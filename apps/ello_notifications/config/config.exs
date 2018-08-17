use Mix.Config

config :ello_notifications,
  stream_service_url:     System.get_env("NOTIFICATION_STREAMS_URL") || "http://localhost:3000",
  stream_service_timeout: String.to_integer(System.get_env("NOTIFICATION_STREAMS_TIMEOUT") || "15000")

import_config "#{Mix.env}.exs"
