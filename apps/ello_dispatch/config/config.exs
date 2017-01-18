# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :ello_dispatch, Ello.Dispatch.Endpoint,
  url:  [host: System.get_env("ELLO_DOMAIN") || "localhost"],
  http: [port: System.get_env("PORT") || 5000],
  render_errors: [view: Ello.Dispatch.ErrorView, accepts: ~w(json)],
  instrumenters: [Ello.Dispatch.NewRelic]

config :ello_dispatch,
  ecto_repos: []

env_name = System.get_env("ENVIRONMENT_NAME") || Mix.env

config :honeybadger,
  environment_name: env_name

config :discorelic,
  application_name: "Elixir API - #{env_name}",
  license_key: System.get_env("NEW_RELIC_LICENSE_KEY")


import_config "#{Mix.env}.exs"
