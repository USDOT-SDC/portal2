import json
from account_link import cognito_user_service, authentication_service, jwt_claims_processor_service


def reset_temporary_password(event, context):
    result = jwt_claims_processor_service.get_verified_claims(event)
    if result['hasError']:
        result['body']['userErrorMessage'] = 'Encountered an unknown error processing your request.'
        return add_headers({'statusCode': result['statusCode'], 'body': json.dumps(result['body'])})
    body_json = json.loads(event['body'])
    username = right_chop(body_json.get('username'), '@securedatacommons.com')
    current_password = body_json.get('currentPassword')
    new_password = body_json.get('newPassword')
    new_password_confirmation = body_json.get('newPasswordConfirmation')
    password_reset_result = authentication_service.change_temporary_user_password(username, current_password, new_password, new_password_confirmation)
    if password_reset_result['hasError']:
        return add_headers({'statusCode': password_reset_result['statusCode'], 'body': json.dumps(password_reset_result['body'])})
    user_result = cognito_user_service.associate_user(username, result['claims'])
    if user_result['hasError']:
        return add_headers({'statusCode': user_result['statusCode'], 'body': json.dumps(user_result['body'])})
    else:
        return add_headers({'statusCode': 200, 'body': json.dumps(user_result['body'])})


def right_chop(thestring, ending):
    if thestring.endswith(ending):
        return thestring[:-len(ending)]
    return thestring

def add_headers(result):
    result['headers'] = { 'access-control-allow-origin': '*', 
                          "access-control-allow-credentials": "true",
                          "access-control-allow-headers": "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,Origin,Access-Control-Allow-Origin'" }
    return result