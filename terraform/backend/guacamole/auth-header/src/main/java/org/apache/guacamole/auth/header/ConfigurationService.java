package org.apache.guacamole.auth.header;

// GENERIC BOILERPLATE — property key names and defaults are SDC-specific.
// Reads the three extension properties from guacamole.properties via the
// injected Environment. Default values mirror what user-data.sh writes into
// guacamole.properties, so the extension works even if a key is missing.

import com.google.inject.Inject;
import org.apache.guacamole.GuacamoleException;
import org.apache.guacamole.environment.Environment;

public class ConfigurationService {

    @Inject
    private Environment environment;

    // Default "REMOTE_USER" — standard header-auth convention; not used in
    // the Cognito JWT flow but required by the base extension interface.
    public String getHttpAuthHeader() throws GuacamoleException {
        return environment.getProperty(
                HTTPHeaderGuacamoleProperties.HTTP_AUTH_HEADER,
                "REMOTE_USER");
    }

    // Default "authToken" — must match the query param name Cognito appends
    // to the redirect URL after a successful login.
    public String getHttpRequestParam() throws GuacamoleException {
        return environment.getProperty(
                HTTPHeaderGuacamoleProperties.HTTP_REQUEST_PARAM,
                "authToken");
    }

    // SDC CUSTOM — no default; must be set in guacamole.properties.
    // Full URL to the Cognito JWKS endpoint used to verify incoming JWTs.
    public String getCognitoWebKeyUrl() throws GuacamoleException {
        return environment.getProperty(
                HTTPHeaderGuacamoleProperties.COGNITO_WEB_KEY_URL,
                "");
    }
}
