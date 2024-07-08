import logging
import json
import boto3
import time
import date, datetime


TABLENAME_MANAGE_USER_INDEX = os.getenv("TABLENAME_MANAGE_USER_INDEX")
TABLENAME_USER_STACKS = os.getenv("TABLENAME_USER_STACKS")
TABLENAME_MANAGE_DISK = os.getenv("TABLENAME_MANAGE_DISK")

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


def ec2_instance_availability_zone(instance_id):
    client = boto3.client('ec2')
    responses = client.describe_instances(InstanceIds=[instance_id])
    for response in responses["Reservations"]:
        for instance in response["Instances"]:
            availability_zone = instance["Placement"]["AvailabilityZone"]
            return availability_zone


def ec2_instance_platform(instance_id):
    ec2 = boto3.resource('ec2')
    instance = ec2.Instance(instance_id)
    return instance.platform


def create_ebs_volume(instance_id,platform,zone,size):
    tag = str(platform) + str(instance_id)
    client = boto3.client('ec2',region_name='us-east-1')
    ec2 = boto3.resource('ec2', region_name='us-east-1')
    volume = ec2.create_volume(
        AvailabilityZone=zone,
        Encrypted=True,
        Size=size,
        VolumeType='gp2',
        TagSpecifications=[
            {
            'ResourceType': 'volume',
            'Tags': [
                {
                'Key': 'Name',
                'Value': tag
                },
            ]
            },
        ]
    )
    print(volume)
    V = str(volume)
    vol,vol1 = V.split("=", 1)
    vol = vol1.replace('\'','')
    volume = vol.replace(')','')
    client.get_waiter('volume_available').wait(VolumeIds=[volume])
    return volume


def insert_disk_request_to_table(params,volume_id,size):
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
    table = dynamodb.Table(TABLENAME_MANAGE_DISK)
    username = params['username']
    instance_id = params['instance_id']
    resp = table.query(
    # Add the name of the index you want to use in your query.
    IndexName=TABLENAME_MANAGE_DISK_INDEX,
    KeyConditionExpression=Key('username').eq(username),FilterExpression=Attr('instance_id').eq(instance_id))
    active = False
    for item in resp['Items']:
        reqID=item['RequestId']
        #### print(reqID)
        table.update_item(
            Key={
            'RequestId': reqID,
            'username': username
            },
            UpdateExpression='set is_active = :active',
            ExpressionAttributeValues={':active': active })

    try:
        request_date = datetime.datetime.now()
        request_date = str(request_date)
        table.put_item(
            Item={
                    'RequestId': str(uuid.uuid4()),
                    'username': params['username'],
                    'user_email': params['user_email'],
                    'instance_id': params['instance_id'],
                    'default_instance_type': params['default_instance_type'],
                    'requested_instance_type': params['default_instance_type'],
                    'operating_system': params['operating_system'],
                    'request_date': request_date,
                    'schedule_from_date': params['diskspace_schedule_from_date'],
                    'schedule_to_date': params['diskspace_schedule_to_date'],
                    'volume_id': volume_id,
                    'volume_size': size,
                    'is_active': True
                }
            )
    except ClientError as e:
        logging.exception("Error: Failed to insert record into Dynamo Db Table with exception - {}".format(e))


def update_volume_number_to_table(params,vol_number):
    instance_id = params['instance_id']
    username = params['username']
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
    table = dynamodb.Table(TABLENAME_USER_STACKS)
    str_vol_number = str(vol_number)
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
            UpdateExpression='SET stacks[' + str(map) +'].volumes = :volumes',
            ExpressionAttributeValues={':volumes': str_vol_number })
    except ClientError as e:
        logging.exception("Error: Failed to update record into Dynamo Db Table with exception - {}".format(e))


def ssm_ec2_instance_windows(instance_id):
    print("Initializing disk2 on instance_id: " + instance_id)
    ssm = boto3.client('ssm',region_name='us-east-1' )
    try:
        response = ssm.send_command( InstanceIds=[instance_id],
        DocumentName='AWS-RunPowerShellScript',
        Parameters={ "commands":[ """Get-Disk | Where partitionstyle -eq ‘raw’ |
                                 Initialize-Disk -PartitionStyle MBR -PassThru |
                                 New-Partition -AssignDriveLetter -UseMaximumSize |
                                 Format-Volume -FileSystem NTFS -NewFileSystemLabel “disk2” -Confirm:$false""" ]  },
                                 MaxErrors='20' )
    except Exception as e:
        logging.error("send command error: {0}".format(e))
        raise e
    command_id = response['Command']['CommandId']
    print('command ID',command_id)
    print(response)


def ssm_ec2_instance_linux(instance_id):
    print("EBS mounting on instance_id: " + instance_id)
    ssm = boto3.client('ssm',region_name='us-east-1' )
    response = ssm.send_command( InstanceIds=[instance_id],
    DocumentName='AWS-RunShellScript',
    Parameters={ "commands":[ """lsblk;
    sudo mkfs -t ext4 /dev/xvdb
    cd /
    mkdir -p /data1
    sudo mount /dev/xvdb  /data1/
    cat /etc/fstab | grep data1
    if [ $? -ne 0 ]; then
    echo "/dev/xvdb       /data1/   ext4    defaults,nofail  0   0" >> /etc/fstab
    fi
    """
    ]  },MaxErrors='20' )
    command_id = response['Command']['CommandId']
    print('Run command id',command_id)
    #print(response)


def workstation_diskspace_request_notification(params):

    subject = 'SDC: New diskspace on your workstation has been Scheduled'
    email = params['user_email']
    size = params['required_diskspace']
    schedule_from_date = format_date(params['diskspace_schedule_from_date'])
    schedule_to_date = format_date(params['diskspace_schedule_to_date'])

    BL0 = "Dear SDC User \r\n\n"
    BL1 = "You just requested  " + str(size) + "Gib of new disk storage for your workstation." 
    BL2 = "Your request has been scheduled from " + str(schedule_from_date) + " to " +  str(schedule_to_date) + ". "
    BL3 = "You will receive an email two days before your schedule expires."
    BL4 = "Please reach out to the SDC Support Team if you have any questions."
    BL5 = "\n\nThank you,\n SDC Support Team"

    body_text = (BL0 + "\r\n" + BL1 + "\n" + BL2 + "\n" + BL3 + "\n" + BL4 + BL5)
    manage_workstation_send_email(email,subject,body_text)


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


def number_of_ec2_volumes(instance_id):
    i = 0
    ec2 = boto3.resource('ec2', region_name='us-east-1')
    instance = ec2.Instance(instance_id)
    volumes = instance.volumes.all()
    for v in volumes:
        i = i + 1
    return i


def attach_ebs_volume(params):
    instance_id = params['instance_id']
    size = int(params['required_diskspace'])
    ### check if instance has more than one volumes
    vol_number=number_of_ec2_volumes(instance_id)
    if vol_number > 1:
        print("Instance " + instance_id + " " + " has " + str(vol_number) + " volumes already")
        return vol_number
    vol_number = vol_number + 1
    client = boto3.client('ec2',region_name='us-east-1')
    state=get_ec2_instance_state(params)
    print('ret: ',state)
    if state != 'running':
        ec2_instance_start(params)
    zone=ec2_instance_availability_zone(instance_id)
    print(zone)
    platform=ec2_instance_platform(instance_id)
    if platform != 'windows':
        platform = 'linux'
    print(platform)
    ### create and get volume_id
    volume_id=create_ebs_volume(instance_id,platform,zone,size)
    response = client.attach_volume(
        Device='/dev/sdb',
        InstanceId=instance_id,
        VolumeId=volume_id)
    waiter = client.get_waiter('volume_in_use')
    waiter.wait(VolumeIds=[volume_id])
    ###
    ###time.sleep(5)
    print('inserting volume_id to DB')
    insert_disk_request_to_table(params,volume_id,size)
    update_volume_number_to_table(params,vol_number)
    #### format volume or mount
    state=get_ec2_instance_state(params)
    print('debug: ',state)
    if platform == 'windows':
        ssm_ec2_instance_windows(instance_id)
    if platform == 'linux':
        ssm_ec2_instance_linux(instance_id)
    ### send mail here
    workstation_diskspace_request_notification(params)
    return response


def user_requests_process(params):
    manageDiskspace = params['manageDiskspace']
    startAfterResize = params['startAfterResize']
    print(manageDiskspace)
    print(startAfterResize)
    response=attach_ebs_volume(params)
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
                'Access-Control-Allow-Origin': 'https://sub1.sdc-dev.dot.gov',
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET',
                'Content-Type': 'application/json'
        }, 
        'body':response
    }