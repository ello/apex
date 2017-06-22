# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :ello_serve,
  namespace: Ello.Serve,
  ecto_repos: [],
  apple_app_id: System.get_env("APPLE_APP_ID"),
  webapp_host: System.get_env("WEBAPP_HOST"),
  webapp_oauth_client_id: System.get_env("WEBAPP_CLIENT_ID") || "client_id",
  webapp_oauth_client_secret: System.get_env("WEBAPP_CLIENT_SECRET") || "client_secret",
  redis_url: System.get_env("SERVE_REDIS_URL") || "redis://localhost:6379",
  redis_pool_size: String.to_integer(System.get_env("SERVE_REDIS_POOL_SIZE") || "5"),
  redis_timeout: String.to_integer(System.get_env("SERVE_REDIS_TIMEOUT") || "5000"),
  environments: String.split(System.get_env("SERVE_ENVIRONMENTS") || "test,dev", ","),
  current_environment: System.get_env("SERVE_CURRENT_ENVIRONMENT") || "test",
  api_username: System.get_env("SERVE_API_USERNAME"),
  api_password: System.get_env("SERVE_API_PASSWORD")




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
