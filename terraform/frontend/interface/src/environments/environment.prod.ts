export const environment = {
  production: false,
  stage: 'prod',
  build: '0.0.1',
  buildDateTime: '2025-01-28 21:00 EST',
  resource_urls: {
    portal: 'portal.sdc.dot.gov',
    portal_api: 'portal-api.sdc.dot.gov/v1',
    guacamole: 'guacamole.sdc.dot.gov',
    sftp: 'sftp.sdc.dot.gov',
    sub1: 'sub1.sdc.dot.gov',
    sub2: 'sub2.sdc.dot.gov/v1',
  },

  auth_config: {
        authority: 'https://cognito-idp.us-east-1.amazonaws.com/us-east-1_3time3is9',
        redirectUrl: window.location.origin + '/login/redirect',
        clientId: '13plus13is26__13plus13is26',
        scope: 'email openid profile',
        responseType: 'code'
  },

  logout_url: 'https://usdot-sdc-prod.auth.us-east-1.amazoncognito.com/logout?client_id=13plus13is26__13plus13is26&logout_uri=' + window.location.origin + '/index.html'
};
