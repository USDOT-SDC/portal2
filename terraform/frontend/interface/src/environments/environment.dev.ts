export const environment = {
  production: false,
  stage: 'dev',
  build: '0.0.1',
  buildDateTime: '2025-01-24 02:59 UTC',
  resource_urls: {
    portal: 'portal.sdc-dev.dot.gov',
    portal_api: 'portal-api.sdc-dev.dot.gov/v1',
    guacamole: 'guacamole.sdc-dev.dot.gov',
    sftp: 'sftp.sdc-dev.dot.gov',
    sub1: 'sub1.sdc-dev.dot.gov',
    sub2: 'sub2.sdc-dev.dot.gov/v1',
  },

  amplify_config: {
    Auth: {
      Cognito: {
        userPoolId: "us-east-1_XrR5IDCuP",
        userPoolClientId: "4binc5ifp081iu97i0dhb10q68",
        loginWith: {
          oauth: {
            domain: "usdot-sdc-dev.auth.us-east-1.amazoncognito.com",
            scopes: ["aws.cognito.signin.user.admin","email","openid","phone","profile"],
            redirectSignIn: [window.location.origin + "/login/redirect"],
            redirectSignOut: [window.location.origin + '/index.html'],
            responseType: "token",
          }
        }
      }
    }
  }
};
