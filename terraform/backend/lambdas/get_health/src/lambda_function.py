import json
    
    
def get_health():
    return {'isBase64Encoded': False, 'statusCode':200, 'headers':{'Content-Type': 'application/json'}, 'body':json.dumps({"isHealthy": True, "source": "webportal-api"})}
