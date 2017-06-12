# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :ello_serve,
  namespace: Ello.Serve

# Configures the endpoint
config :ello_serve, Ello.Serve.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "lSJy8ebzMtK1z4TNiYXhnLrYRjg7YDgpLR/FRI2HBUuSTbbMxwlq7qj46M5oTCmD",
  render_errors: [view: Ello.Serve.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Ello.Serve.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
