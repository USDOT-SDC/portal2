import json
from lambda_cognito_layer import cognito_user_service, jwt_claims_processor_service


def account_linked(event, context):
    result = jwt_claims_processor_service.get_verified_claims(event)
    if result['hasError']:
        return add_headers({ 'statusCode': result['statusCode'], 'body': json.dumps(result['body']) })
    claims = result['claims']
    if account_is_linked(claims):
        return add_headers({'statusCode': 200, 'body': json.dumps({'accountLinked': True, 'migratedLegacyUser': False})})
    else:
        result = cognito_user_service.migrate_from_legacy_pool(claims)
        return add_headers({'statusCode': 200, 'body': json.dumps({'accountLinked': False, 'migratedLegacyUser': result['migratedLegacyUser']})})

def account_is_linked(claims):
    return 'ADFS' in claims['cognito:username']

def add_headers(result):
    result['headers'] = { 'access-control-allow-origin': '*', 
                          "access-control-allow-credentials": "true",
                          "access-control-allow-headers": "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,Origin,Access-Control-Allow-Origin'" }
    return result