use Mix.Config

config :ello_core,
  redis_url: System.get_env("REDIS_URL")

config :ello_core, Ello.Core.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  ssl: true,
  pool_size: String.to_integer(System.get_env("ECTO_POOL_SIZE") || "20")
