# API used when a user requests to export a table to the edgeDB

import boto3
import os
import logging
import ast, json
import datetime, time


RESTAPIID = os.getenv("RESTAPIID")
AUTHORIZERID = os.getenv("AUTHORIZERID")
TABLENAME_USER_STACKS = os.getenv("TABLENAME_USER_STACKS")
TABLENAME_AVAILABLE_DATASET = os.getenv("TABLENAME_AVAILABLE_DATASET")
TABLENAME_EXPORT_FILE_REQUEST = os.getenv("TABLENAME_EXPORT_FILE_REQUEST")
ALLOW_ORIGIN_URL = os.getenv("ALLOW_ORIGIN_URL")

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


def get_user_details(id_token):
    apigateway = boto3.client('apigateway')
    response = apigateway.test_invoke_authorizer(
    restApiId=RESTAPIID,
    authorizerId=AUTHORIZERID,
    headers={
        'Authorization': id_token
    })
    print('test invoke authorizer response: ', response)
    # roles_response=response['claims']['family_name']
    email=response['claims']['email']
    full_username=response['claims']['cognito:username'].split('\\')[1]
    # roles_list_formatted = ast.literal_eval(json.dumps(roles_response))
    # role_list= roles_list_formatted.split(",")

    # roles=[]
    # for r in role_list:
    #     if ":role/" in r:
    #         roles.append(r.split(":role/")[1])

    # return { 'role' : roles , 'email': email, 'username': full_username }
    return { 'email': email, 'username': full_username }
 

def get_user_details_from_username(username):
    try:
        table = dynamodb_client.Table(TABLENAME_USER_STACKS)  
        response_table = table.get_item(Key={'username': username })
        team_name = response_table['Item']['teamName']
        logging.info("team_name: " + team_name)
    except BaseException as be:
        logging.exception("Error: Failed to get the team name for the user" + str(be))
        raise ("Failed to get the team name for the user")
    return team_name


def lambda_handler(event, context):
    paramsQuery = json.loads(event['body'])
    paramsString = paramsQuery['message']
    logger.setLevel("INFO")
    logging.info("Received request {}".format(paramsString))
    params = json.loads(paramsString)
    bypassExportFileRequestTable = False

    try:
        selctedDataSet=params['selectedDataInfo']['selectedDataSet']
        selectedDataProvider=params['selectedDataInfo']['selectedDataProvider']
        selectedDatatype=params['selectedDataInfo']['selectedDatatype']
        combinedDataInfo=selctedDataSet + "-" + selectedDataProvider + "-" + selectedDatatype
        userID=params['UserID']
        team_name = get_user_details_from_username(userID)

        id_token = event['headers']['Authorization']
        info_dict=get_user_details(id_token)
        user_email=info_dict['email']

        combinedExportWorkflow = get_combined_export_workflow()

        trustedWorkflowStatus = \
            combinedExportWorkflow[selctedDataSet][selectedDataProvider]['datatypes'][selectedDatatype]['Trusted']['WorkflowStatus']

        nonTrustedWorkflowStatus = \
            combinedExportWorkflow[selctedDataSet][selectedDataProvider]['datatypes'][selectedDatatype]['NonTrusted']['WorkflowStatus']

        listOfPOC=combinedExportWorkflow[selctedDataSet][selectedDataProvider]['ListOfPOC']
        dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
        acceptableUse = 'Decline'

        if 'acceptableUse' in params and params['acceptableUse']:
            acceptableUse = params['acceptableUse']

            source_db_schema = 'internal' #TODO Retrieve this from SSM Param Store
            target_db_schema = 'edge'#TODO Retrieve this from SSM Param Store
            database_name = str(params['DatabaseName'])
            table_name = str(params['TableName'])
            
            exportFileRequestTable = dynamodb.Table(TABLENAME_EXPORT_FILE_REQUEST)
            table_key_hash = database_name +'.'+source_db_schema+'.'+table_name
            timemills = int(time.time())
            response = exportFileRequestTable.put_item(
                Item={
                    'S3KeyHash': table_key_hash,
                    'S3Key': table_key_hash,
                    'Dataset-DataProvider-Datatype': combinedDataInfo,
                    'ApprovalForm': params['ApprovalForm'],
                    'RequestReviewStatus': 'Submitted',
                    'RequestedBy_Epoch': userID + "_" + str(timemills),
                    'RequestedBy': userID,
                    'TeamBucket': '',
                    'ReqReceivedTimestamp': timemills,
                    'UserEmail': user_email,
                    'ReqReceivedDate': datetime.datetime.now().strftime('%Y-%m-%d'),
                    'TableName': table_name,
                    'SourceDatabaseSchema': source_db_schema,
                    'TargetDatabaseSchema': target_db_schema,
                    'RequestType': 'Table',
                    'DatabaseName': database_name,
                    'ListOfPOC': listOfPOC,
                    'TableSchema': '' #Gets populated in glue job execution below.
                }
            )
            availableDatasets = get_datasets()['datasets']['Items']
            logging.info("Available datasets:" + str(availableDatasets))

            fakeListOfPOC = ['c.m.fitzgerald.ctr@dot.gov', 'b.fitzpatrick.ctr@dot.gov'] #For Debugging

            glue_client = boto3.client('glue')
            glueWorkflowName = f"Populate_Schema_Export_Request"
            glue_schemaPopulate_workflow = glue_client.start_workflow_run(Name=glueWorkflowName)
            update_schemaPopulate_workflow = glue_client.put_workflow_run_properties(
                Name = glueWorkflowName,
                RunId = glue_schemaPopulate_workflow['RunId'],
                RunProperties = {
                    'S3KeyHash': table_key_hash,
                    'RequestedByEpoch': userID + "_" + str(timemills),
                    'databaseName': database_name,
                    'tableName': table_name,
                    'internalSchema': source_db_schema,
                    'listOfPOC': ','.join(listOfPOC),
                    #'listOfPOC': ','.join(fakeListOfPOC),
                    'userID': userID,
                    'userEmail': user_email
                }
            )

    except BaseException as be:
        logging.exception("Error: Failed to process export request" + str(be))
        raise ("Failed to process export request")

    return {
        'isBase64Encoded': False, 
        'statusCode':200,
        'headers':{
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Origin': ALLOW_ORIGIN_URL,
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET',
                'Content-Type': 'text/plain'
        }, 
        'body':json.dumps(response)
    }