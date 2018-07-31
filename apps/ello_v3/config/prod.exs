use Mix.Config

config :ello_v3,
  allow_graphiql: System.get_env("ALLOW_GRAPHIQL") == "true",
  asset_host: System.get_env("ASSET_HOST") || "assets%d.ello.co"
