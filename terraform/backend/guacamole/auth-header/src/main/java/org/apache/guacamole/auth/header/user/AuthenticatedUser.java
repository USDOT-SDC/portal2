package org.apache.guacamole.auth.header.user;

import com.google.inject.Inject;
import org.apache.guacamole.net.auth.AbstractAuthenticatedUser;
import org.apache.guacamole.net.auth.AuthenticationProvider;
import org.apache.guacamole.net.auth.Credentials;










































public class AuthenticatedUser
  extends AbstractAuthenticatedUser
{
  @Inject
  private AuthenticationProvider authProvider;
  private Credentials credentials;
  
  public void init(String username, Credentials credentials) {
/* 57 */     this.credentials = credentials;
/* 58 */     setIdentifier(username.toLowerCase());
  }

  
  public AuthenticationProvider getAuthenticationProvider() {
/* 63 */     return this.authProvider;
  }

  
  public Credentials getCredentials() {
/* 68 */     return this.credentials;
  }
}


/* Location:              C:\Users\Scott.Shugh\Documents\DoT\guacamole\guacamole-auth-header-0.9.14.jar!\org\apache\guacamole\auth\heade\\user\AuthenticatedUser.class
 * Java compiler version: 6 (50.0)
 * JD-Core Version:       1.1.3
 */