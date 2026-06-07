package org.apache.guacamole.auth.header;

// GENERIC BOILERPLATE — no SDC-specific logic here.
// Standard Guice module that binds the three objects the injector needs to
// construct AuthenticationProviderService: the AuthenticationProvider itself,
// the shared LocalEnvironment (singleton provided by Guacamole), and the
// ConfigurationService that reads guacamole.properties.

import com.google.inject.AbstractModule;
import org.apache.guacamole.environment.Environment;
import org.apache.guacamole.environment.LocalEnvironment;
import org.apache.guacamole.net.auth.AuthenticationProvider;

public class HTTPHeaderAuthenticationProviderModule extends AbstractModule {

    private final Environment environment;
    private final AuthenticationProvider authProvider;

    public HTTPHeaderAuthenticationProviderModule(AuthenticationProvider authProvider) {
        // LocalEnvironment.getInstance() returns the singleton shared with the
        // Guacamole web app — do NOT use new LocalEnvironment() (deprecated).
        this.environment = LocalEnvironment.getInstance();
        this.authProvider = authProvider;
    }

    @Override
    protected void configure() {
        bind(AuthenticationProvider.class).toInstance(authProvider);
        bind(Environment.class).toInstance(environment);
        bind(ConfigurationService.class);
    }
}
