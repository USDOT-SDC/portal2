package org.apache.guacamole.auth.header;

import com.google.inject.Guice;
import com.google.inject.Injector;
import com.google.inject.Module;
import org.apache.guacamole.GuacamoleException;
import org.apache.guacamole.net.auth.AuthenticatedUser;
import org.apache.guacamole.net.auth.AuthenticationProvider;
import org.apache.guacamole.net.auth.Credentials;
import org.apache.guacamole.net.auth.UserContext;


public class HTTPHeaderAuthenticationProvider 
  implements AuthenticationProvider
{
  private final Injector injector = Guice.createInjector(new Module[] {
        (Module)new HTTPHeaderAuthenticationProviderModule(this)
      });

  public String getIdentifier() {
    return "header";
  }
  
  public Object getResource() {
    return null;
  }

  public AuthenticatedUser authenticateUser(Credentials credentials) throws GuacamoleException {
    AuthenticationProviderService authProviderService = (AuthenticationProviderService)this.injector.getInstance(AuthenticationProviderService.class);
    return (AuthenticatedUser)authProviderService.authenticateUser(credentials);
  }

  public AuthenticatedUser updateAuthenticatedUser(AuthenticatedUser authenticatedUser, Credentials credentials) throws GuacamoleException {
    return authenticatedUser;
  }

  public UserContext getUserContext(AuthenticatedUser authenticatedUser) throws GuacamoleException {
    return null;
  }

  public UserContext updateUserContext(UserContext context, AuthenticatedUser authenticatedUser, Credentials credentials) throws GuacamoleException {
    return context;
  }

  public UserContext decorate(UserContext context, AuthenticatedUser authenticatedUser, Credentials credentials) throws GuacamoleException {
    return context;
  }
  
  public UserContext redecorate(UserContext decorated, UserContext context, AuthenticatedUser authenticatedUser, Credentials credentials) throws GuacamoleException {
    return context;
  }
  
  public void shutdown() {}
}