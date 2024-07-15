import logging
import simplejson as json
import boto3
import time
from datetime import date, datetime
import os
from boto3.dynamodb.conditions import Key, Attr
import uuid


TABLENAME_MANAGE_USER_INDEX = os.getenv("TABLENAME_MANAGE_USER_INDEX")
TABLENAME_MANAGE_USER = os.getenv("TABLENAME_MANAGE_USER")
TABLENAME_USER_STACKS = os.getenv("TABLENAME_USER_STACKS")
ALLOW_ORIGIN_URL = os.getenv("ALLOW_ORIGIN_URL")


logger = logging.getLogger()


def get_ec2_instance_state(params):
    instance_id = params['instance_id']
    ec2 = boto3.resource('ec2', region_name='us-east-1')
    instance = ec2.Instance(instance_id)
    return instance.state['Name']


def ec2_instance_stop(instance_id):
    print("stopping instance_id: " + instance_id)  
    client = boto3.client('ec2',region_name='us-east-1')

    # Stop the instance
    client.stop_instances(InstanceIds=[instance_id])


def ec2_instance_start(params):
    instance_id = params['instance_id']
    print("Starting instance_id: " + instance_id)
    client = boto3.client('ec2',region_name='us-east-1')

    # Start the instance
    try:
        client.start_instances(InstanceIds=[instance_id])
    except ClientError as e:
        print(e)


def modify_instance(instance_id, request_instance_type):
    print("Modifying instance_id: " + instance_id + " to " + request_instance_type)  
    client = boto3.client('ec2',region_name='us-east-1')
    try:
        client.modify_instance_attribute(InstanceId=instance_id,Attribute='instanceType', Value=request_instance_type)
    except ClientError as e:
        print(e)   


def format_date(date):
    yyyy = date[0:4]
    mm = date[5:7]
    dd = date[8:10]
    formated_date = str(mm)+'/'+str(dd)+'/'+str(yyyy)
    return formated_date


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
        print(state)
        if state == "running":
           ec2_instance_stop(instance_id)
        while state != "stopped":
            state=get_ec2_instance_state(params)  
        else: 
            modify_instance(instance_id, requested_instance_type)
            time.sleep(5)
        ### send email
        workstation_instance_request_notification(params)

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
        request_date = datetime.now()
        request_date = str(request_date)
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
    except ClientError as e:
        logging.exception("Error: Failed to insert record into Dynamo Db Table with exception - {}".format(e))


def update_configuration_type_to_table(params):
    print(params)
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
    except ClientError as e:
        logging.exception("Error: Failed to update record into Dynamo Db Table with exception - {}".format(e))


def user_requests_process(params):
    startAfterResize = params['startAfterResize']
    print(startAfterResize)
    resize_workstation(params)
    insert_request_to_table(params)
    update_configuration_type_to_table(params)
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

    return {
        'isBase64Encoded': False, 
        'statusCode':200,
        'headers':{
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Origin': ALLOW_ORIGIN_URL,
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET',
                'Content-Type': 'application/json'
        }, 
        'body':json.dumps(response)
    }