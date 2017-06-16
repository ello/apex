use Mix.Config

config :ello_auth,
  ecto_repos: [],
  user_lookup_mfa: {Ello.Core.Network, :load_current_user},
  auth_host: System.get_env("AUTH_HOST") || System.get_env("WEBAPP_HOST") || "ello.co"

import_config "#{Mix.env}.exs"
