# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :ello_v3,
  allow_graphiql: false,
  asset_host: System.get_env("ASSET_HOST")

import_config "#{Mix.env}.exs"
