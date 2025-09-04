import boto3
import logging
import os
import simplejson as json
from urllib.parse import unquote


RECEIVER = os.getenv("RECEIVER_EMAIL")
ALLOW_ORIGIN_URL = os.getenv("ALLOW_ORIGIN_URL")


logger = logging.getLogger()


def lambda_handler(event, context):
    ses_client = boto3.client('ses')

    params = json.loads(unquote(event['body']))
    if not params or "sender" not in params or "message" not in params:
        logger.error("The query parameters 'sender' or 'message' is missing")
        raise BadRequestError("The query parameters 'sender' or 'message' is missing")
    sender = RECEIVER
    message = params['message']
    # other_recipient = set(email_addr for group in params.get("recipient", [[""]]) for email_addr in group)
    # all_recipients = other_recipient.add(sender)
    all_recipients = set(email for email in params.get("recipient", []) if len(email)==1)

    # testing:
    logger.info(all_recipients)

    all_recipients = set(["nathaniel.martin.ctr@dot.gov"])

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
        raise NotFoundError("Failed to send email")
    
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
