import { NgModule } from '@angular/core';
import { AuthModule, LogLevel } from 'angular-auth-oidc-client';
import { environment } from 'src/environments/environment';

const AuthConfig = environment.auth_config;

@NgModule({
    imports: [AuthModule.forRoot({
        config: {
            authority: AuthConfig.authority,
            redirectUrl: AuthConfig.redirectUrl,
            clientId: AuthConfig.clientId,
            scope: AuthConfig.scope,
            responseType: AuthConfig.responseType,
            postLogoutRedirectUri: environment.logout_url,
            silentRenew: true,
            useRefreshToken: true,
            renewTimeBeforeTokenExpiresInSeconds: 30,
            logLevel: LogLevel.Debug,
        }
    })],
    exports: [AuthModule],
})
export class AuthConfigModule { }
