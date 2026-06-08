package org.apache.guacamole.auth.header;

// MOSTLY GENERIC — property key names and defaults are SDC-specific.
// Declares the three guacamole.properties keys this extension reads.
// Property values are set in guacamole.properties on the server (rendered by
// user-data.sh from Terraform template variables).
//
// SDC-specific keys and their defaults:
//   http-auth-header   -> REMOTE_USER   (standard header-auth; not actually
//                                        used for JWT flow but required by ext)
//   http-request-param -> authToken     (query param Cognito appends to the
//                                        redirect URL after login)
//   cognito-web-key-url                 (Cognito JWKS endpoint used to verify
//                                        the JWT; set to the pool's /.well-known
//                                        /jwks.json URL via terraform template)

import org.apache.guacamole.properties.StringGuacamoleProperty;

public class HTTPHeaderGuacamoleProperties {

    // HTTP header carrying the pre-authenticated username (e.g. from a reverse
    // proxy). Not used in the Cognito JWT flow but required by the base ext.
    public static final StringGuacamoleProperty HTTP_AUTH_HEADER =
            new StringGuacamoleProperty() {
                @Override
                public String getName() { return "http-auth-header"; }
            };

    // Query parameter name that carries the Cognito JWT on the redirect URL.
    // Must match the param name Cognito is configured to append.
    public static final StringGuacamoleProperty HTTP_REQUEST_PARAM =
            new StringGuacamoleProperty() {
                @Override
                public String getName() { return "http-request-param"; }
            };

    // SDC CUSTOM — not in the upstream guacamole-auth-header extension.
    // Full URL to the Cognito user pool's JWKS endpoint, e.g.:
    //   https://cognito-idp.us-east-1.amazonaws.com/<pool-id>/.well-known/jwks.json
    // Set via cognito-web-key-url in guacamole.properties.
    public static final StringGuacamoleProperty COGNITO_WEB_KEY_URL =
            new StringGuacamoleProperty() {
                @Override
                public String getName() { return "cognito-web-key-url"; }
            };
}
