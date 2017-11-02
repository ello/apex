# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

use Mix.Config

config :ello_grandstand, ecto_repos: []

config :ello_grandstand,
  service_url:        System.get_env("GRANDSTAND_URL") || "http://localhost:3000",
  grandstand_timeout: String.to_integer(System.get_env("GRANDSTAND_TIMEOUT") || "15000")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
