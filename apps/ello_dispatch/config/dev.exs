use Mix.Config

config :ello_dispatch, Ello.Dispatch.Endpoint,
  debug_errors: true,
  code_reloader: true,
  check_origin: false

config :honeybadger,
  api_key: "",
  exclude_envs: [:dev, :test]
