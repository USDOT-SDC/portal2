import boto3
import os
import ast, json
from boto3.dynamodb.conditions import Key, Attr

RESTAPIID = os.getenv("RESTAPIID")
AUTHORIZERID = os.getenv("AUTHORIZERID")
TABLENAME_USER_STACKS = os.getenv("TABLENAME_USER_STACKS")
TABLENAME_AVAILABLE_DATASET = os.getenv("TABLENAME_AVAILABLE_DATASET")
TABLENAME_TRUSTED_USERS = os.getenv("TABLENAME_TRUSTED_USERS")
TABLENAME_AUTOEXPORT_USERS = os.getenv("TABLENAME_AUTOEXPORT_USERS")
ALLOW_ORIGIN_URL = os.getenv("ALLOW_ORIGIN_URL")


print("Loading function")
dynamo_resource = boto3.resource("dynamodb")


def get_user_details(id_token):
    apigateway = boto3.client("apigateway")
    response = apigateway.test_invoke_authorizer(
        restApiId=RESTAPIID,
        authorizerId=AUTHORIZERID,
        headers={"Authorization": id_token},
    )
    print("test invoke authorizer response: ", response)
    email = response["claims"]["email"]
    full_username = response["claims"]["cognito:username"]
    return {"email": email, "username": full_username}


def get_datasets():
    try:
        table = dynamo_resource.Table(TABLENAME_AVAILABLE_DATASET)
        response = table.scan(TableName=TABLENAME_AVAILABLE_DATASET)
        return {"datasets": response}
    except Exception:
        print(Exception)


def get_user_trustedstatus(userid):
    trustedUsersTable = dynamo_resource.Table(TABLENAME_TRUSTED_USERS)

    response = trustedUsersTable.query(
        KeyConditionExpression=Key("UserID").eq(userid), FilterExpression=Attr("TrustedStatus").eq("Trusted")
    )
    userTrustedStatus = {}
    for x in response["Items"]:
        userTrustedStatus[x["Dataset-DataProvider-Datatype"]] = "Trusted"

    return userTrustedStatus


def get_user_autoexportstatus(userid):
    autoExportUsersTable = dynamo_resource.Table(TABLENAME_AUTOEXPORT_USERS)

    response = autoExportUsersTable.query(
        KeyConditionExpression=Key("UserID").eq(userid), FilterExpression=Attr("AutoExportStatus").eq("Approved")
    )
    userAutoExportStatus = {}
    for x in response["Items"]:
        userAutoExportStatus[x["Dataset-DataProvider-Datatype"]] = "Approved"

    return userAutoExportStatus


def lambda_handler(event, context):
    user_info = {}
    roles = []
    try:
        id_token = event["headers"]["Authorization"]
        info_dict = get_user_details(id_token)
        user_info["email"] = info_dict["email"]
        user_info["username"] = info_dict["username"]
        user_info["datasets"] = get_datasets()["datasets"]["Items"]
        user_info["userTrustedStatus"] = get_user_trustedstatus(info_dict["username"])
        user_info["userAutoExportStatus"] = get_user_autoexportstatus(info_dict["username"])
    except Exception:
        print(Exception)

    table = dynamo_resource.Table(TABLENAME_USER_STACKS)

    # Get the item with role name
    try:
        response_table = table.get_item(Key={"username": user_info["username"]})
    except Exception:
        print(Exception)

    # Convert unicode to ascii
    try:
        user_info["stacks"] = ast.literal_eval(json.dumps(response_table["Item"]["stacks"]))
        user_info["team_slug"] = response_table["Item"]["teamName"]
        user_info["upload_locations"] = response_table["Item"]["upload_locations"]
        user_info["name"] = response_table["Item"]["name"]
    except Exception:
        print(Exception)

    # Lambda with proxy integration response must be in the format: {'isBase64Encoded': true|false, 'statusCode':<htmlstatuscode>, 'headers':{'<name>':'<value',...}, 'body':<body>}
    return {
        "isBase64Encoded": False,
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Origin": ALLOW_ORIGIN_URL,
            "Access-Control-Allow-Methods": "OPTIONS,POST,GET",
            "Content-Type": "text/plain",
        },
        "body": json.dumps(user_info),
    }
