# guacd-download

Downloads `guacd`, `libguac-client-rdp`, and `xfreerdp` RPMs (plus all dependencies) from
EPEL and copies them into `../files/guacd-rpms/` so Terraform can upload them to S3.

## Why this exists

The DOT gold AMI blocks EPEL. These packages are not in any DOT-managed repo. This script
launches a throwaway bare RHEL9 instance (Red Hat's public AMI, not the gold image), pulls
the RPMs via `dnf download --resolve`, pushes them to a temp S3 prefix, downloads them
locally, then terminates everything.

Run this only when `guac_version` changes in `user-data.tf`. Commit the resulting RPMs in
`../files/guacd-rpms/` to git — teammates don't need to run this themselves.

## Prerequisites

- Python 3.x with a venv: `python -m venv .venv && .venv\Scripts\activate && pip install -r requirements.txt`
- AWS credentials for the profile in `config.json` (`sdc-dev` by default)
- The profile must have IAM and EC2 permissions to create/delete roles, instance profiles,
  security groups, and launch instances
- VPN access to the subnet in `config.json` (SSH inbound is opened automatically for
  troubleshooting; the instance IP will be on a private CIDR)

## Usage

```cmd
cd terraform\backend\guacamole\guacd-download
.venv\Scripts\activate
python guacd-download.py
```

After it completes, the new RPMs appear in `../files/guacd-rpms/`. Commit them, then run
`terraform apply` — Terraform will upload them to S3 and replace the Guac instance.

## config.json

| Key | Description |
|-----|-------------|
| `aws_profile` | Named AWS CLI profile to use |
| `region` | AWS region |
| `guac_version` | Guacamole version (informational only — does not affect RPM download) |
| `terraform_bucket` | S3 bucket where Terraform artifacts live |
| `s3_tmp_prefix` | Temporary S3 prefix used during download (cleaned up automatically) |
| `local_files_dir` | Relative path to the RPM output directory (`../files/guacd-rpms`) |
| `rhel9_ami_owner` | AWS account ID for Red Hat's public AMIs (`309956199498`) |
| `instance_type` | EC2 instance type for the throwaway instance |
| `subnet_id` | Subnet to launch the instance in (must have NAT/internet access for EPEL) |
| `key_name` | EC2 key pair name for SSH access (used for troubleshooting only) |

## What the script does

1. Cleans up any leftover temp IAM/SG resources from a previous failed run
2. Finds the latest RHEL9 AMI from Red Hat's public account
3. Creates a temporary IAM role scoped to `s3:PutObject` on the tmp prefix only
4. Creates a temporary security group with SSH (port 22) inbound and full egress
5. Launches a `t3.medium` with user-data that:
   - Installs the AWS CLI (not present on bare RHEL9)
   - Installs EPEL
   - Runs `dnf download --resolve` for guacd, libguac-client-rdp, and xfreerdp
   - Uploads all RPMs (~126 packages) to the temp S3 prefix
   - Drops a `done` marker in S3, then shuts down
6. Polls S3 for the `done` marker (timeout: 15 minutes)
7. Downloads all RPMs to `local_files_dir`
8. Deletes the temp S3 prefix, waits for instance termination, deletes the SG and IAM role

On failure the script terminates the instance and cleans up all temp AWS resources before
exiting with code 1. It is safe to re-run after a failure.

## Notes

- The bare RHEL9 AMI does **not** include the AWS CLI — the user-data script installs it
  from the official AWS installer before attempting any S3 operations
- The script is safe to re-run — leftover IAM roles, instance profiles, and security groups
  from failed runs are detected and deleted automatically at startup
- Expect a total runtime of ~10 minutes (AWS CLI install + EPEL + 126 dep downloads)
