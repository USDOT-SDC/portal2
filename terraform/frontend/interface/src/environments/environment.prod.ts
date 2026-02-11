export const environment = {
  production: true,
  stage: 'prod',
  build: '2.0.16',
  buildDateTime: '2026-02-11 15:00 EST',
  resource_urls: {
    portal: 'portal.sdc.dot.gov',
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
    scope: 'email openid profile',
    responseType: 'code'
  },

  logout_url: 'https://auth.portal.sdc.dot.gov/logout?client_id=51nhfldlrp6e62cdo360fh9o78&logout_uri=' + window.location.origin + '/index.html'
};
