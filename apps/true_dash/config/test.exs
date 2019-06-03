use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :true_dash, TH.TrueDash.Endpoint,
  url: [host: "localhost"]

# config :true_dash

# Print only warnings and errors during test
config :logger, level: :warn
