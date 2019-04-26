use Mix.Config

config :th_dash,
  namespace: TH.Dash,
  ecto_repos: []

# Configures the endpoint
config :th_dash, Th.Dash.Endpoint,
  url: [host: "localhost"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n"

import_config "#{Mix.env}.exs"
