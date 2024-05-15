import logging
import json
import boto3
import time
from datetime import datetime, date 
import os
from boto3.dynamodb.conditions import Key, Attr
import uuid


TABLENAME_MANAGE_UPTIME = os.getenv("TABLENAME_MANAGE_UPTIME")
TABLENAME_MANAGE_UPTIME_INDEX = os.getenv("TABLENAME_MANAGE_UPTIME_INDEX")


logger = logging.getLogger()


def get_ec2_instance_state(params):
    instance_id = params['instance_id']
    ec2 = boto3.resource('ec2', region_name='us-east-1')
    instance = ec2.Instance(instance_id)
    return instance.state['Name']


def ec2_instance_start(params):
    instance_id = params['instance_id']
    print("Starting instance_id: " + instance_id)
    client = boto3.client('ec2',region_name='us-east-1')

    # Start the instance
    try:
        client.start_instances(InstanceIds=[instance_id])
    except ClientError as e:
        print(e)


def manage_workstation_send_email(email,subject,body_text):
    SENDER = "SDC Support <sdc-support@dot.gov>"
    RECIPIENT = email
    AWS_REGION = "us-east-1"

    # The subject line for the email.
    SUBJECT = subject
    # The email body for recipients with non-HTML email clients.
    BODY_TEXT = body_text

    # The character encoding for the email.
    CHARSET = "UTF-8"

    # Create a new SES resource and specify a region.
    client = boto3.client('ses',region_name=AWS_REGION)

    # Try to send the email.
    try: #Provide the contents of the email.
        response = client.send_email(
            Destination={
                'ToAddresses': [
                    RECIPIENT,
                ],
            },
            Message={
                'Body': {
                    'Text': {
                        'Charset': CHARSET,
                        'Data': BODY_TEXT,
                    },
                },
                'Subject': {
                    'Charset': CHARSET,
                    'Data': SUBJECT,
                },
            },
            Source=SENDER,
        )
    # Display an error if something goes wrong.     
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        print("Email sent! Message ID:"),
        print(response['MessageId'])

def format_date(date):
    yyyy = date[0:4]
    mm = date[5:7]
    dd = date[8:10]
    formated_date = str(mm)+'/'+str(dd)+'/'+str(yyyy)
    return formated_date


def workstation_uptime_request_notification(params):

    subject = 'SDC: New workstation uptime has been Scheduled'
    email = params['user_email']
    schedule_from_date = format_date(params['uptime_schedule_from_date'])
    schedule_to_date = format_date(params['uptime_schedule_to_date'])

    BL0 = "Dear SDC User \r\n\n"
    BL1 = "Your request for a new uptime for your workstation has been scheduled." 
    BL2 = "Your request has been scheduled from " + str(schedule_from_date) + " to " +  str(schedule_to_date) + ". "
    BL3 = "You will receive an email two days before your schedule expires."
    BL4 = "Please reach out to the SDC Support Team if you have any questions."
    BL5 = "\n\nThank you,\n SDC Support Team"

    body_text = (BL0 + "\r\n" + BL1 + "\n" + BL2 + "\n" + BL3 + "\n" + BL4 + BL5)
    manage_workstation_send_email(email,subject,body_text)


def insert_schedule_uptime_to_table(params):
    instance_id = params['instance_id']
    ec2 = boto3.resource('ec2', region_name='us-east-1')
    ec2.create_tags(Resources=[instance_id], Tags=[{'Key':'Action', 'Value':'KeepRunning'}])
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
    table = dynamodb.Table(TABLENAME_MANAGE_UPTIME)

    username = params['username']
    instance_id = params['instance_id']
    resp = table.query(
        IndexName=TABLENAME_MANAGE_UPTIME_INDEX,
        KeyConditionExpression=Key('username').eq(username),
        FilterExpression=Attr('instance_id').eq(instance_id)
        )
    active = False
    for item in resp['Items']:
        reqID=item['RequestId']
    ###   print(reqID)
        table.update_item(
        Key={
        'RequestId': reqID,
        'username': username
        },
        UpdateExpression='set is_active = :active',
        ExpressionAttributeValues={':active': active })

    try:
        request_date = datetime.now()
        request_date = str(request_date)
        table.put_item(
            Item={
                    'RequestId': str(uuid.uuid4()),
                    'username': params['username'],
                    'user_email': params['user_email'],
                    'instance_id': params['instance_id'],
                    'operating_system': params['operating_system'],
                    'request_date': request_date,
                    'schedule_from_date': params['uptime_schedule_from_date'],
                    'schedule_to_date': params['uptime_schedule_to_date'],
                    'is_active': True
                }
            )
        workstation_uptime_request_notification(params)
    except ClientError as e:
        logging.exception("Error: Failed to insert record into Dynamo Db Table with exception - {}".format(e))


def user_requests_process(params):
    startAfterResize = params['startAfterResize']
    print(startAfterResize)
    insert_schedule_uptime_to_table(params)
    if startAfterResize == True:
        state=get_ec2_instance_state(params)
        if state != "running":
         ec2_instance_start(params)


def lambda_handler(event, context):
    paramsQuery = event['queryStringParameters']
    paramsString = paramsQuery['wsrequest']
    logger.setLevel("INFO")
    logging.info("Received request {}".format(paramsString))
    params = json.loads(paramsString)
    response = {}
    try:
        user_requests_process(params)
    except BaseException as be:
        logging.exception("Error: Failed to process export request" + str(be))
        raise ("Failed to process export request")

    return {'isBase64Encoded': False, 'statusCode':200, 'headers':{'Content-Type': 'application/json'}, 'body':response}
