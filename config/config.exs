# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :ello,
  ecto_repos: [Ello.Repo]

# Rails and ecto migrations are in-compatable.
# Rails is really true source of migrations, but ecto will try to read
# incompatable table of same name and blow up if we don't set this.
config :ello, Ello.Repo, migration_source: "ecto_migrations"

# Configures the endpoint
config :ello, Ello.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "bTJlM9Hi6IN16zJ0imPkI8NVqcDBCbc0K3i0WkSiy6KUHrgcJWhLipAo9b+UPnpW",
  render_errors: [view: Ello.ErrorView, accepts: ~w(json)],
  pubsub: [name: Ello.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
