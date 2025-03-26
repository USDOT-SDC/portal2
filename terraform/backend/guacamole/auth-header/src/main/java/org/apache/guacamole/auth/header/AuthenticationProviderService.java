package org.apache.guacamole.auth.header;

import com.google.inject.Inject;
import com.google.inject.Provider;
import com.nimbusds.jwt.JWTClaimsSet;
import javax.servlet.http.HttpServletRequest;
import net.minidev.json.JSONObject;
import org.apache.guacamole.GuacamoleException;
import org.apache.guacamole.auth.header.user.AuthenticatedUser;
import org.apache.guacamole.auth.header.user.AuthenticationUtil;
import org.apache.guacamole.net.auth.Credentials;
import org.apache.guacamole.net.auth.credentials.CredentialsInfo;
import org.apache.guacamole.net.auth.credentials.GuacamoleInvalidCredentialsException;

public class AuthenticationProviderService
{
  @Inject
  private ConfigurationService confService;
  @Inject
  private Provider<AuthenticatedUser> authenticatedUserProvider;
  
  public AuthenticatedUser authenticateUser(Credentials credentials) throws GuacamoleException {
    String username = null;
    HttpServletRequest request = credentials.getRequest();
    String webKeyUrl = this.confService.getCognitoWebKeyUrl();
    String requestParam = this.confService.getHttpRequestParam();
    if (request != null) {
      String token = request.getParameter(requestParam);
      try {
        if (token != null && token.length() > 1) {
          JWTClaimsSet jwtClaimsSet = AuthenticationUtil.validateAWSJwtToken(token, webKeyUrl);
          if (jwtClaimsSet == null) {
            throw new GuacamoleInvalidCredentialsException("Invalid login.", CredentialsInfo.USERNAME_PASSWORD);
          }
          JSONObject payload = jwtClaimsSet.toJSONObject();
          String userName = payload.getAsString("cognito:username");
          username = String.valueOf(userName.substring(userName.indexOf("\\") + 1));
        }
      } catch (Exception e) {
    	e.printStackTrace();
        throw new GuacamoleInvalidCredentialsException("Invalid login.", CredentialsInfo.USERNAME_PASSWORD);
      } 
    } 


    
    if (username != null) {
      AuthenticatedUser authenticatedUser = (AuthenticatedUser)this.authenticatedUserProvider.get();
      authenticatedUser.init(username, credentials);
      return authenticatedUser;
    } 


    
    throw new GuacamoleInvalidCredentialsException("Invalid login.", CredentialsInfo.USERNAME_PASSWORD);
  }
}