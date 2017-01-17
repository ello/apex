# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :ello_dispatch, Ello.Dispatch.Endpoint,
  url:  [host: System.get_env("ELLO_DOMAIN") || "localhost"],
  http: [port: System.get_env("PORT") || 5000],
  render_errors: [view: Ello.Dispatch.ErrorView, accepts: ~w(json)]

config :ello_dispatch,
  ecto_repos: []

config :honeybadger, :environment_name, System.get_env("ENVIRONMENT_NAME") || Mix.env

import_config "#{Mix.env}.exs"
