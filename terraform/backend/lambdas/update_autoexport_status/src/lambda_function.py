import boto3
import simplejson as json
import os


RECEIVER = os.getenv("RECEIVER_EMAIL")
TABLENAME_AUTOEXPORT_USERS = os.getenv("TABLENAME_AUTOEXPORT_USERS")
ALLOW_ORIGIN_URL = os.getenv("ALLOW_ORIGIN_URL")

dynamodb_client = boto3.resource('dynamodb')

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
    paramsQuery = event['body']
    paramsString = paramsQuery['message']
    logger.setLevel("INFO")
    logging.info("Received request {}".format(paramsString))
    params = json.loads(paramsString)
    response = {}
    try:
        status=params['status']
        key1=params['key1']
        key2=params['key2']
        userEmail = params['userEmail']

        autoExportRequestTable = dynamodb_client.Table(TABLENAME_AUTOEXPORT_USERS)
        autoExportRequestTable.update_item(
                            Key={
                                'UserID': key1,
                                'Dataset-DataProvider-Datatype': key2
                            },
                            UpdateExpression="set AutoExportStatus = :val",
                            ExpressionAttributeValues = {
                                ':val': status
                            },
                            ReturnValues="UPDATED_NEW"
                        )
        # Send notification to the analyst if their request is approved or rejected
        listOfPOC = []
        listOfPOC.append(userEmail)
        emailContent = "<br/>The Status of the Auto-Export Status Request made by you for the Dataset <b>" + key2 + "</b> has been changed to <b>" + params['status'] + "</b>. "
        if params['status'] == 'Approved':
            emailContent = emailContent + 'An SDC Admin will now assign auto-export permissions to your SDC account. Please wait to be contacted by an SDC Admin that your new permissions have been assigned before attempting to use auto-export.'
        send_notification(listOfPOC, emailContent, 'Auto-Export Request Response')

        # NEW
        if params['status'] == 'Approved':
            listOfPOC = [RECEIVER]
            emailContent = "<br/>Auto-Export status has been approved for <b>" + key1 + "</b> for the Dataset-DataProvider-Datatype <b>" + key2 + "</b>. Please perform next steps following this SOP: https://securedatacommons.atlassian.net/wiki/spaces/SD/pages/265519105/SOP+-+Assigning+S3+Auto-Export+IAM+Roles."
            send_notification(listOfPOC, emailContent, 'Auto-Export Action Required')

    except BaseException as be:
        logging.exception("Error: Failed to updateautoexportstatus" + str(be))
        raise ("Failed to updateautoexportstatus")

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