package org.apache.guacamole.auth.header;

import com.google.inject.AbstractModule;
import org.apache.guacamole.GuacamoleException;
import org.apache.guacamole.environment.Environment;
import org.apache.guacamole.environment.LocalEnvironment;
import org.apache.guacamole.net.auth.AuthenticationProvider;


public class HTTPHeaderAuthenticationProviderModule
  extends AbstractModule
{
  private final Environment environment;
  private final AuthenticationProvider authProvider;
  
  public HTTPHeaderAuthenticationProviderModule(AuthenticationProvider authProvider) {
     try {
  this.environment = (Environment)new LocalEnvironment();
  } catch (Exception ex) {
    throw new RuntimeException("Failed to created LocalEnvironemnt", ex);
  }

     this.authProvider = authProvider;
  }

  protected void configure() {
     bind(AuthenticationProvider.class).toInstance(this.authProvider);
     bind(Environment.class).toInstance(this.environment);

    
     bind(ConfigurationService.class);
  }
}