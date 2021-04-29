# Ello.Dispatch

Dispatch HTTP and Websocket requests to the proper umbrella app.

Ello.Dispatch is a normal Mix project, but using Phoenix as a dependency. The
Ello.Dispatch.Endpoint is the only Phoenix.Endpoint started when starting the
umbrella app. It accepts all HTTP and Websocket requests and ensures they are
forwarded to the proper application.

No authentication or other logic is performed.

- Websockets are dispatched in Ello.Dispatch.Endpoint
- HTTP requests are dispatches in Ello.Dispatch

## Configuration

Ello.Dispatch expects the following environmental variables in production (like)
environments:

- `PORT` – the port to run the http server on, typically provided by Heroku.
  Defaults to `5000`
- `WEBAPP_HOST` – the domain the app is running on as accessed by user, e.g.
  `ello.ninja`. Defaults to `ello.co`
- `ENVIRONMENT_NAME` – the name of the environment (e.g. `ninja`, `rainbow`,
  `production`, etc). Used in Honeybadger and New Relic to seperate environment
  reporting. Defaults to the Mix.env
- `NEW_RELIC_LICENSE_KEY` – if not present, New Relic data is not reported
- `HONEYBADGER_API_KEY` – if not present, exceptions are not reported
