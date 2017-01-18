use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ello_v2, Ello.V2.Endpoint,
  http: [port: nil],
  server: false

config :ello_v2,
  social_icons_url: "https://social-icons.ello.co"

# Print only warnings and errors during test
config :logger, level: :warn
