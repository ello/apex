# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :ello_v2,
  namespace: Ello.V2,
  webapp_host: System.get_env("WEBAPP_HOST"),
  ecto_repos: [],
  editorial_stream_kind_size: System.get_env("EDITORIAL_STREAM_KIND_SIZE") || 5

# Configures the endpoint
config :ello_v2, Ello.V2.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: Ello.V2.ErrorView, accepts: ~w(json)],
  pubsub: [name: Ello.V2.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
