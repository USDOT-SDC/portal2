import json
from lambda_cognito_layer import cognito_user_service, authentication_service, jwt_claims_processor_service


def link_account(event, context):
    result = jwt_claims_processor_service.get_verified_claims(event)
    if result['hasError']:
        result['body']['userErrorMessage'] = 'Encountered an unknown error processing your request.'
        return add_headers({ 'statusCode': result['statusCode'], 'body': json.dumps(result['body']) })
    if account_is_linked(result['claims']):
        return add_headers({ 'statusCode': 400, 'body': json.dumps({ 'userErrorMessage': 'Encountered an unknown error processing your request.', 
                                                         'errorMessage': 'This account is already linked.'}) })

    body_json = json.loads(event['body'])
    username = right_chop(body_json['username'], '@securedatacommons.com')
    authentication_result = authentication_service.authenticate_user(username, body_json['password'])
    if authentication_result['hasError']: return add_headers({ 'statusCode': authentication_result['statusCode'], 'body': json.dumps(authentication_result['body']) })

    user_result = cognito_user_service.associate_user(username, result['claims'])
    if user_result['hasError']:    
        return add_headers({ 'statusCode': user_result['statusCode'], 'body': json.dumps(user_result['body']) })
    else:
        return add_headers({'statusCode': 200, 'body': json.dumps(user_result['body'])})

def right_chop(thestring, ending):
    if thestring.endswith(ending):
        return thestring[:-len(ending)]
    return thestring

def account_is_linked(claims):
    return 'ADFS' in claims['cognito:username']

def add_headers(result):
    result['headers'] = { 'access-control-allow-origin': '*', 
                          "access-control-allow-credentials": "true",
                          "access-control-allow-headers": "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,Origin,Access-Control-Allow-Origin'" }
    return result