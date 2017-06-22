use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ello_serve, Ello.Serve.Endpoint,
  http: [port: 4001],
  server: false

config :ello_serve,
  apple_app_id: "1234567",
  webapp_host: "ello.co",
  api_username: "test",
  api_password: "only"


# Print only warnings and errors during test
config :logger, level: :warn
