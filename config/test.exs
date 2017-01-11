use Mix.Config

config :ello,
  jwt_alg: :hs256,
  jwt_secret: "SECRET"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ello, Ello.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :ello, Ello.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "ello_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
