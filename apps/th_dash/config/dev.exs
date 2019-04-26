use Mix.Config

# config :th_dash
config :th_dash, Th.Dash.Endpoint,
  http: [port: nil],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [],
  server: false
