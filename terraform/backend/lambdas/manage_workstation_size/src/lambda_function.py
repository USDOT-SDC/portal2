import logging
import simplejson as json
import boto3
from botocore.exceptions import ClientError, ParamValidationError
import time
from datetime import date, datetime
import os
from boto3.dynamodb.conditions import Key, Attr
import uuid
from urllib.parse import unquote

TABLENAME_MANAGE_USER_INDEX = os.getenv("TABLENAME_MANAGE_USER_INDEX")
TABLENAME_MANAGE_USER = os.getenv("TABLENAME_MANAGE_USER")
TABLENAME_USER_STACKS = os.getenv("TABLENAME_USER_STACKS")
ALLOW_ORIGIN_URL = os.getenv("ALLOW_ORIGIN_URL")


logger = logging.getLogger()
# logger.setLevel(logging.INFO)

def get_ec2_instance_state(params):
    instance_id = params['instance_id']
    if not instance_id:
        raise ValueError("Missing instance_id in params")
    ec2 = boto3.resource('ec2', region_name='us-east-1')
    instance = ec2.Instance(instance_id)
    return instance.state['Name']


def ec2_instance_stop(instance_id):
    logger.info("stopping instance_id: " + instance_id)  
    client = boto3.client('ec2',region_name='us-east-1')

    # Stop the instance
    client.stop_instances(InstanceIds=[instance_id])
    logger.info(f"Successfully initiated stop for instance {instance_id}")

def ec2_instance_start(params):
    instance_id = params['instance_id']
    if not instance_id:
        raise ValueError("Missing instance_id in params")
    logger.info("Starting instance_id: " + instance_id)
    client = boto3.client('ec2',region_name='us-east-1')

    # Start the instance
    try:
        client.start_instances(InstanceIds=[instance_id])
        logger.info(f"Successfully initiated start for instance {instance_id}")
    except ClientError as e:
        logger.error(e)


def modify_instance(instance_id, request_instance_type):
    logger.info("Modifying instance_id: " + instance_id + " to " + request_instance_type)  
    client = boto3.client('ec2',region_name='us-east-1')
    try:
        client.modify_instance_attribute(InstanceId=instance_id,Attribute='instanceType', Value=request_instance_type)
        logger.info(f"Successfully modified instance {instance_id}")
    except ClientError as e:
        print(e)   


def format_date(date_str):
    yyyy = date_str[0:4]
    mm = date_str[5:7]
    dd = date_str[8:10]
    formatted_date = f"{mm}/{dd}/{yyyy}"
    logger.debug(f"Formatted date: {date_str} to {formatted_date}")
    return formatted_date


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
        logger.info(f"Email sent to {email}. Message ID: {response['MessageId']}")
    # Display an error if something goes wrong.     
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        print("Email sent! Message ID:"),
        print(response['MessageId'])


def workstation_instance_request_notification(params):

    subject = 'SDC: New instance type for your workstation has been Scheduled'
    email = params['user_email']
    instance_type = params['requested_instance_type']
    schedule_from_date = format_date(params['workstation_schedule_from_date'])
    schedule_to_date = format_date(params['workstation_schedule_to_date'])

    BL0 = "Dear SDC User \r\n\n"
    BL1 = "You just requested " + instance_type + " instance type as your new workstation." 
    BL2 = "Your request has been scheduled from " + str(schedule_from_date) + " to " +  str(schedule_to_date) + ". "
    BL3 = "You will receive an email two days before your schedule expires."
    BL4 = "Please reach out to the SDC Support Team if you have any questions."
    BL5 = "\n\nThank you,\n SDC Support Team"

    body_text = (BL0 + "\r\n" + BL1 + "\n" + BL2 + "\n" + BL3 + "\n" + BL4 + BL5)
    manage_workstation_send_email(email,subject,body_text)


def resize_workstation(params):
    try:
        state=get_ec2_instance_state(params)
        instance_id = params['instance_id']
        requested_instance_type = params['requested_instance_type']
        logger.info(f"Instance {instance_id} current state: {state}")

        if state == "running":
           ec2_instance_stop(instance_id)
        while state != "stopped":
            time.sleep(5)
            state = get_ec2_instance_state(params)
            logger.debug(f"Waiting for instance {instance_id} to stop, current state: {state}")
        
        modify_instance(instance_id, requested_instance_type)
        ### send email
        workstation_instance_request_notification(params)
        logger.info(f"Successfully resized workstation {instance_id}")

    except ClientError as e:
        logging.exception("Error: Failed to insert record into Dynamo Db Table with exception - {}".format(e))


def insert_request_to_table(params):
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
    table = dynamodb.Table(TABLENAME_MANAGE_USER)

    username = params['username']
    instance_id = params['instance_id']
    resp = table.query(
    # Add the name of the index you want to use in your query.
    IndexName=TABLENAME_MANAGE_USER_INDEX,
    KeyConditionExpression=Key('username').eq(username),FilterExpression=Attr('instance_id').eq(instance_id))
    active = False
    for item in resp['Items']:
        reqID=item['RequestId']
        ###print(reqID)
        table.update_item(
            Key={
            'RequestId': reqID,
            'username': username
            },
            UpdateExpression='set is_active = :active',
            ExpressionAttributeValues={':active': active })

    try:
        request_date = str(datetime.now())
        table.put_item(
            Item={
                    'RequestId': str(uuid.uuid4()),
                    'username': params['username'],
                    'user_email': params['user_email'],
                    'instance_id': params['instance_id'],
                    'default_instance_type': params['default_instance_type'],
                    'requested_instance_type': params['requested_instance_type'],
                    'operating_system': params['operating_system'],
                    'request_date': request_date,
                    'schedule_from_date': params['workstation_schedule_from_date'],
                    'schedule_to_date': params['workstation_schedule_to_date'],
                    'is_active': True
                }
            )
        logger.info(f"Successfully inserted request for user {username}")
    except ClientError as e:
        logging.exception("Error: Failed to insert record into Dynamo Db Table with exception - {}".format(e))


def update_configuration_type_to_table(params):
    logger.info(params)
    vcpu = params['vcpu']
    memory = params['memory']
    instance_id = params['instance_id']
    username = params['username']
    current_configuration = "vCPUs:" + str(vcpu) + ",RAM(GiB):" + str(memory)
    current_instance_type = params['requested_instance_type']
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
    table = dynamodb.Table(TABLENAME_USER_STACKS)
    try:
        resp = table.query(KeyConditionExpression=Key('username').eq(username))

        map = -1
        map_num = -1
        for item in resp['Items']:
            for stack in (item['stacks']):
                map_num = map_num + 1
                if stack['instance_id'] == instance_id:
                    map = map_num
        if map == -1:
            print('Instance id ' + instance_id + ' not found in '+ TABLENAME_USER_STACKS)
            return -1
        table.update_item(
            Key={
            'username': username,
            },
            UpdateExpression='set stacks[' + str(map) + '].current_configuration = :conf,stacks[' + str(map) +'].current_instance_type = :type',
            ExpressionAttributeValues={
                ':conf': current_configuration,
                ':type': current_instance_type
            })
        logger.info(f"Successfully updated configuration for user {username}")
    except ClientError as e:
        logging.exception("Error: Failed to update record into Dynamo Db Table with exception - {}".format(e))


def user_requests_process(params):

    startAfterResize = params['startAfterResize']
    logger.info(f"Processing user request with startAfterResize: {startAfterResize}")

    resize_workstation(params)
    insert_request_to_table(params)
    update_configuration_type_to_table(params)

    if startAfterResize:
        state = get_ec2_instance_state(params)
        if state != "running":
         ec2_instance_start(params)
    
    logger.info("Successfully processed user request")


def lambda_handler(event, context):
    try:
        logger.setLevel("INFO")
        paramsString = unquote(event['queryStringParameters']['wsrequest'])
        logging.info("Received request {}".format(paramsString))

        # String concat necessary as currently curly braces can't be passed in AWS through a URL
        params = json.loads("{" + paramsString + "}")
        response = {}
        # this is necessary since .get only inserts a default value if the key is absent, not if the value is None
        if not params.get("workstation_schedule_to_date", None): 
            params["workstation_schedule_to_date"] = "2099-12-31"       
            
        user_requests_process(params)
    except BaseException as be:
        logging.exception("Error: Failed to process export request" + str(be))
        raise ("Failed to process export request")

    return {
        'isBase64Encoded': False, 
        'statusCode':200,
        'headers':{
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Origin': ALLOW_ORIGIN_URL,
                'Access-Control-Allow-Methods': 'OPTIONS,GET',
                'Content-Type': 'text/plain'
        }, 
        'body':json.dumps(response)
    }