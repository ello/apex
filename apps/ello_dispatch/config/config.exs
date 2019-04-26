# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :ello_dispatch, Ello.Dispatch.Endpoint,
  url:  [host: System.get_env("WEBAPP_HOST") || "localhost"],
  http: [port: System.get_env("PORT") || 5000],
  render_errors: [view: Ello.Dispatch.ErrorView, accepts: ~w(json)],
  instrumenters: [
    # 2019-05-07 - the 'newrelic' repo has out of date dependencies, disabling
    # newrelic until we have bandwidth to update our code, maybe to new_relic
    # NewRelicPhoenix.Endpoint
  ]

config :ello_dispatch,
  ecto_repos: []

env_name = case System.get_env("ENVIRONMENT_NAME") do
  nil -> Mix.env
  ""  -> Mix.env
  str -> String.to_atom(str)
end

config :honeybadger,
  environment_name: env_name,
  exclude_envs: [:dev, :test]


# 2019-05-07 - the 'newrelic' repo has out of date dependencies, disabling
# newrelic until we have bandwidth to update our code, maybe to new_relic
# config :newrelic_phoenix,
#   application_name: "Elixir API - #{env_name}",
#   license_key: {:system, "NEW_RELIC_LICENSE_KEY"}


import_config "#{Mix.env}.exs"
