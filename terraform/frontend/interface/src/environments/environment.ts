export const environment = {
  production: false,
  stage: 'dev',
  build: '0.0.1',
  buildDateTime: '2025-01-28 21:00 EST',
  resource_urls: {
    portal: 'portal.sdc-dev.dot.gov',
    portal_api: 'portal-api.sdc-dev.dot.gov/v1',
    guacamole: 'guacamole.sdc-dev.dot.gov',
    sftp: 'sftp.sdc-dev.dot.gov',
    sub1: 'sub1.sdc-dev.dot.gov',
    sub2: 'sub2.sdc-dev.dot.gov/v1',
  },

  auth_config: {
        authority: 'https://cognito-idp.us-east-1.amazonaws.com/us-east-1_XrR5IDCuP',
    redirectUrl: window.location.origin + '/login/redirect',
        clientId: '4binc5ifp081iu97i0dhb10q68',
        scope: 'email openid profile',
        responseType: 'code'
  },

  logout_url: 'https://usdot-sdc-dev.auth.us-east-1.amazoncognito.com/logout?client_id=4binc5ifp081iu97i0dhb10q68&logout_uri=' + window.location.origin + '/index.html'
};
