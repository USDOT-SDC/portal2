import boto3


logger = logging.getLogger()
    
    
def lambda_handler(event, context):
    params = event['queryStringParameters']
    if not params or "instance_id" not in params:
        logger.error("The query parameters 'instance_id' is missing")
        raise BadRequestError("The query parameters 'instance_id' is missing")

    try:
        client_ec2 = boto3.client('ec2')
        response = client_ec2.describe_instance_status(
            InstanceIds=[
                params['instance_id'],
            ]
        )
    except BaseException as be:
        logging.exception("Error: Failed to get info about instance" + str(be) )
        raise ("Internal error at server side")

    return Response(body={'Status': response},
                    status_code=200,
                    headers={'Content-Type': 'text/plain'})
