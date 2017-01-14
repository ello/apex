use Mix.Config

# Rails and ecto migrations are in-compatable.
# Rails is really true source of migrations, but ecto will try to read
# incompatable table of same name and blow up if we don't set this.
config :ello_core, Ello.Core.Repo,
  migration_source: "ecto_migrations"

config :ello_core,
  ecto_repos: [Ello.Core.Repo]

import_config "#{Mix.env}.exs"
