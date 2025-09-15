export const environment = {
  production: false,
  stage: 'dev',
  build: '2.0.7',
  buildDateTime: '2025-09-15 09:45 EST',
  resource_urls: {
    portal: 'portal.sdc-dev.dot.gov',
    portal_api: 'portal-api.sdc-dev.dot.gov/v1',
    guacamole: 'guacamole.sdc-dev.dot.gov',
    sftp: 'sftp.sdc-dev.dot.gov',
    sub1: 'sub1.sdc-dev.dot.gov',
    sub2: 'sub2.sdc-dev.dot.gov/v1',
  },

  auth_config: {
    authority: 'https://cognito-idp.us-east-1.amazonaws.com/us-east-1_Hfsr83Wne',
    redirectUrl: window.location.origin + '/login/redirect',
    clientId: 'hvac1g2q751nd3bvn02nu55v0',
    scope: 'email openid profile',
    responseType: 'code'
  },

  logout_url: 'https://auth.portal.sdc-dev.dot.gov/logout?client_id=hvac1g2q751nd3bvn02nu55v0&logout_uri=' + window.location.origin + '/index.html'
};
