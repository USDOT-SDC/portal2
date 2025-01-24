export const environment = {
  production: ${production},
  stage: '${stage}',
  build: '${build}',
  buildDateTime: '${build_datetime}',
  resource_urls: {
    portal: '${portal_url}',
    portal_api: '${portal_api_url}',
    guacamole: '${guacamole_url}',
    sftp: '${sftp_url}',
    sub1: '${sub1_url}',
    sub2: '${sub2_url}',
  },

  amplify_config: {
    Auth: {
      Cognito: {
        userPoolId: "${user_pool_id}",
        userPoolClientId: "${user_pool_client_id}",
        loginWith: {
          oauth: {
            domain: "${user_pool_domain}",
            scopes: ${user_pool_client_scopes},
            redirectSignIn: [window.location.origin + "/login/redirect"],
            redirectSignOut: [window.location.origin + '/index.html'],
            responseType: "token",
          }
        }
      }
    }
  },

};
