import boto3
import os

LAMBDA_USER_PREFIX = 'PROXY-ADFS'
DOT_AD_USER_PREFIX = 'ADDOT'

DOT_AD = 'dot_active_directory_user'
LOGIN_GOV = 'login_gov_user'


def associate_user(username, claims):
    if user_exists(username):
        return delete_and_associate_user(claims, username, 'USDOT-ADFS')
    else:
        return associate_with_new_cognito_user(claims, username)


def user_exists(username):
    client = cognito_client()
    try:
        client.admin_get_user(UserPoolId=os.environ.get('USER_POOL_ID'), Username='USDOT-ADFS_SDC\\' + username)
    except client.exceptions.UserNotFoundException as e:
        return False
    return True


def delete_and_associate_user(claims, username, provider_name):
    split_username = claims['cognito:username'].split('_')
    client = cognito_client()
    client.admin_delete_user(UserPoolId=os.environ.get('USER_POOL_ID'), Username=claims['cognito:username'])
    client.admin_link_provider_for_user(UserPoolId=os.environ.get('USER_POOL_ID'),
                                        DestinationUser={'ProviderName': provider_name,
                                                         'ProviderAttributeValue': 'SDC\\' + username},
                                        SourceUser={'ProviderName': split_username[0],
                                                    'ProviderAttributeName': 'Cognito_Subject',
                                                    'ProviderAttributeValue': split_username[1]})
    return {'hasError': False, 'body': {'signInType': identity_provider_sign_in(claims['cognito:username'])}}


def identity_provider_sign_in(cognito_username):
    if DOT_AD_USER_PREFIX in cognito_username:
        return DOT_AD
    else:
        return LOGIN_GOV


def associate_with_new_cognito_user(claims, username):
    client = cognito_client()
    try:
        client.admin_create_user(UserPoolId=os.environ.get('USER_POOL_ID'),
                                 Username=LAMBDA_USER_PREFIX + '_SDC\\' + username,
                                 UserAttributes=[
                                     {'Name': 'email', 'Value': claims['email']},
                                     # Right now, user roles are stored in family_name and referenced here:
                                     # https://github.com/usdot-jpo-sdc/sdc-dot-webportal/blob/master/webportal/lambda/app.py#L60
                                     # However as far as I can tell, these user roles are not actually used within the lambda... this whole thing should be cleaned up ASAP
                                     {'Name': 'family_name', 'Value': '[]'}
                                 ],
                                 MessageAction='SUPPRESS')
    except client.exceptions.UsernameExistsException as e:
        # Allow linking multiple times to the same username
        pass
    return delete_and_associate_user(claims, username, LAMBDA_USER_PREFIX)


def migrate_from_legacy_pool(claims):
    if not os.environ.get('LEGACY_USER_POOL_ID'):
        return {'hasError': False, 'migratedLegacyUser': False}

    legacy_user = find_legacy_user_by_email(claims['email'])
    if not legacy_user:
        return {'hasError': False, 'migratedLegacyUser': False}

    username = legacy_user['Username'].split('\\')[1]
    associate_with_new_cognito_user(claims, username)
    return {'hasError': False, 'migratedLegacyUser': True}


def find_legacy_user_by_email(email):
    legacy_pool = os.environ.get('LEGACY_USER_POOL_ID')
    client = cognito_client()
    list_user_result = client.list_users(UserPoolId=legacy_pool)
    user_list = list_user_result['Users']
    pagination_token = list_user_result.get('PaginationToken')
    while pagination_token:
        list_user_result = client.list_users(UserPoolId=legacy_pool, PaginationToken=pagination_token)
        pagination_token = list_user_result.get('PaginationToken')
        user_list.extend(list_user_result['Users'])
    result = None
    for user in user_list:
        for attribute in user['Attributes']:
            if attribute['Name'] == 'email' and attribute['Value'].lower() == email.lower():
                result = user
    return result


def cognito_client():
    return boto3.client('cognito-idp')