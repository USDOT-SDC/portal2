package org.apache.guacamole.auth.header;

// SDC CUSTOM — the JWT validation and Cognito username extraction logic is
// entirely custom. The surrounding Guice injection scaffolding is generic.
//
// Authentication flow:
//   1. Browser arrives at Guacamole with ?authToken=<Cognito JWT> in the URL
//      (Cognito appends this after a successful login redirect)
//   2. We extract the token using the param name from http-request-param
//      (default: "authToken") in guacamole.properties
//   3. AuthenticationUtil validates the JWT signature against Cognito's JWKS
//   4. We extract the username from the cognito:username claim in the payload.
//      The pool currently uses plain usernames (e.g. "jsmith") with no IdP
//      prefix. The backslash-strip below is a no-op for plain usernames but
//      handles "<IdP>\jsmith" style names if federation is added later.
//   5. On success, return an AuthenticatedUser; on any failure throw
//      GuacamoleInvalidCredentialsException so Guacamole shows a login error.

import com.google.inject.Inject;
import com.google.inject.Provider;
import com.nimbusds.jwt.JWTClaimsSet;
import net.minidev.json.JSONObject;
import org.apache.guacamole.GuacamoleException;
import org.apache.guacamole.auth.header.user.AuthenticatedUser;
import org.apache.guacamole.auth.header.user.AuthenticationUtil;
import org.apache.guacamole.net.RequestDetails;
import org.apache.guacamole.net.auth.Credentials;
import org.apache.guacamole.net.auth.credentials.CredentialsInfo;
import org.apache.guacamole.net.auth.credentials.GuacamoleInvalidCredentialsException;
import java.util.logging.Logger;

public class AuthenticationProviderService {

    private static final Logger logger = Logger.getLogger(AuthenticationProviderService.class.getName());

    @Inject
    private ConfigurationService confService;

    @Inject
    private Provider<AuthenticatedUser> authenticatedUserProvider;

    public AuthenticatedUser authenticateUser(Credentials credentials) throws GuacamoleException {
        String username = null;
        RequestDetails requestDetails = credentials.getRequestDetails();
        String webKeyUrl = confService.getCognitoWebKeyUrl();
        String requestParam = confService.getHttpRequestParam();

        if (requestDetails != null) {
            String token = requestDetails.getParameter(requestParam);
            try {
                if (token != null && token.length() > 1) {
                    JWTClaimsSet jwtClaimsSet = AuthenticationUtil.validateAWSJwtToken(token, webKeyUrl);
                    if (jwtClaimsSet == null) {
                        throw new GuacamoleInvalidCredentialsException("Invalid login.", CredentialsInfo.USERNAME_PASSWORD);
                    }
                    JSONObject payload = jwtClaimsSet.toJSONObject();
                    String userName = payload.getAsString("cognito:username");
                    // Strip any "<IdP>\" prefix from federated usernames.
                    // Current pool uses plain usernames with no prefix, so this
                    // is a no-op today but harmless if federation is added later.
                    username = userName.substring(userName.indexOf("\\") + 1);
                }
            } catch (GuacamoleInvalidCredentialsException e) {
                throw e;
            } catch (Exception e) {
                logger.warning(() -> "Authentication failed: " + e.getMessage());
                throw new GuacamoleInvalidCredentialsException("Invalid login.", CredentialsInfo.USERNAME_PASSWORD);
            }
        }

        if (username != null) {
            AuthenticatedUser authenticatedUser = authenticatedUserProvider.get();
            authenticatedUser.init(username, credentials);
            return authenticatedUser;
        }

        throw new GuacamoleInvalidCredentialsException("Invalid login.", CredentialsInfo.USERNAME_PASSWORD);
    }
}
