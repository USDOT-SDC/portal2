"""Lambda function to retrieve S3 object metadata and export request status."""

import os
import traceback
from typing import Any

import boto3
from boto3.dynamodb.conditions import Attr
import simplejson as json


TABLENAME_EXPORT_FILE_REQUEST: str | None = os.getenv("TABLENAME_EXPORT_FILE_REQUEST")
ALLOW_ORIGIN_URL: str | None = os.getenv("ALLOW_ORIGIN_URL")

s3_client = boto3.client("s3")
dynamodb_resource = boto3.resource("dynamodb")


def _build_response(status_code: int, body: dict[str, Any]) -> dict[str, Any]:
    """Build a standardized API Gateway proxy response.

    Args:
        status_code: HTTP status code for the response.
        body: Dictionary to serialize as the JSON response body.

    Returns:
        API Gateway proxy integration response dict.
    """
    return {
        "isBase64Encoded": False,
        "statusCode": status_code,
        "headers": {
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Origin": ALLOW_ORIGIN_URL,
            "Access-Control-Allow-Methods": "OPTIONS,POST,GET",
            "Content-Type": "text/plain",
        },
        "body": json.dumps(body),
    }


def _get_latest_export_request(file_name: str) -> dict[str, Any] | None:
    """Query DynamoDB for the most recent export file request matching the S3 key.

    Args:
        file_name: The S3 key to filter on.

    Returns:
        The most recent matching item, or None if no matches found.
    """
    table = dynamodb_resource.Table(TABLENAME_EXPORT_FILE_REQUEST)

    scan_response = table.scan(
        Select="ALL_ATTRIBUTES",
        FilterExpression=Attr("S3Key").eq(file_name),
    )

    items: list[dict[str, Any]] = scan_response.get("Items", [])
    if not items:
        return None

    return sorted(items, key=lambda x: x["ReqReceivedTimestamp"], reverse=True)[0]


def lambda_handler(event: dict[str, Any], context: Any) -> dict[str, Any]:
    """Retrieve S3 object metadata and enrich it with export request status.

    Fetches metadata for the specified S3 object via head_object, then looks up
    the most recent export file request in DynamoDB to determine the review status.

    Args:
        event: API Gateway proxy event containing queryStringParameters
            with 'bucket_name' and 'file_name'.
        context: Lambda context object (unused).

    Returns:
        API Gateway proxy response containing the enriched S3 metadata.
    """
    params: dict[str, str] | None = event.get("queryStringParameters")
    if not params or "bucket_name" not in params or "file_name" not in params:
        print("Error: Missing required query parameters 'bucket_name' and/or 'file_name'")
        return _build_response(400, {"error": "Missing required query parameters: bucket_name, file_name"})

    bucket_name: str = params["bucket_name"]
    file_name: str = params["file_name"]
    print(f"Params - bucket_name: {bucket_name}, file_name: {file_name}")

    try:
        response = s3_client.head_object(Bucket=bucket_name, Key=file_name)
        metadata: dict[str, str] = response["Metadata"]
        etag: str = response["ETag"]
        print(f"S3 object metadata: {metadata}")

        metadata["LastModified"] = str(response["LastModified"])

        latest_request = _get_latest_export_request(file_name)

        if latest_request is None:
            metadata["requestReviewStatus"] = "-1"
        elif str(etag) == str(latest_request["S3KeyHash"]):
            print(f"ETag match: {etag} == {latest_request['S3KeyHash']}")
            metadata["requestReviewStatus"] = latest_request["RequestReviewStatus"]
        else:
            print(f"ETag mismatch: {etag} != {latest_request['S3KeyHash']}")
            metadata["requestReviewStatus"] = "-1"


    except s3_client.exceptions.NoSuchKey:
        print(f"Error: S3 object not found - bucket: {bucket_name}, key: {file_name}")
        return _build_response(404, {"error": f"S3 object not found: {file_name}"})

    except Exception:
        print(f"Error: Failed to get S3 metadata:\n{traceback.format_exc()}")
        return _build_response(500, {"error": "Failed to get S3 metadata"})

    print(f"Response metadata: {metadata}")
    return _build_response(200,{
    "download": metadata.get("download", "false"),
    "export": metadata.get("export", "false"),
    "publish": metadata.get("publish", "false"),
    "requestReviewStatus": metadata["requestReviewStatus"],
    "LastModified": metadata["LastModified"],
})

