package org.apache.guacamole.auth.header;

import com.google.inject.Inject;
import org.apache.guacamole.GuacamoleException;
import org.apache.guacamole.environment.Environment;
import org.apache.guacamole.properties.GuacamoleProperty;

public class ConfigurationService
{
  @Inject
  private Environment environment;
  
  public String getHttpAuthHeader() throws GuacamoleException {
    return (String)this.environment.getProperty(
        (GuacamoleProperty)HTTPHeaderGuacamoleProperties.HTTP_AUTH_HEADER, 
        "REMOTE_USER");
  }

  
  public String getHttpRequestParam() throws GuacamoleException {
    return (String)this.environment.getProperty(
        (GuacamoleProperty)HTTPHeaderGuacamoleProperties.HTTP_REQUEST_PARAM, 
        "authToken");
  }

  
  public String getCognitoWebKeyUrl() throws GuacamoleException {
    return (String)this.environment.getProperty(
        (GuacamoleProperty)HTTPHeaderGuacamoleProperties.COGNITO_WEB_KEY_URL, 
        "");
  }
}