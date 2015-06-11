/* jshint node: true */

module.exports = function(environment) {
  var ENV = {
    modulePrefix: 'swag-ember',
    environment: environment,
    baseURL: '/',

    locationType: 'auto',

    contentSecurityPolicy: {
      'frame-src': '\'self\' http://static.ak.facebook.com https://s-static.ak.facebook.com https://www.facebook.com',
      'img-src': 'self https://www.facebook.com',
      'style-src': '\'self\' \'unsafe-inline\'',
      'script-src': '\'self\' http://connect.facebook.net https://graph.facebook.com https://www.facebook.com',
      'connect-src': '\'self\' ws://localhost:35729 ws://0.0.0.0:35729 http://0.0.0.0:4200/csp-report http://localhost:8000 http://learninglocker.{{provision__fqdn}}/data/xAPI/'
    },

    EmberENV: {
      FEATURES: {
        // Here you can enable experimental features on an ember canary build
        // e.g. 'with-controller': true
      }
    },

    APP: {
      xAPIEndpoint: "http://learninglocker.{{provision__fqdn}}/data/xAPI/",
      xAPIUsername: "{{learninglocker__xapi_user}}",
      xAPIPassword: "{{learninglocker__xapi_pass}}",

      // overide the login email with this email
      agentEmailOverride: '{{provision__admin_user}}@tunapanda.org',

      // set to true to disable api requests and use fixtures in models/swagmap
      useFixtures: true
    }
  };

  ENV['simple-auth'] = {
    store: 'simple-auth-session-store:local-storage',
    'authenticationRoute': 'index'
  };

  ENV['torii'] = {
    providers: {
      'facebook-connect': {
        appId: '256282564410162'
      }
    }
  };

  if (environment === 'development') {
    // ENV.APP.LOG_RESOLVER = true;
    // ENV.APP.LOG_ACTIVE_GENERATION = true;
    // ENV.APP.LOG_TRANSITIONS = true;
    // ENV.APP.LOG_TRANSITIONS_INTERNAL = true;
    // ENV.APP.LOG_VIEW_LOOKUPS = true;
  }

  if (environment === 'test') {
    // Testem prefers this...
    ENV.baseURL = '/';
    ENV.locationType = 'none';

    // keep test console output quieter
    ENV.APP.LOG_ACTIVE_GENERATION = false;
    ENV.APP.LOG_VIEW_LOOKUPS = false;

    ENV.APP.rootElement = '#ember-testing';
  }

  if (environment === 'production') {

  }

  return ENV;
};
