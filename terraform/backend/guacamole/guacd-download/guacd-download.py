"""Download guacd RPMs via a throwaway RHEL9 EC2 and copy them to the local files/ directory.

Launches a bare RHEL9 instance (not the DOT gold AMI), installs guacd and its RDP/xfreerdp
dependencies from EPEL, uploads the RPMs to a temporary S3 prefix, downloads them to the
local ../files/ directory, then terminates the instance and cleans up all temp AWS resources.

Run this script whenever guac_version changes in user-data.tf, then commit the resulting
RPMs in ../files/ to git.

Usage:
    python guacd-download.py

Config is read from config.json in the same directory.
"""

import json
import logging
import os
import sys
import textwrap
import time
from pathlib import Path
from typing import Any

import boto3
from botocore.exceptions import ClientError


_log_level = getattr(logging, os.environ.get("LOG_LEVEL", "INFO").upper(), logging.INFO)
logger = logging.getLogger()
logger.setLevel(_log_level)
for _h in logger.handlers[:]:
    logger.removeHandler(_h)
_ch = logging.StreamHandler()
_ch.setLevel(_log_level)
_ch.setFormatter(logging.Formatter("%(levelname)s - %(message)s"))
logger.addHandler(_ch)

SCRIPT_DIR = Path(__file__).parent
CONFIG_PATH = SCRIPT_DIR / "config.json"

TEMP_ROLE_NAME = "guacd-download-temp-role"
TEMP_PROFILE_NAME = "guacd-download-temp-profile"
TEMP_SG_NAME = "guacd-download-temp-sg"
TEMP_INSTANCE_TAG = "guacd-download-temp"


def load_config() -> dict[str, Any]:
    """Load config.json from the script directory.

    Returns:
        Parsed configuration dictionary.
    """
    with open(CONFIG_PATH) as f:
        return json.load(f)


def get_latest_rhel9_ami(ec2: Any, owner: str) -> str:
    """Find the most recently created RHEL9 x86_64 AMI from the given owner.

    Args:
        ec2: Boto3 EC2 client.
        owner: AWS account ID of the AMI owner (Red Hat's public account).

    Returns:
        AMI ID string.

    Raises:
        RuntimeError: If no matching AMIs are found.
    """
    response = ec2.describe_images(
        Owners=[owner],
        Filters=[
            {"Name": "name", "Values": ["RHEL-9*"]},
            {"Name": "architecture", "Values": ["x86_64"]},
            {"Name": "state", "Values": ["available"]},
        ],
    )
    images = sorted(response["Images"], key=lambda x: x["CreationDate"], reverse=True)
    if not images:
        raise RuntimeError(f"No RHEL9 AMIs found for owner {owner}")
    ami_id = images[0]["ImageId"]
    logger.info("Using AMI: %s (%s)", ami_id, images[0]["Name"])
    return ami_id


def get_vpc_for_subnet(ec2: Any, subnet_id: str) -> str:
    """Return the VPC ID for the given subnet.

    Args:
        ec2: Boto3 EC2 client.
        subnet_id: Subnet ID to look up.

    Returns:
        VPC ID string.
    """
    response = ec2.describe_subnets(SubnetIds=[subnet_id])
    return response["Subnets"][0]["VpcId"]


def create_temp_iam(iam: Any, bucket: str, prefix: str) -> None:
    """Create a temporary IAM role and instance profile scoped to S3 PutObject on the tmp prefix.

    Deletes any leftover resources with the same names before creating fresh ones, so the
    script is safe to re-run after a failed previous attempt.

    Args:
        iam: Boto3 IAM client.
        bucket: S3 bucket name.
        prefix: S3 key prefix the instance is allowed to write to.
    """
    # Clean up any leftovers from a previous failed run
    delete_temp_iam(iam)

    assume_policy = json.dumps({
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Principal": {"Service": "ec2.amazonaws.com"},
            "Action": "sts:AssumeRole",
        }],
    })
    inline_policy = json.dumps({
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Action": ["s3:PutObject", "s3:DeleteObject"],
            "Resource": f"arn:aws:s3:::{bucket}/{prefix}*",
        }],
    })

    logger.info("Creating temp IAM role: %s", TEMP_ROLE_NAME)
    iam.create_role(RoleName=TEMP_ROLE_NAME, AssumeRolePolicyDocument=assume_policy)
    iam.put_role_policy(RoleName=TEMP_ROLE_NAME, PolicyName="s3-put", PolicyDocument=inline_policy)

    logger.info("Creating temp IAM instance profile: %s", TEMP_PROFILE_NAME)
    iam.create_instance_profile(InstanceProfileName=TEMP_PROFILE_NAME)
    iam.add_role_to_instance_profile(InstanceProfileName=TEMP_PROFILE_NAME, RoleName=TEMP_ROLE_NAME)

    # IAM changes take a few seconds to propagate before EC2 can assume the role
    logger.info("Waiting 15s for IAM propagation...")
    time.sleep(15)


def delete_temp_iam(iam: Any) -> None:
    """Delete the temporary IAM role and instance profile if they exist.

    Safe to call even when resources don't exist — skips each step quietly if the
    resource is already gone.

    Args:
        iam: Boto3 IAM client.
    """
    def _ignore_not_found(fn: Any, **kwargs: Any) -> None:
        try:
            fn(**kwargs)
        except ClientError as e:
            code = e.response["Error"]["Code"]
            if code not in ("NoSuchEntity", "NoSuchEntityException"):
                logger.warning("IAM cleanup warning (%s): %s", code, e)

    logger.info("Cleaning up temp IAM resources (if any)...")
    _ignore_not_found(
        iam.remove_role_from_instance_profile,
        InstanceProfileName=TEMP_PROFILE_NAME,
        RoleName=TEMP_ROLE_NAME,
    )
    _ignore_not_found(iam.delete_instance_profile, InstanceProfileName=TEMP_PROFILE_NAME)
    _ignore_not_found(iam.delete_role_policy, RoleName=TEMP_ROLE_NAME, PolicyName="s3-put")
    _ignore_not_found(iam.delete_role, RoleName=TEMP_ROLE_NAME)
    logger.info("Temp IAM cleanup done.")


def create_temp_sg(ec2: Any, vpc_id: str) -> str:
    """Create a temporary security group with default egress (all outbound allowed).

    Deletes any leftover SG with the same name in the same VPC before creating a fresh one.

    Args:
        ec2: Boto3 EC2 client.
        vpc_id: VPC to create the SG in.

    Returns:
        Security group ID.
    """
    # Clean up any leftover from a previous failed run
    existing = ec2.describe_security_groups(
        Filters=[
            {"Name": "group-name", "Values": [TEMP_SG_NAME]},
            {"Name": "vpc-id", "Values": [vpc_id]},
        ]
    )
    for sg in existing.get("SecurityGroups", []):
        logger.info("Deleting leftover temp SG %s...", sg["GroupId"])
        try:
            ec2.delete_security_group(GroupId=sg["GroupId"])
        except ClientError as e:
            logger.warning("Could not delete leftover SG %s: %s", sg["GroupId"], e)

    logger.info("Creating temp security group in VPC %s...", vpc_id)
    response = ec2.create_security_group(
        GroupName=TEMP_SG_NAME,
        Description="Temporary SG for guacd RPM download - safe to delete",
        VpcId=vpc_id,
    )
    sg_id = response["GroupId"]
    ec2.authorize_security_group_ingress(
        GroupId=sg_id,
        IpPermissions=[{
            "IpProtocol": "tcp",
            "FromPort": 22,
            "ToPort": 22,
            "IpRanges": [{"CidrIp": "0.0.0.0/0"}],
        }],
    )
    logger.info("Created SG: %s (SSH inbound open)", sg_id)
    return sg_id


def delete_temp_sg(ec2: Any, sg_id: str) -> None:
    """Delete the temporary security group.

    Args:
        ec2: Boto3 EC2 client.
        sg_id: Security group ID to delete.
    """
    logger.info("Deleting temp security group %s...", sg_id)
    try:
        ec2.delete_security_group(GroupId=sg_id)
        logger.info("Temp SG deleted.")
    except ClientError as e:
        logger.warning("Error deleting SG %s (may need manual cleanup): %s", sg_id, e)


def build_user_data(bucket: str, prefix: str) -> str:
    """Build the user-data script for the temp EC2.

    Downloads guacd and its dependencies from EPEL, uploads all RPMs to S3,
    drops a 'done' marker, then shuts down (triggering instance termination).

    Args:
        bucket: S3 bucket name.
        prefix: S3 key prefix to upload RPMs under.

    Returns:
        Shell script string.
    """
    return textwrap.dedent(f"""\
        #!/bin/bash
        exec > >(tee /tmp/guacd-download.log | logger -t guacd-download -s 2>/dev/console) 2>&1
        set -e

        echo "=== Installing AWS CLI ==="
        dnf install -y unzip
        curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
        unzip -q /tmp/awscliv2.zip -d /tmp
        /tmp/aws/install
        export PATH=/usr/local/bin:$PATH

        echo "=== Installing EPEL ==="
        dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm

        echo "=== Downloading guacd RPMs and all dependencies ==="
        mkdir -p /tmp/guacd-rpms
        dnf download --resolve --destdir /tmp/guacd-rpms guacd libguac-client-rdp xfreerdp

        echo "=== Uploading RPMs to S3 ==="
        for f in /tmp/guacd-rpms/*.rpm; do
            echo "Uploading $(basename $f)..."
            aws s3 cp "$f" "s3://{bucket}/{prefix}$(basename $f)" --region us-east-1
        done

        echo "=== Dropping done marker ==="
        echo "done" | aws s3 cp - "s3://{bucket}/{prefix}done" --region us-east-1

        echo "=== All done, shutting down ==="
        shutdown -h now
    """)


def launch_instance(
    ec2: Any,
    config: dict[str, Any],
    ami_id: str,
    sg_id: str,
    user_data: str,
) -> str:
    """Launch the throwaway EC2 instance.

    Args:
        ec2: Boto3 EC2 client.
        config: Parsed config.json dictionary.
        ami_id: AMI to launch.
        sg_id: Security group ID to attach.
        user_data: Shell script to run on boot.

    Returns:
        Instance ID string.
    """
    logger.info("Launching temp EC2 instance...")
    response = ec2.run_instances(
        ImageId=ami_id,
        InstanceType=config["instance_type"],
        MinCount=1,
        MaxCount=1,
        SubnetId=config["subnet_id"],
        KeyName=config["key_name"],
        IamInstanceProfile={"Name": TEMP_PROFILE_NAME},
        SecurityGroupIds=[sg_id],
        UserData=user_data,
        InstanceInitiatedShutdownBehavior="terminate",
        TagSpecifications=[{
            "ResourceType": "instance",
            "Tags": [{"Key": "Name", "Value": TEMP_INSTANCE_TAG}],
        }],
    )
    instance_id = response["Instances"][0]["InstanceId"]
    logger.info("Launched instance: %s", instance_id)
    return instance_id


def terminate_instance(ec2: Any, instance_id: str) -> None:
    """Terminate an EC2 instance if it is not already terminated.

    Args:
        ec2: Boto3 EC2 client.
        instance_id: Instance ID to terminate.
    """
    try:
        ec2.terminate_instances(InstanceIds=[instance_id])
        logger.info("Termination request sent for %s.", instance_id)
    except ClientError as e:
        logger.warning("Error sending termination request: %s", e)


def wait_for_termination(ec2: Any, instance_id: str, timeout_seconds: int = 600) -> None:
    """Block until the instance reaches the 'terminated' state.

    Args:
        ec2: Boto3 EC2 client.
        instance_id: Instance ID to wait on.
        timeout_seconds: Maximum seconds to wait before raising.

    Raises:
        TimeoutError: If the instance does not terminate within timeout_seconds.
    """
    logger.info("Waiting for instance %s to terminate...", instance_id)
    waiter = ec2.get_waiter("instance_terminated")
    waiter.wait(
        InstanceIds=[instance_id],
        WaiterConfig={"Delay": 15, "MaxAttempts": timeout_seconds // 15},
    )
    logger.info("Instance %s terminated.", instance_id)


def wait_for_done_marker(s3: Any, bucket: str, prefix: str, timeout_seconds: int = 900) -> None:
    """Poll S3 for the 'done' marker dropped by user-data when the upload completes.

    Args:
        s3: Boto3 S3 client.
        bucket: S3 bucket name.
        prefix: S3 key prefix where the marker will appear.
        timeout_seconds: Maximum seconds to poll before raising.

    Raises:
        TimeoutError: If the marker does not appear within timeout_seconds.
    """
    marker_key = prefix + "done"
    logger.info("Polling for done marker at s3://%s/%s", bucket, marker_key)
    deadline = time.time() + timeout_seconds
    while time.time() < deadline:
        try:
            s3.head_object(Bucket=bucket, Key=marker_key)
            logger.info("Done marker found.")
            return
        except ClientError as e:
            if e.response["Error"]["Code"] in ("404", "NoSuchKey"):
                remaining = int(deadline - time.time())
                logger.info("Not ready yet — polling again in 20s (%ds remaining)...", remaining)
                time.sleep(20)
            else:
                raise
    raise TimeoutError(f"Timed out after {timeout_seconds}s waiting for done marker")


def download_rpms(s3: Any, bucket: str, prefix: str, local_dir: Path) -> list[str]:
    """Download all RPMs from the S3 tmp prefix to the local files directory.

    Args:
        s3: Boto3 S3 client.
        bucket: S3 bucket name.
        prefix: S3 key prefix containing the RPMs.
        local_dir: Local directory to write RPMs into.

    Returns:
        List of downloaded filenames.
    """
    local_dir.mkdir(parents=True, exist_ok=True)
    paginator = s3.get_paginator("list_objects_v2")
    downloaded: list[str] = []
    for page in paginator.paginate(Bucket=bucket, Prefix=prefix):
        for obj in page.get("Contents", []):
            key = obj["Key"]
            filename = Path(key).name
            if not filename.endswith(".rpm"):
                continue
            dest = local_dir / filename
            logger.info("Downloading s3://%s/%s -> %s", bucket, key, dest)
            s3.download_file(bucket, key, str(dest))
            downloaded.append(filename)
    return downloaded


def delete_s3_prefix(s3: Any, bucket: str, prefix: str) -> None:
    """Delete all objects under the given S3 prefix.

    Args:
        s3: Boto3 S3 client.
        bucket: S3 bucket name.
        prefix: S3 key prefix to wipe.
    """
    logger.info("Cleaning up S3 prefix s3://%s/%s...", bucket, prefix)
    paginator = s3.get_paginator("list_objects_v2")
    for page in paginator.paginate(Bucket=bucket, Prefix=prefix):
        objects = [{"Key": obj["Key"]} for obj in page.get("Contents", [])]
        if objects:
            s3.delete_objects(Bucket=bucket, Delete={"Objects": objects})
    logger.info("S3 cleanup complete.")


def main() -> None:
    """Orchestrate the full RPM download workflow."""
    config = load_config()
    local_files_dir = (SCRIPT_DIR / config["local_files_dir"]).resolve()
    bucket = config["terraform_bucket"]
    prefix = config["s3_tmp_prefix"]

    session = boto3.Session(profile_name=config["aws_profile"], region_name=config["region"])
    ec2 = session.client("ec2")
    iam = session.client("iam")
    s3 = session.client("s3")

    iam_created = False
    sg_id: str | None = None
    instance_id: str | None = None

    try:
        ami_id = get_latest_rhel9_ami(ec2, config["rhel9_ami_owner"])
        vpc_id = get_vpc_for_subnet(ec2, config["subnet_id"])

        create_temp_iam(iam, bucket, prefix)
        iam_created = True

        sg_id = create_temp_sg(ec2, vpc_id)

        user_data = build_user_data(bucket, prefix)
        instance_id = launch_instance(ec2, config, ami_id, sg_id, user_data)

        wait_for_done_marker(s3, bucket, prefix)
        downloaded = download_rpms(s3, bucket, prefix, local_files_dir)
        delete_s3_prefix(s3, bucket, prefix)

        wait_for_termination(ec2, instance_id)
        instance_id = None  # terminated, no longer needs cleanup

        delete_temp_sg(ec2, sg_id)
        sg_id = None

        delete_temp_iam(iam)
        iam_created = False

        logger.info("Downloaded %d RPMs to %s:", len(downloaded), local_files_dir)
        for f in sorted(downloaded):
            logger.info("  %s", f)
        logger.info("All done. Commit the RPMs in %s to git.", local_files_dir)

    except Exception:
        logger.exception("Script failed")
        if instance_id:
            logger.warning("Terminating instance %s...", instance_id)
            terminate_instance(ec2, instance_id)
            try:
                wait_for_termination(ec2, instance_id)
            except Exception:
                logger.warning("Instance %s may still be running — check the AWS console.", instance_id)
        if sg_id:
            delete_temp_sg(ec2, sg_id)
        if iam_created:
            delete_temp_iam(iam)
        sys.exit(1)


if __name__ == "__main__":
    main()
