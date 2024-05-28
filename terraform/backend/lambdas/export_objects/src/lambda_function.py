import boto3
import json


def lambda_handler(event, context):
    content = set()
    user_id = ''
    params = event['queryStringParameters']
    print("USER_BUCKET == ", params['userBucketName'])
    try:
        client_s3 = boto3.client('s3')
        export_response = client_s3.list_objects(
            Bucket=params['userBucketName'],
            Prefix='export_requests/'
        )
        total_export_content = {}
        if 'Contents' in export_response:
            total_export_content = export_response['Contents']
        for c in total_export_content:
            content.add(c['Key'])
    except BaseException as ce:
        print(ce)
    return {'isBase64Encoded': False, 'statusCode':200, 'headers':{'Content-Type': 'text/plain'}, 'body':json.dumps(list(content))}
