import boto3
import logging
import os
import simplejson as json
from urllib.parse import unquote


RECEIVER = os.getenv("RECEIVER_EMAIL")
ALLOW_ORIGIN_URL = os.getenv("ALLOW_ORIGIN_URL")


logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    ses_client = boto3.client('ses')

    try:
        message = unquote(event['queryStringParameters']['message'])
        logger.info(f"Recipient: {unquote(event['queryStringParameters']['recipient'])}")
        recipient = json.loads(unquote(event['queryStringParameters']['recipient'])) if 'recipient' in event['queryStringParameters'] else [[RECEIVER]]
        sender = RECEIVER
        all_recipients = set(email for emails in recipient for email in emails)

        # testing:
        logger.info(all_recipients)
        # all_recipients = set(["nathaniel.martin.ctr@dot.gov"])

    except KeyError as ke:
        raise KeyError(f"One or more fields is missing: {ke}")
    except BaseException as be:
        logging.exception(f"Failed as {be}")

    try:
        response = ses_client.send_email(
            Destination={
                'BccAddresses': [
                ],
                'CcAddresses': [
                ],
                'ToAddresses': list(all_recipients),
            },
            Message={
                'Body': {
                    'Html': {
                        'Charset': 'UTF-8',
                        'Data': message,
                    },
                    'Text': {
                        'Charset': 'UTF-8',
                        'Data': 'This is the message body in text format.',
                    },
                },
                'Subject': {
                    'Charset': 'UTF-8',
                    'Data': 'Request email',
                },
            },
            Source=sender
        )
    except BaseException as ke:
        logging.exception("Failed to send email "+ str(ke) )
        raise Exception("Failed to send email")
    
    return {
        'isBase64Encoded': False, 
        'statusCode':200,
        'headers':{
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Origin':  ALLOW_ORIGIN_URL,
                'Access-Control-Allow-Methods': 'OPTIONS,POST',
                'Content-Type': 'text/plain'
        },
        'body': json.dumps("email sent")
    }
