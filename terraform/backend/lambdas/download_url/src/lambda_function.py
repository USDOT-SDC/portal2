import boto3
import logging


def lambda_handler(event, context):
    params = event['queryStringParameters']
    try:
        client_s3 = boto3.client('s3')
        response = client_s3.generate_presigned_url('get_object', Params={'Bucket': params['bucket_name'], 'Key': params['file_name']}, ExpiresIn=600, HttpMethod='GET')
        logging.info("Response from pre-signed url - " + response)
    except BaseException as be:
        logging.exception("Error: Failed to generate presigned url" + str(be))
        raise ("Failed to get presigned url")
    return {'isBase64Encoded': False, 'statusCode':200, 'headers':{'Content-Type': 'text/plain'}, 'body':response}
