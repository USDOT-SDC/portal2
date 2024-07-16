import json
import boto3
from boto3.dynamodb.conditions import Key


def lambda_handler(event: dict, context: object):
    """
    The Lambda handler

    Args:
        event (dict): The Lambda event data
        context (object): The Lambda context data

    Returns:
        dict: Status
    """
    print(f"{context.get_remaining_time_in_millis() * 1000} seconds to execution time out")
    table_name = event["queryStringParameters"]["table_name"]
    table = boto3.resource("dynamodb").Table(table_name)
    operation = event["httpMethod"]
    if operation == "POST":
        return create_item(event, table)
    elif operation == "GET":
        return read_item(event, table)
    elif operation == "PUT":
        return update_item(event, table)
    elif operation == "DELETE":
        return delete_item(event, table)
    else:
        return {"statusCode": 400, "body": json.dumps("Unsupported method")}


def create_item(event: dict, table: boto3.resource.Table) -> dict:
    """
    Creates a new item

    Returns:
        dict: Status
    """
    body = json.loads(event["body"])
    table.put_item(Item=body)
    return {"statusCode": 200, "body": json.dumps("Item created")}


def read_item(event: dict, table: boto3.resource.Table):
    """
    Reads an item

    Returns:
        dict: Status
    """
    hash_key = event["queryStringParameters"]["hash_key"]
    key = event["queryStringParameters"][hash_key]
    response = table.get_item(Key={hash_key: key})
    return {"statusCode": 200, "body": json.dumps(response.get("Item", {}))}


def update_item(event: dict, table: boto3.resource.Table):
    """
    Updates an item

    Returns:
        dict: Status
    """
    body = json.loads(event["body"])
    hash_key = event["queryStringParameters"]["hash_key"]
    key = {hash_key: body[hash_key]}
    update_expression = "SET " + ", ".join(f"{k}=:{k}" for k in body if k != hash_key)
    expression_attribute_values = {f":{k}": v for k, v in body.items() if k != hash_key}
    table.update_item(
        Key=key,
        UpdateExpression=update_expression,
        ExpressionAttributeValues=expression_attribute_values,
    )
    return {"statusCode": 200, "body": json.dumps("Item updated")}


def delete_item(event: dict, table: boto3.resource.Table):
    """
    Deletes an item

    Returns:
        dict: Status
    """
    hash_key = event["queryStringParameters"]["hash_key"]
    key = event["queryStringParameters"][hash_key]
    table.delete_item(Key={hash_key: key})
    return {"statusCode": 200, "body": json.dumps("Item deleted")}
