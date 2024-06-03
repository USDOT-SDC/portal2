import { Amplify } from 'aws-amplify';
import { fetchAuthSession, CredentialsAndIdentityIdProvider, CredentialsAndIdentityId, GetCredentialsOptions, AuthTokens, } from 'aws-amplify/auth';
import { CognitoIdentity } from '@aws-sdk/client-cognito-identity';
import { environment } from 'src/environments/environment';

const COGNITO_IDENTITY = new CognitoIdentity({ region: '<region-from-config>', });

export class CustomCredentialProvider implements CredentialsAndIdentityIdProvider {

    public federatedLogin: { domain: string, token: string } | any;

    public loadFederatedLogin(login?: typeof this.federatedLogin): void { this.federatedLogin = login; }

    public async getCredentialsAndIdentityId(getCredentialsOptions?: GetCredentialsOptions): Promise<CredentialsAndIdentityId | undefined> {
        try {

            // You can add in some validation to check if the token is available before proceeding
            // You can also refresh the token if it's expired before proceeding

            const getIdResult: any = await COGNITO_IDENTITY.getId({
                IdentityPoolId: 'environment.cognito.Auth.Cognito.userPoolClientId',
                Logins: { [this.federatedLogin.domain]: this.federatedLogin.token },
            });

            const cognitoCredentialsResult: any = await COGNITO_IDENTITY.getCredentialsForIdentity({
                IdentityId: getIdResult.IdentityId,
                Logins: { [this.federatedLogin.domain]: this.federatedLogin.token },
            });

            const credentials: CredentialsAndIdentityId = {
                credentials: {
                    accessKeyId: cognitoCredentialsResult.Credentials?.AccessKeyId,
                    secretAccessKey: cognitoCredentialsResult.Credentials?.SecretKey,
                    sessionToken: cognitoCredentialsResult.Credentials?.SessionToken,
                    expiration: cognitoCredentialsResult.Credentials?.Expiration,
                },
                identityId: getIdResult.IdentityId,
            };
            return credentials;
        } catch (e) {
            console.log('Error getting credentials: ', e);
            return undefined
        }
    }

    // Implement this to clear any cached credentials and identityId. This can be called when signing out of the federation service.
    public clearCredentialsAndIdentityId(): void { }
}
