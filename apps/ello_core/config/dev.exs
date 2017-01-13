use Mix.Config

config :ello_core,
  redis_url: "redis://localhost:6379"

config :ello_core, Ello.Core.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "ello_development",
  hostname: "localhost",
  pool_size: 10
