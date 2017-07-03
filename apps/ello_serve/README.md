# Ello.Serve

HTML Server for webapp.

Ello.Serve hosts HTML built by the webapp, injects environment specific config,
meta attributes, and fallback noscript content. The HTML store is shared across
all of Ello's environments allowing any build of the webapp to be previewed
anywhere.

## Version Storage and Activation.

The Ello.Serve version store stores and provides APIs for managing different
versions of apps. All versions for each app are available in all environments,
however you can choose to make one version the default active version in each
environment.

### POST /api/serve/v1/versions

Accepts a json object with 'version', 'app', and 'html' keys. Stores the version
in a shared Redis instance. Requires basicauth username/password.

This endpoint is used to push new versions to the shared store. When a new 
version is published a slack notification is pushed, allowing preview and
activation from slack.

### POST /api/serve/v1/versions/activate

Accepts a json object with 'version', 'app', and 'environment' keys. Activates
the version as default for the given environment.

## Serving webapp

When any GET request to known webapp url is made the following steps happen:

1. The version requested is determined (either the default active version, or the explicitly requested version)
2. The version is retreived from the version store (redis).
3. The application determines if you are a known user with javascript support (you have logged in via js and had a cookie set).
4. The proper controller is routed to. When a paramatarized route is accessed (eg, a username or post token is present) we ensure the request object exists, if not we return a 404.
5. Any supplementary resources are loaded (non-known users)
6. Environment specific configuration is injected into the html.
7. Meta tags with the proper OG tags are injected into the html.
8. Fallback noscript content is rendered for non-known users.
9. The html is returned.
10. The browser boots the webapp and renders appropriately


## Configuration

Ello.Serve expects the following environmental variables in production
(like) environments:

* WEBAPP_HOST - The public domain name, e.g. `ello.co` or
  `ello-fg-rainbow.herokuapp.com`.
* APPLE_APP_ID - The apple app id of the Ello iOS app.
* WEBAPP_CLIENT_ID - OAuth client id for webapp.
* WEBAPP_CLIENT_SECRET - OAuth client secret for webapp.
* SERVE_REDIS_URL - URL of the shared redis version store.
* SERVE_ENVIRONMENTS - A comma seperated list of environments that Ello.Serve should support, eg: "ninja,rainbow,production"
* SERVE_CURRENT_ENVIRONMENT - the current environment, eg: "rainbow"
* SERVE_API_USERNAME - username to create/activate versions
* SERVE_API_PASSWORD - password to create/activate versions
* SERVE_SLACK_WEBHOOK_URL - slack webhook url for version/activation callbacks
* SERVE_SLACK_TOKEN - token to validate slack callbacks.
