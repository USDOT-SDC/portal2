import boto3
import simplejson as json
import os
import logging


TABLENAME_TRUSTED_USERS = os.getenv("TABLENAME_TRUSTED_USERS")
RECEIVER = os.getenv("RECEIVER_EMAIL")

logger = logging.getLogger()
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
    paramsQuery = event['queryStringParameters']
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

        trustedRequestTable = dynamodb_client.Table(TABLENAME_TRUSTED_USERS)
        trustedRequestTable.update_item(
                            Key={
                                'UserID': key1,
                                'Dataset-DataProvider-Datatype': key2
                            },
                            UpdateExpression="set TrustedStatus = :val",
                            ExpressionAttributeValues = {
                                ':val': status
                            },
                            ReturnValues="UPDATED_NEW"
                        )
        # Send notification to the analyst if his request is approved or rejected
        listOfPOC = []
        listOfPOC.append(userEmail)
        emailContent = "<br/>The Status of the Trusted Status Request made by you for the Dataset <b>" + key2 + "</b> has been changed to <b>" + params['status'] + "</b>"
        send_notification(listOfPOC, emailContent)

    except BaseException as be:
        logging.exception("Error: Failed to updatetrustedtatus" + str(be))
        raise ("Failed to updatetrustedtatus")

    return {'isBase64Encoded': False, 'statusCode':200, 'headers':{'Content-Type': 'text/plain'}, 'body': json.dumps(response)}
