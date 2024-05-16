import boto3
import logging


logger = logging.getLogger()


def lambda_handler(event, context):
    params = event['queryStringParameters']
    try:
        client_s3 = boto3.client('s3')
        location = params['bucket_name'].split('/', 1)
        response = client_s3.generate_presigned_url('put_object', Params={'Bucket': location[0], 'Key': '{}{}'.format(location[1], params['file_name']), 'ContentType': params['file_type'], 'Metadata': {'download':'true', 'export':'false', 'publish':'true'}}, ExpiresIn=3600, HttpMethod='PUT')
        logging.info("Response from pre-signed url - " + response)
    except BaseException as be:
        logging.exception("Error: Failed to generate presigned url" + str(be))
        raise ("Failed to get presigned url")
    return {'isBase64Encoded': False, 'statusCode':200, 'headers':{'Content-Type': 'text/plain'}, 'body':response}
    