use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :th_dash, TH.Dash.Endpoint,
  url: [host: "localhost"]

# config :th_dash

# Print only warnings and errors during test
config :logger, level: :warn
