package org.apache.guacamole.auth.header;

// GENERIC BOILERPLATE — no SDC-specific logic here.
// This is the entry point that Guacamole discovers via guac-manifest.json.
// It wires the Guice injector and delegates all real work to
// AuthenticationProviderService. The only meaningful value here is
// getIdentifier(), which must match the "extension-priority" value in
// guacamole.properties ("header").

import com.google.inject.Guice;
import com.google.inject.Injector;
import com.google.inject.Module;
import org.apache.guacamole.GuacamoleException;
import org.apache.guacamole.net.auth.AuthenticatedUser;
import org.apache.guacamole.net.auth.AuthenticationProvider;
import org.apache.guacamole.net.auth.Credentials;
import org.apache.guacamole.net.auth.UserContext;

public class HTTPHeaderAuthenticationProvider implements AuthenticationProvider {

    // Guice injector — wires all @Inject dependencies across the extension.
    private final Injector injector = Guice.createInjector(
            new Module[] { new HTTPHeaderAuthenticationProviderModule(this) });

    // Must match "extension-priority: header" in guacamole.properties.
    @Override
    public String getIdentifier() {
        return "header";
    }

    @Override
    public Object getResource() {
        return null;
    }

    // Real authentication logic lives in AuthenticationProviderService.
    @Override
    public AuthenticatedUser authenticateUser(Credentials credentials) throws GuacamoleException {
        AuthenticationProviderService authProviderService =
                injector.getInstance(AuthenticationProviderService.class);
        return authProviderService.authenticateUser(credentials);
    }

    // Remaining methods are required by the AuthenticationProvider interface
    // but unused — we don't manage user contexts or sessions.

    @Override
    public AuthenticatedUser updateAuthenticatedUser(AuthenticatedUser authenticatedUser,
            Credentials credentials) throws GuacamoleException {
        return authenticatedUser;
    }

    @Override
    public UserContext getUserContext(AuthenticatedUser authenticatedUser) throws GuacamoleException {
        return null;
    }

    @Override
    public UserContext updateUserContext(UserContext context, AuthenticatedUser authenticatedUser,
            Credentials credentials) throws GuacamoleException {
        return context;
    }

    @Override
    public UserContext decorate(UserContext context, AuthenticatedUser authenticatedUser,
            Credentials credentials) throws GuacamoleException {
        return context;
    }

    @Override
    public UserContext redecorate(UserContext decorated, UserContext context,
            AuthenticatedUser authenticatedUser, Credentials credentials) throws GuacamoleException {
        return context;
    }

    @Override
    public void shutdown() {}
}
