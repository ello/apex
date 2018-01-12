# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :ello_dispatch, Ello.Dispatch.Endpoint,
  url:  [host: System.get_env("WEBAPP_HOST") || "localhost"],
  http: [port: System.get_env("PORT") || 5000],
  render_errors: [view: Ello.Dispatch.ErrorView, accepts: ~w(json)],
  instrumenters: [NewRelicPhoenix.Endpoint]

config :ello_dispatch,
  ecto_repos: []

env_name = System.get_env("ENVIRONMENT_NAME") || Mix.env

config :honeybadger,
  environment_name: env_name,
  exclude_envs: [:dev, :test]


config :newrelic_phoenix,
  application_name: "Elixir API - #{env_name}",
  license_key: {:system, "NEW_RELIC_LICENSE_KEY"}


import_config "#{Mix.env}.exs"
