package org.apache.guacamole.auth.header.user;

// GENERIC BOILERPLATE — no SDC-specific logic here.
// Minimal AuthenticatedUser implementation: holds the username (lowercased)
// and the original Credentials object. Constructed by Guice and initialized
// by AuthenticationProviderService after a successful JWT validation.

import com.google.inject.Inject;
import org.apache.guacamole.net.auth.AbstractAuthenticatedUser;
import org.apache.guacamole.net.auth.AuthenticationProvider;
import org.apache.guacamole.net.auth.Credentials;

public class AuthenticatedUser extends AbstractAuthenticatedUser {

    @Inject
    private AuthenticationProvider authProvider;

    private Credentials credentials;

    // Called by AuthenticationProviderService once the JWT is validated and
    // the username has been extracted from the cognito:username claim.
    public void init(String username, Credentials credentials) {
        this.credentials = credentials;
        setIdentifier(username.toLowerCase());
    }

    @Override
    public AuthenticationProvider getAuthenticationProvider() {
        return authProvider;
    }

    @Override
    public Credentials getCredentials() {
        return credentials;
    }
}
