use Mix.Config

# config :true_dash
config :true_dash, Th.Dash.Endpoint,
  http: [port: nil],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [],
  server: false
