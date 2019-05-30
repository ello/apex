use Mix.Config

config :true_dash,
  namespace: TH.TrueDash,
  ecto_repos: []

# Configures the endpoint
config :true_dash, Th.Dash.Endpoint,
  url: [host: "localhost"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n"

import_config "#{Mix.env}.exs"
