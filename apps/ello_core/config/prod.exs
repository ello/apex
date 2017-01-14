use Mix.Config

config :ello_core,
  redis_url: System.get_env("REDIS_URL")

config :ello_core, Ello.Core.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: {:system, "DATABASE_URL"},
  ssl: true,
  pool_size: 20
