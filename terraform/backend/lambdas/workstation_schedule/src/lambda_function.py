import boto3
import logging
import json
import os
from boto3.dynamodb.conditions import Key, Attr



TABLENAME_MANAGE_DISK = os.getenv("TABLENAME_MANAGE_DISK")
TABLENAME_MANAGE_DISK_INDEX = os.getenv("TABLENAME_MANAGE_DISK_INDEX")
TABLENAME_MANAGE_USER = os.getenv("TABLENAME_MANAGE_USER")
TABLENAME_MANAGE_USER_INDEX = os.getenv("TABLENAME_MANAGE_USER_INDEX")
TABLENAME_MANAGE_UPTIME = os.getenv("TABLENAME_MANAGE_UPTIME")
TABLENAME_MANAGE_UPTIME_INDEX = os.getenv("TABLENAME_MANAGE_UPTIME_INDEX")


logger = logging.getLogger()


def format_date(date):
    yyyy = date[0:4]
    mm = date[5:7]
    dd = date[8:10]
    formated_date = str(mm)+'/'+str(dd)+'/'+str(yyyy)
    return formated_date


def lambda_handler(event, context):
    paramsQuery = event['queryStringParameters']
    paramsString = paramsQuery['wsrequest']
    logger.setLevel("INFO")
    logging.info("Received request {}".format(paramsString))
    params = json.loads(paramsString)
    username = params['username']
    instance_id = params['instance_id']
    print(username)
    workstation_schedule = {}
    workstation_schedule['schedulelist'] = []
    dynamodb = boto3.resource('dynamodb',region_name='us-east-1')

    table = dynamodb.Table(TABLENAME_MANAGE_DISK)
    resp = table.query(
    IndexName=TABLENAME_MANAGE_DISK_INDEX,
    KeyConditionExpression=Key('username').eq(username),FilterExpression=Attr('is_active').eq(True) & Attr('instance_id').eq(instance_id))

    for item in resp['Items']:
        info = {"diskspace_instance_id" : instance_id, "diskspace_schedule_from_date" : format_date(item['schedule_from_date']),"diskspace_schedule_to_date" : format_date(item['schedule_to_date'])}
        workstation_schedule['schedulelist'].append(info)

    table = dynamodb.Table(TABLENAME_MANAGE_USER)
    resp = table.query(
        IndexName=TABLENAME_MANAGE_USER_INDEX,
        KeyConditionExpression=Key('username').eq(username),FilterExpression=Attr('is_active').eq(True) & Attr('instance_id').eq(instance_id))

    for item in resp['Items']:
        info = {"workstation_instnace_id" : instance_id,"workstation_schedule_from_date" : format_date(item['schedule_from_date']),"workstation_schedule_to_date" : format_date(item['schedule_to_date'])}
        workstation_schedule['schedulelist'].append(info)

    table = dynamodb.Table(TABLENAME_MANAGE_UPTIME)
    resp = table.query(
        IndexName=TABLENAME_MANAGE_UPTIME_INDEX,
        KeyConditionExpression=Key('username').eq(username),FilterExpression=Attr('is_active').eq(True) & Attr('instance_id').eq(instance_id))

    for item in resp['Items']:
        info = {"uptime_instnace_id" : instance_id,"uptime_schedule_from_date" : format_date(item['schedule_from_date']),"uptime_schedule_to_date" : format_date(item['schedule_to_date'])}
        workstation_schedule['schedulelist'].append(info)
    return workstation_schedule
