import boto3
from boto3.dynamodb.conditions import Attr, Key
import logging
import simplejson as json
import time
import os


TABLENAME_AVAILABLE_DATASET = os.getenv("TABLENAME_AVAILABLE_DATASET")
TABLENAME_TRUSTED_USERS = os.getenv("TABLENAME_TRUSTED_USERS")
TABLENAME_AUTOEXPORT_USERS = os.getenv("TABLENAME_AUTOEXPORT_USERS")
TABLENAME_EXPORT_FILE_REQUEST = os.getenv("TABLENAME_EXPORT_FILE_REQUEST")

logger = logging.getLogger()
dynamodb_client = boto3.resource('dynamodb')

def get_datasets():
    try:
        table = dynamodb_client.Table(TABLENAME_AVAILABLE_DATASET)
        response = table.scan(TableName=TABLENAME_AVAILABLE_DATASET)
        return { 'datasets' : response }
    except BaseException as be:
        logging.exception("Error: Failed to get dataset" + str(be) )
        raise ("Internal error occurred! Contact your administrator.")


def get_combined_export_workflow():
    availableDatasets = get_datasets()['datasets']['Items']
    combinedExportWorkflow = {}
    for dataset in availableDatasets:
        if 'exportWorkflow' in dataset:
            combinedExportWorkflow.update(dataset['exportWorkflow'])
    return combinedExportWorkflow


def lambda_handler(event, context):
    paramsQuery = event['queryStringParameters']
    paramsString = paramsQuery['message']
    logger.setLevel("INFO")
    logging.info("Received request {}".format(paramsString))
    params = json.loads(paramsString)

    useremail = params['ApprovalForm']['email']
    userdatasets = []
    response = {"exportRequests": {"tableRequests":[], "s3Requests":[]}, "trustedRequests": [], "autoExportRequests": []}
    try:
        combinedExportWorkflow = get_combined_export_workflow()

        for dataset in combinedExportWorkflow:
            for dataprovider in combinedExportWorkflow[dataset]:
                listOfPOC = combinedExportWorkflow[dataset][dataprovider]['ListOfPOC']
                if listOfPOC and useremail in listOfPOC:
                    for datatype in combinedExportWorkflow[dataset][dataprovider]['datatypes']:
                        userdatasets.append(dataset + "-" + dataprovider + "-" + datatype)

        #Query all submitted requests for the selected datatype
        exportFileRequestTable = dynamodb_client.Table(TABLENAME_EXPORT_FILE_REQUEST)
        trustedRequestTable = dynamodb_client.Table(TABLENAME_TRUSTED_USERS)
        autoExportRequestTable = dynamodb_client.Table(TABLENAME_AUTOEXPORT_USERS)
        for userdataset in userdatasets:
            logging.info("Dataset: " + userdataset)
            # Data File Request query
            exportFileRequestResponse = exportFileRequestTable.query(
                IndexName='DataInfo-ReqReceivedtimestamp-index',
                KeyConditionExpression=Key('Dataset-DataProvider-Datatype').eq(userdataset))
            if exportFileRequestResponse['Items']:
                for entry in exportFileRequestResponse['Items']:
                    type = entry['RequestType'] if 'RequestType' in entry.keys() else None
                    if type:
                        if type.lower() == 'table':
                            response['exportRequests']['tableRequests'].append(entry)
                        else:
                            response['exportRequests']['s3Requests'].append(entry)
                    else:
                        response['exportRequests']['s3Requests'].append(entry)
                    

            # Trusted User Request query
            trustedRequestResponse = trustedRequestTable.query(
                IndexName='DataInfo-ReqReceivedtimestamp-index',
                KeyConditionExpression=Key('Dataset-DataProvider-Datatype').eq(userdataset))
            if trustedRequestResponse['Items']:
                response['trustedRequests'].append(trustedRequestResponse['Items'])

        # Auto-export uses derived data types that has no limit of potential datatypes so prefix must be used
        userdatasetprefixes = []
        for ds in userdatasets:
            prefix = ds.split('-')[0] + '-' + ds.split('-')[0]
            if prefix not in userdatasetprefixes:
                userdatasetprefixes.append(prefix)

        for datasetprefix in userdatasetprefixes:
            logging.info("Dataset Prefix: " + datasetprefix)

            # Auto-Export Request query
            # This will become  unused  with impending removal of CVP-WYDOT as an available dataset
            autoExportRequestResponse = autoExportRequestTable.scan(
                FilterExpression=Attr('Dataset-DataProvider-Datatype').begins_with('CVP-WYDOT'))
            if autoExportRequestResponse['Items']:
                response['autoExportRequests'].append(autoExportRequestResponse['Items'])

        logging.info(response)
    except BaseException as be:
        logging.exception("Error: Failed to get submit requests" + str(be))
        raise ("Failed to get submit requests")

    return {
        'isBase64Encoded': False, 
        'statusCode':200,
        'headers':{
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Origin': 'https://sub1.sdc-dev.dot.gov',
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET',
                'Content-Type': 'text/plain'
        }, 
        'body':json.dumps(response)
    }