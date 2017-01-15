use Mix.Config

config :ello_auth, ecto_repos: []

import_config "#{Mix.env}.exs"
