import json
import boto3

def lambda_handler(event, context):
    cognito_client = boto3.client('cognito-idp')
    user_pool_id = event['userPoolId']
    provider_name = event['callerContext']['clientId']
    user_attributes = event['request']['userAttributes']
    email = user_attributes.get('email')

    # Check if a user with the same email already exists
    try:
        response = cognito_client.list_users(
            UserPoolId=user_pool_id,
            Filter=f'email = "{email}"',
            Limit=1
        )
        existing_users = response.get('Users', [])

        if existing_users:
            # Existing user found, link the DOT-PIV identity
            existing_user = existing_users[0]
            username = existing_user['Username']
            
            cognito_client.admin_link_provider_for_user(
                UserPoolId=user_pool_id,
                DestinationUser={
                    'ProviderName': 'Cognito',
                    'ProviderAttributeName': 'cognito:username',
                    'ProviderAttributeValue': username
                },
                SourceUser={
                    'ProviderName': 'DOT-PIV',  # Assuming DOT-PIV is the provider name
                    'ProviderAttributeName': 'email',
                    'ProviderAttributeValue': email
                }
            )

            # Auto-confirm the user
            event['response']['autoConfirmUser'] = True
            event['response']['autoVerifyEmail'] = True

        else:
            # No existing user, proceed with normal sign-up
            event['response']['autoConfirmUser'] = True
            event['response']['autoVerifyEmail'] = True

    except Exception as e:
        print(f"Error: {str(e)}")
        # In case of error, allow sign-up to proceed without linking
        event['response']['autoConfirmUser'] = True
        event['response']['autoVerifyEmail'] = True

    return event