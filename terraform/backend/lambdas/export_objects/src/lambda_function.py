# API which returns objects to populate the files a user wishes to export; this would show up in the My Resources section in the My Data table

import boto3
import json
import os

ALLOW_ORIGIN_URL = os.getenv("ALLOW_ORIGIN_URL")

def lambda_handler(event, context):
    content = set()
    user_id = ''
    params = event['queryStringParameters']
    print("USER_BUCKET == ", params['userBucketName'])
    try:
        client_s3 = boto3.client('s3')
        response = client_s3.list_objects(
            Bucket=params['userBucketName'],
            Prefix='{}/uploaded_files/'.format(params['username'])
        )
        export_response = client_s3.list_objects(
            Bucket=params['userBucketName'],
            Prefix='export_requests/'
        )
        total_content = {}
        total_export_content = {}
        if 'Contents' in export_response:
            total_export_content = export_response['Contents']
        if 'Contents' in response:
            total_content=response['Contents']
        for c in total_content:
            content.add(c['Key'])
        for c in total_export_content:
            content.add(c['Key'])

    except BaseException as ce:
        print(ce)
    
    return {
        'isBase64Encoded': False, 
        'statusCode':200,
        'headers':{
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Origin': ALLOW_ORIGIN_URL,
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET',
                'Content-Type': 'text/plain'
        }, 
        'body':json.dumps(list(content))
    }