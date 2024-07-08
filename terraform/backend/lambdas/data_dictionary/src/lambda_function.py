import boto3
import logging
import json

logger = logging.getLogger()

def lambda_handler(event, context):
    params = event['queryStringParameters']
    if not params or "readmepathkey" not in params or "readmebucket" not in params:
        logger.error("The query parameters 'readmepathkey' or 'readmebucket' is missing")
        raise ("The query parameters 'readmepathkey' or 'readmebucket' is missing")

    try:
        client_s3 = boto3.client('s3')
        response = client_s3.get_object(
        Bucket=params['readmebucket'],
        Key=params['readmepathkey']
        )
        data = response['Body'].read().decode('utf-8')
    except BaseException as be:
        logging.exception("Error: Failed to get data from s3 file" + str(be) )
        raise ("Internal error at server side")
    
    return {
        'isBase64Encoded': False, 
        'statusCode':200,
        'headers':{
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Origin': 'https://sub1.sdc-dev.dot.gov',
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET',
                'Content-Type': 'text/plain'
        }, 
        'body':json.dumps(data)
    }