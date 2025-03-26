package org.apache.guacamole.auth.header;

import org.apache.guacamole.properties.StringGuacamoleProperty;


public class HTTPHeaderGuacamoleProperties
{
   public static final StringGuacamoleProperty HTTP_AUTH_HEADER = new StringGuacamoleProperty()
    {
      public String getName() {
         return "http-auth-header";
      }
    };

   public static final StringGuacamoleProperty HTTP_REQUEST_PARAM = new StringGuacamoleProperty()
    {
      public String getName() {
         return "http-request-param";
      }
    };
  
   public static final StringGuacamoleProperty COGNITO_WEB_KEY_URL = new StringGuacamoleProperty()
    {
      public String getName() {
         return "cognito-web-key-url";
      }
    };
}