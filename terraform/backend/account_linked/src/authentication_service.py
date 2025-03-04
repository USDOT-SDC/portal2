import os
from ldap3 import Server, Connection, ALL, Tls, SUBTREE, extend
import ssl
import boto3

AD_ENDPOINT_PARAM_STORE_NAME = 'SDCActiveDirectoryEndpoint'
SSL_FOLDER = '/tmp'
SSL_CERT_FILE_NAME = "sdc_internal_certificate.pem"
SERVICE_ACCOUNT_USERNAME = "password_reset"
SERVICE_ACCOUNT_PASSWORD_KEY = "Password-Reset-Service-Account-Password"
UNKNOWN_ERROR_MESSAGE = 'Encountered an unknown error processing your request. If you continue to see this message, email support@securedatacommons.com for additional assistance.'
INVALID_PASSWORD_ERROR_MESSAGE = 'The password does not match the required criteria. It must be 7 characters long and contain at least 3 of the following: lower case letter, upper case letter, special character, or number.'

def authenticate_user(username, password):
    parameters = get_parameter_store_values()
    ldap_connection = ldap_bind(username, password, parameters)
    if invalid_ldap_connection(ldap_connection):
        return translate_ldap_errors(ldap_connection)
    return {'hasError': False}


def change_temporary_user_password(username, current_password, new_password, new_password_confirmation):
    parameters = get_parameter_store_values()
    ldap_connection = ldap_bind(username, current_password, parameters)
    if invalid_username_or_password(ldap_connection):
        return {'hasError': True, 'statusCode': 400, 'body': {'userErrorMessage': 'Invalid password.'}}
    if not user_must_change_password(ldap_connection):
        return {'hasError': True, 'statusCode': 400, 'body': {'userErrorMessage': UNKNOWN_ERROR_MESSAGE}}
    if new_password != new_password_confirmation:
        return {'hasError': True, 'statusCode': 400, 'body': {'userErrorMessage': 'Passwords do not match.'}}

    admin_connection = ldap_bind(SERVICE_ACCOUNT_USERNAME, parameters[SERVICE_ACCOUNT_PASSWORD_KEY], parameters)
    user_query = f'(&(|(userPrincipalName={username})(samaccountname={username}))(objectClass=person))'
    admin_connection.search(search_base=os.environ['LDAP_SEARCH_BASE'], search_filter=user_query, search_scope=SUBTREE, attributes=['cn', 'givenName'])
    for entry in admin_connection.response:
        if entry.get("dn"):
            user_dn = entry.get('dn')
    reset_successful = extend.microsoft.modifyPassword.ad_modify_password(admin_connection, user_dn, new_password, None)
    if reset_successful:
        return {'hasError': False}
    else:
        return {'hasError': True, 'statusCode': 400, 'body': {'userErrorMessage': INVALID_PASSWORD_ERROR_MESSAGE}}


def ldap_bind(username, password, parameters, raise_exceptions=False):
    host = parameters[AD_ENDPOINT_PARAM_STORE_NAME]
    # Get LDAP server SSL certificate pem file from S3 bucket.
    if os.environ['DOWNLOAD_CUSTOM_LDAP_CERT'] == 'true':
        download_ldap_ssl_certificate()

        tls = Tls(validate=ssl.CERT_REQUIRED, version=ssl.PROTOCOL_TLSv1_2,
                ca_certs_file=SSL_FOLDER + '/' + SSL_CERT_FILE_NAME)
        server = Server(host, port=636, use_ssl=True, get_info=ALL, tls=tls, connect_timeout=5)
    else:
        server = Server(host, port=636, use_ssl=True, get_info=ALL, connect_timeout=5)
    # NOTE: use below for debugging only... port 389 does not use TLS!
    server = Server(host, port=389, use_ssl=False, get_info=ALL, connect_timeout=5)
    connection = Connection(server, user="SDC\\" + username, password=password, receive_timeout=5, raise_exceptions=raise_exceptions)
    connection.open()
    connection.bind()
    return connection


def invalid_ldap_connection(ldap_connection):
    # for a list of values that may appear here, this is a good resource: https://ldapwiki.com/wiki/LDAP%20Result%20Codes
    return ldap_connection.result['result'] != 0


def translate_ldap_errors(ldap_connection):
    # here is a nice resource for these error codes: https://confluence.atlassian.com/stashkb/ldap-error-code-49-317195698.html
    result = {'hasError': True}
    if invalid_username_or_password(ldap_connection):
        result.update({'statusCode': 400, 'body': {'userErrorMessage': 'Invalid username or password.'}})
    elif user_must_change_password(ldap_connection):
        result.update({'statusCode': 400, 'body': {'userErrorMessage': 'Your password has expired.', 'passwordExpired': True}})
    else:
        result.update({'statusCode': 401, 'body': {'userErrorMessage': UNKNOWN_ERROR_MESSAGE}})
    return result


def invalid_username_or_password(ldap_connection):
    return 'data 52e' in ldap_connection.result['message'] or 'data 525' in ldap_connection.result['message']


def user_must_change_password(ldap_connection):
    return 'data 773' in ldap_connection.result['message'] or 'data 532' in ldap_connection.result['message']


def download_ldap_ssl_certificate():
    """
           Method to download LDAP ssl certificate.
    """
    os.makedirs(SSL_FOLDER, exist_ok=True)

    s3 = boto3.client('s3')
    s3.download_file(os.environ['CERTIFICATE_BUCKET'], SSL_CERT_FILE_NAME, SSL_FOLDER + '/' + SSL_CERT_FILE_NAME)


def get_parameter_store_values():
    response = ssm_client().get_parameters(
        Names=[AD_ENDPOINT_PARAM_STORE_NAME, SERVICE_ACCOUNT_PASSWORD_KEY],
        WithDecryption=True
    )
    params = list(map(lambda x: {x['Name']: x['Value']}, response['Parameters']))
    flat_params = {k: v for d in params for k, v in d.items()}
    return flat_params


def ssm_client():
    return boto3.client('ssm')