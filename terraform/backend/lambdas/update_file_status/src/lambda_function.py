import boto3
import json


TABLENAME_EXPORT_FILE_REQUEST = os.getenv("TABLENAME_EXPORT_FILE_REQUEST")
RECEIVER = os.getenv("RECEIVER_EMAIL")

logger = logging.getLogger()
dynamodb_client = boto3.resource('dynamodb')


def send_notification(listOfPOC, emailContent, subject = 'Export Notification'):
    ses_client = boto3.client('ses')
    sender = RECEIVER
    try:
        response = ses_client.send_email(
            Destination={
                'BccAddresses': [
                ],
                'CcAddresses': [
                ],
                'ToAddresses': listOfPOC,
            },
            Message={
                'Body': {
                    'Html': {
                        'Charset': 'UTF-8',
                        'Data': emailContent,
                    },
                    'Text': {
                        'Charset': 'UTF-8',
                        'Data': 'This is the notification message body in text format.',
                    },
                },
                'Subject': {
                    'Charset': 'UTF-8',
                    'Data': subject,
                },
            },
            Source=sender
        )
    except BaseException as ke:
        logging.exception("Failed to send notification "+ str(ke))
        raise NotFoundError("Failed to send notification")


def lambda_handler(event, context):
    paramsQuery = event['queryStringParameters']
    paramsString = paramsQuery['message']
    logger.setLevel("INFO")
    logging.info("Received request {}".format(paramsString))
    params = json.loads(paramsString)
    response = {}
    try:
        status=params['status']
        s3KeyHash=params['key1']
        requestedBy_Epoch=params['key2']
        datainfo = params['datainfo']
        userEmail = params['userEmail']
        exportFileRequestTable = dynamodb_client.Table(TABLENAME_EXPORT_FILE_REQUEST)

        kwargs = {
        'FilterExpression': Attr('RequestType').eq('Table') & Attr('RequestReviewStatus').eq('Approved') & Attr('S3KeyHash').eq(s3KeyHash) # Filter Expression for DynamoDB Scan. Get entries where status = 'approved'
        }
        table_requests = scan_db(TABLENAME_EXPORT_FILE_REQUEST, kwargs)
        for request in table_requests:
            exportFileRequestTable.update_item(
                Key={
                    'S3KeyHash': request['S3KeyHash'],
                    'RequestedBy_Epoch': request['RequestedBy_Epoch']
                },
                UpdateExpression="set RequestReviewStatus = :val",
                ExpressionAttributeValues = {
                    ':val': 'Rejected'
                },
                ReturnValues="UPDATED_NEW"
            )
        
        # exportFileRequestTable = dynamodb_client.Table(TABLENAME_EXPORT_FILE_REQUEST)
        exportFileRequestTable.update_item(
            Key={
                'S3KeyHash': s3KeyHash,
                'RequestedBy_Epoch': requestedBy_Epoch
            },
            UpdateExpression="set RequestReviewStatus = :val",
            ExpressionAttributeValues = {
                ':val': status
            },
            ReturnValues="UPDATED_NEW"
        )
        
                
        emailContent = ''
        if 'TeamBucket' in params.keys():
            download = 'false'
            export = 'true'
            publish = 'false'
            metadata = {'download': download, 'export': export, 'publish': publish}

            if status == "Approved":
                download = 'true'
                publish = 'true'
                export = 'false'
                metadata = {'download': download, 'export': export, 'publish': publish}
            elif status == "TrustedApproved":
                metadata = {'download': download, 'export': export, 'publish': publish , datainfo : 'true'}

            logging.info(metadata)
            logging.info(params)

            s3 = boto3.resource('s3')
            s3_object = s3.Object(params['TeamBucket'], params['S3Key'])
            #s3_object.metadata.update(metadata)
            s3_object.copy_from(CopySource={'Bucket': params['TeamBucket'], 'Key': params['S3Key']},
                                Metadata=metadata,
                                MetadataDirective='REPLACE')
            emailContent = "<br/>The Status of the Export Request made by you for the file <b>" + params['S3Key'] + "</b> has been changed to <b>" + params['status'] + "</b>"
        if 'TableName' in params.keys():
            emailContent = "<br/>The Status of the Table Export Request made by you for the table <b>" + params['TableName'] + "</b> has been changed to <b>" + params['status'] + "</b>"

        # Send notification to the analyst if his request is approved or rejected
        listOfPOC = []
        listOfPOC.append(userEmail)
        send_notification(listOfPOC, emailContent)

    except BaseException as be:
        logging.exception("Error: Failed to updatefilestatus" + str(be))
        raise ChaliceViewError("Failed to updatefilestatus")

    return {'isBase64Encoded': False, 'statusCode':200, 'headers':{'Content-Type': 'text/plain'}, 'body': response}
