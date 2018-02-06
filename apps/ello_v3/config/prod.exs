use Mix.Config

config :ello_v3,
  asset_host: System.get_env("ASSET_HOST") || "assets%d.ello.co"
