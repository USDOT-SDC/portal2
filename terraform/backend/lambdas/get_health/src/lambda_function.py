import json
    
    
def lambda_handler(event, context):
    return {'isBase64Encoded': False, 'statusCode':200, 'headers':{'Content-Type': 'application/json'}, 'body':json.dumps({"isHealthy": True, "source": "webportal-api"})}
