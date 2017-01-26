use Mix.Config

config :ello_auth,
  ecto_repos: [],
  user_lookup_mfa: {Ello.Core.Network, :load_current_user}

import_config "#{Mix.env}.exs"
