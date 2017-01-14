# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :ello_dispatch, Ello.Dispatch.Endpoint,
  url:  [host: System.get_env("ELLO_DOMAIN") || "localhost"],
  http: [port: System.get_env("PORT") || 5000]

config :ello_dispatch,
  ecto_repos: []

import_config "#{Mix.env}.exs"
