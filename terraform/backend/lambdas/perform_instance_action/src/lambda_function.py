import boto3
import logging
import simplejson as json


logger = logging.getLogger()


def lambda_handler(event, context):
    params = event['queryStringParameters']
    if not params or "instance_id" not in params:
        logger.error("The query parameters 'instance_id' is missing")
        raise BadRequestError("The query parameters 'instance_id' is missing")

    if not params or "action" not in params:
        logger.error("The query parameters 'action' is missing")
        raise BadRequestError("The query parameters 'action' is missing")
    
    resource = boto3.resource('ec2')
    instance = resource.Instance(params['instance_id'])

    if params['action'] == 'run':
        try:
            response = instance.start()
        except BaseException as be:
            logging.exception("Error: Failed to start instance" + str(be) )
            raise ("Internal error at server side")
    else:
        try:
            response = instance.stop(Force=True)
        except BaseException as be:
            logging.exception("Error: Failed to stop instance" + str(be) )
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
        'body':json.dumps({'Status':response})
    }