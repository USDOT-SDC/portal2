export const environment = {
  production: true,
  stage: 'prod',
  build: '1.0.1',
  buildDateTime: '2025-03-21 14:45 EST',
  resource_urls: {
    portal: 'sub1.sdc.dot.gov',
    portal_api: 'portal-api.sdc.dot.gov/v1',
    guacamole: 'guacamole.sdc.dot.gov',
    sftp: 'sftp.sdc.dot.gov',
    sub1: 'sub1.sdc.dot.gov',
    sub2: 'sub2.sdc.dot.gov/v1',
  },

  auth_config: {
    authority: 'https://cognito-idp.us-east-1.amazonaws.com/us-east-1_TgCjgpriJ',
    redirectUrl: window.location.origin + '/login/redirect',
    clientId: '51nhfldlrp6e62cdo360fh9o78',
    scope: 'email openid phone profile',
    responseType: 'code'
  },

  logout_url: 'https://usdot-sdc-prod.auth.us-east-1.amazoncognito.com/logout?client_id=51nhfldlrp6e62cdo360fh9o78&logout_uri=' + window.location.origin + '/index.html'
};
