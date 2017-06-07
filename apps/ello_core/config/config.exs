use Mix.Config

# Rails and ecto migrations are in-compatable.
# Rails is really true source of migrations, but ecto will try to read
# incompatable table of same name and blow up if we don't set this.
config :ello_core, Ello.Core.Repo,
  migration_source: "ecto_migrations",
  loggers: [{Ecto.LogEntry, :log, []}, NewRelicPhoenix.Ecto],
  after_connect: {Ello.Core.Repo, :after_connect, []}

config :ello_core,
  ecto_repos: [Ello.Core.Repo],
  redis_pool_size: String.to_integer(System.get_env("REDIS_POOL_SIZE") || "5"),
  redis_timeout: String.to_integer(System.get_env("REDIS_TIMEOUT") || "10000"),
  user_post_query_timeout: String.to_integer(System.get_env("USER_POST_QUERY_TIMEOUT") || "10000"),
  pg_statement_timeout: (System.get_env("PG_STATEMENT_TIMEOUT") || "1min")

import_config "#{Mix.env}.exs"
