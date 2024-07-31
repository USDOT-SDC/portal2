# API which is used when a user submits an export request for approval

import boto3
import logging
import ast
import simplejson as json
from datetime import datetime
import hashlib
import time
import os
from boto3.dynamodb.conditions import Key, Attr


RESTAPIID = os.getenv("RESTAPIID")
AUTHORIZERID = os.getenv("AUTHORIZERID")
TABLENAME_USER_STACKS = os.getenv("TABLENAME_USER_STACKS")
TABLENAME_AVAILABLE_DATASET = os.getenv("TABLENAME_AVAILABLE_DATASET")
TABLENAME_TRUSTED_USERS = os.getenv("TABLENAME_TRUSTED_USERS")
TABLENAME_AUTOEXPORT_USERS = os.getenv("TABLENAME_AUTOEXPORT_USERS")
TABLENAME_EXPORT_FILE_REQUEST = os.getenv("TABLENAME_EXPORT_FILE_REQUEST")
RECEIVER = os.getenv("RECEIVER_EMAIL")
ALLOW_ORIGIN_URL = os.getenv("ALLOW_ORIGIN_URL")

logger = logging.getLogger()
dynamodb_client = boto3.resource('dynamodb')

def get_user_details_from_username(username):
    try:
        table = dynamodb_client.Table(TABLENAME_USER_STACKS)  
        response_table = table.get_item(Key={'username': username })
        team_name = response_table['Item']['teamName']
        logging.info("team_name: " + team_name)
    except BaseException as be:
        logging.exception("Error: Failed to get the team name for the user" + str(be))
        raise ("Failed to get the team name for the user")
    return team_name


def get_user_details(id_token):
    apigateway = boto3.client('apigateway')
    response = apigateway.test_invoke_authorizer(
    restApiId=RESTAPIID,
    authorizerId=AUTHORIZERID,
    headers={
        'Authorization': id_token
    })
    print('test invoke authorizer response: ', response)
    roles_response=response['claims']['family_name']
    email=response['claims']['email']
    full_username=response['claims']['cognito:username'].split('\\')[1]
    roles_list_formatted = ast.literal_eval(json.dumps(roles_response))
    role_list= roles_list_formatted.split(",")

    roles=[]
    for r in role_list:
        if ":role/" in r:
            roles.append(r.split(":role/")[1])

    return { 'role' : roles , 'email': email, 'username': full_username }
 

def get_combined_export_workflow():
    availableDatasets = get_datasets()['datasets']['Items']
    combinedExportWorkflow = {}
    for dataset in availableDatasets:
        if 'exportWorkflow' in dataset:
            combinedExportWorkflow.update(dataset['exportWorkflow'])
    return combinedExportWorkflow


def get_user_trustedstatus(userid):
    trustedUsersTable = dynamodb_client.Table(TABLENAME_TRUSTED_USERS)

    response = trustedUsersTable.query(
        KeyConditionExpression=Key('UserID').eq(userid),
        FilterExpression=Attr('TrustedStatus').eq('Trusted')
    )
    userTrustedStatus = {}
    for x in response['Items']:
        userTrustedStatus[x['Dataset-DataProvider-Datatype']] = 'Trusted'

    return userTrustedStatus


def get_datasets():
    try:
        table = dynamodb_client.Table(TABLENAME_AVAILABLE_DATASET)
        response = table.scan(TableName=TABLENAME_AVAILABLE_DATASET)
        return { 'datasets' : response }
    except BaseException as be:
        logging.exception("Error: Failed to get dataset" + str(be) )
        raise ("Internal error occurred! Contact your administrator.")


def send_notification(listOfPOC, emailContent, subject = 'Export Notification'):
    ses_client = boto3.client('ses')
    sender = RECEIVER
    try:
        response = ses_client.send_email(
            Destination={
                'BccAddresses': [
                ],
                'CcAddresses': [
                ],
                'ToAddresses': listOfPOC,
            },
            Message={
                'Body': {
                    'Html': {
                        'Charset': 'UTF-8',
                        'Data': emailContent,
                    },
                    'Text': {
                        'Charset': 'UTF-8',
                        'Data': 'This is the notification message body in text format.',
                    },
                },
                'Subject': {
                    'Charset': 'UTF-8',
                    'Data': subject,
                },
            },
            Source=sender
        )
    except BaseException as ke:
        logging.exception("Failed to send notification "+ str(ke))
        raise NotFoundError("Failed to send notification")


def lambda_handler(event, context):
    paramsQuery = json.loads(event['body'])
    paramsString = paramsQuery['message']
    logger.setLevel("INFO")
    logging.info("Received request {}".format(paramsString))
    params = json.loads(paramsString)
    bypassExportFileRequestTable = False

    try:
        selctedDataSet=params['selectedDataInfo']['selectedDataSet']
        selectedDataProvider=params['selectedDataInfo']['selectedDataProvider']
        selectedDatatype=params['selectedDataInfo']['selectedDatatype']
        combinedDataInfo=selctedDataSet + "-" + selectedDataProvider + "-" + selectedDatatype
        userID=params['UserID']
        team_name = get_user_details_from_username(userID)

        id_token = event['headers']['Authorization']
        info_dict=get_user_details(id_token)
        user_email=info_dict['email']

        combinedExportWorkflow = get_combined_export_workflow()

        trustedWorkflowStatus = \
        combinedExportWorkflow[selctedDataSet][selectedDataProvider]['datatypes'][selectedDatatype]['Trusted']['WorkflowStatus']

        nonTrustedWorkflowStatus = \
            combinedExportWorkflow[selctedDataSet][selectedDataProvider]['datatypes'][selectedDatatype]['NonTrusted']['WorkflowStatus']

        listOfPOC=combinedExportWorkflow[selctedDataSet][selectedDataProvider]['ListOfPOC']
        emailContent = ""
        dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
        acceptableUse = 'Decline'

        # verify if user is already trusted for selected combinedDataInfo
        userTrustedStatus = get_user_trustedstatus(userID)
        userTrustedStatusForSelectedDataset = combinedDataInfo in userTrustedStatus and userTrustedStatus[combinedDataInfo] == 'Trusted'

        if 'acceptableUse' in params and params['acceptableUse']:
            acceptableUse = params['acceptableUse']

        if 'trustedRequest' in params:
            trustedUsersTable = dynamodb.Table(TABLENAME_TRUSTED_USERS)

            trustedStatus = params['trustedRequest']['trustedRequestStatus']
            trustedReason = params['trustedRequest']['trustedRequestReason']

            if trustedStatus == 'Submitted' :
                bypassExportFileRequestTable = True

            if acceptableUse == 'Decline':
                trustedStatus = 'Untrusted'
                emailContent = "<br/>Trusted status has been declined to <b>" + userID + "</b> for dataset <b>" + combinedDataInfo + "</b>"
            elif trustedWorkflowStatus == 'Notify':
                trustedStatus='Trusted'
                emailContent="<br/>Trusted status has been approved to <b>" + userID + "</b> for dataset <b>" + combinedDataInfo + "</b>"
            else:
                emailContent = "<br/>Trusted status has been requested by <b>" + userID + "</b> for dataset <b>" + combinedDataInfo + "</b>"

             #send email to List of POC for Trusted Status Requests
            send_notification(listOfPOC,emailContent)    

            response = trustedUsersTable.put_item(
                Item = {
                    'UserID': userID,
                    'UserEmail': user_email,
                    'Dataset-DataProvider-Datatype': combinedDataInfo,
                    'TrustedStatus': trustedStatus,
                    'TrustedJustification': trustedReason,
                    'UsagePolicyStatus': acceptableUse,
                    'ReqReceivedTimestamp': int(time.time()),
                    'LastUpdatedTimestamp': datetime.datetime.utcnow().strftime("%Y%m%d")
                }
            )

        if 'autoExportRequest' in params:
            autoExportUsersTable = dynamodb.Table(TABLENAME_AUTOEXPORT_USERS)

            autoExportStatus = params['autoExportRequest']['autoExportRequestStatus']
            autoExportReason = params['autoExportRequest']['autoExportRequestReason']
            autoExportDataInfo = combinedDataInfo.split('-')[0] + '-' + combinedDataInfo.split('-')[1] + '-' + params['autoExportRequest']['autoExportRequestDataset']

            send_notification(listOfPOC,"Auto-Export status has been requested by <b>" + userID + "</b> for dataset <b>" + autoExportDataInfo + "</b>", 'Auto-Export Request')

            response = autoExportUsersTable.put_item(
                            Item = {
                                'UserID': userID,
                                'UserEmail': user_email,
                                'Dataset-DataProvider-Datatype': autoExportDataInfo,
                                'AutoExportStatus': autoExportStatus,
                                'ReqReceivedTime': int(time.time()),
                                'LastUpdatedTime': datetime.datetime.utcnow().strftime("%Y%m%d"),
                                'Justification': autoExportReason
                            }
                        )

        if not bypassExportFileRequestTable :

            requestReviewStatus = params['RequestReviewStatus']
            download = 'false'
            export = 'true'
            publish = 'false'
            if nonTrustedWorkflowStatus == 'Notify' or userTrustedStatusForSelectedDataset is True:
                requestReviewStatus = 'Approved'
                download = 'true'
                publish = 'true'
                export = 'false'
                emailContent += "<br/>Export request has been approved to <b>" + userID + "</b> for dataset <b>" + params['S3Key'] + "</b>"

            else:
                emailContent += "<br/>Export request has been requested by <b>" + userID + "</b> for dataset <b>" + params['S3Key'] + "</b>"


            exportFileRequestTable = dynamodb.Table(TABLENAME_EXPORT_FILE_REQUEST)
            hashed_object = hashlib.md5(params['S3Key'].encode())

            s3 = boto3.resource('s3')
            s3_object = s3.Object(params['TeamBucket'], params['S3Key'])
    
            s3_object.copy_from(CopySource={'Bucket': params['TeamBucket'], 'Key': params['S3Key']},
                                Metadata={'download': download, 'export': export, 'publish': publish},
                                MetadataDirective='REPLACE')
            logging.info("BEFORE")
            logging.info("KEY == " + params['TeamBucket'] + params['S3Key'])
            client_s3 = boto3.client('s3')
            response = client_s3.list_object_versions(Bucket=params['TeamBucket'], Prefix=params['S3Key'])
            latest_version = max(response['Versions'], key=lambda x: x['LastModified'])
            logging.info("LATEST VERSION" + str(latest_version))


            timemills = int(time.time())
            response = exportFileRequestTable.put_item(
                Item={
                    'S3KeyHash': str(latest_version['ETag']),
                    'Dataset-DataProvider-Datatype': combinedDataInfo,
                    'ApprovalForm': params['ApprovalForm'],
                    'RequestReviewStatus': requestReviewStatus,
                    'S3Key': params['S3Key'],
                    'RequestedBy_Epoch': userID + "_" + str(timemills),
                    'RequestedBy': userID,
                    'TeamBucket': params['TeamBucket'],
                    'ReqReceivedTimestamp': timemills,
                    'UserEmail': user_email,
                    'ReqReceivedDate': datetime.now().strftime('%Y-%m-%d')
                }
            )
            availableDatasets = get_datasets()['datasets']['Items']
            logging.info("Available datasets:" + str(availableDatasets))

            

            #send email to List of POC
            send_notification(listOfPOC,emailContent)


    except BaseException as be:
        logging.exception("Error: Failed to process export request" + str(be))
        raise ("Failed to process export request")

    return {
        'isBase64Encoded': False, 
        'statusCode':200,
        'headers':{
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Origin': ALLOW_ORIGIN_URL,
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET',
                'Content-Type': 'text/plain'
        }, 
        'body':json.dumps(response)
    }