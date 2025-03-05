export const environment = {
  production: ${production},
  stage: '${stage}',
  build: '${build}',
  buildDateTime: '',
  resource_urls: {
    portal: '${portal_url}',
    portal_api: '${portal_api_url}',
    guacamole: '${guacamole_url}',
    sftp: '${sftp_url}',
    sub1: '${sub1_url}',
    sub2: '${sub2_url}',
  },

  auth_config: {
    authority: 'https://cognito-idp.us-east-1.amazonaws.com/${user_pool_id}',
    redirectUrl: window.location.origin + '/login/redirect',
    clientId: '${user_pool_client_id}',
    scope: '${user_pool_client_scopes}',
    responseType: 'code'
  },

  logout_url: 'https://${user_pool_domain}/logout?client_id=${user_pool_client_id}&logout_uri=' + window.location.origin + '/index.html'
};
