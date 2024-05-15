import boto3
import logging
import os
from boto3.dynamodb.conditions import Key, Attr


TABLENAME_EXPORT_FILE_REQUEST = os.getenv("TABLENAME_EXPORT_FILE_REQUEST")

logger = logging.getLogger()
dynamodb_client = boto3.resource('dynamodb')


def lambda_handler(event, context):
    params = event['queryStringParameters']
    logger.setLevel("INFO")
    logging.info("Params - " + params['bucket_name'])
    logging.info("Params filename- " + params['file_name'])

    try:
        client_s3 = boto3.client('s3')
        response = client_s3.get_object(Bucket=params['bucket_name'],Key=params['file_name'])
        response = client_s3.head_object(Bucket=params['bucket_name'], Key=params['file_name'])
        logging.info("S3 object metadata response - " + str(response["Metadata"]))
        print("response == ", response)

        eTag = response['ETag']


        exportFileRequestTable = dynamodb_client.Table(TABLENAME_EXPORT_FILE_REQUEST)

        exportFileRequestResponse = exportFileRequestTable.scan(
            Select= 'ALL_ATTRIBUTES',
            FilterExpression=Attr('S3Key').eq(params['file_name'])
        )
        if exportFileRequestResponse['Items']:
            sorted_items = sorted(exportFileRequestResponse['Items'], key=lambda x: x['ReqReceivedTimestamp'], reverse=True)
            if sorted_items:
                print(str(eTag) + "  <-- tags -->  " + str(sorted_items[0]["S3KeyHash"]))


        if exportFileRequestResponse['Items'] and str(eTag) == str(sorted_items[0]["S3KeyHash"]):
            
            response["Metadata"]["requestReviewStatus"] = sorted_items[0]["RequestReviewStatus"]
        elif exportFileRequestResponse['Items'] and not str(eTag) == str(sorted_items[0]["S3KeyHash"]):
            return Response(body={'download': 'false', 'export': 'true', 'publish': 'false', 'requestReviewStatus': "-1"},
                    status_code=200,
                    headers={'Content-Type': 'text/plain'})
        else: 
            response["Metadata"]["requestReviewStatus"] = "-1"
        

    except BaseException as be:
        logging.exception("Error: Failed to get S3 metadata" + str(be))
        raise ("Failed to get s3 metadata")

    print("Response == ", response)
    return {'isBase64Encoded': False, 'statusCode':200, 'headers':{'Content-Type': 'text/plain'}, 'body':response["Metadata"]}
