import json
    
    
def lambda_handler(event, context):
    return {
        'isBase64Encoded': False, 
        'statusCode':200,
        'headers':{
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Origin': 'https://sub1.sdc-dev.dot.gov',
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET',
                'Content-Type': 'application/json'
        }, 
        'body':json.dumps({"isHealthy": True, "source": "webportal-api"})
    }