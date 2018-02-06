# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :ello_v3,
  webapp_host: System.get_env("WEBAPP_HOST")

#     import_config "#{Mix.env}.exs"
