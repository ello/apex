use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :ello_v2, Ello.V2.Endpoint,
  http: [port: nil],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [],
  server: false

config :ello_v2,
  social_icons_host: "social-icons.ello.co",
  asset_host: "assets.ello.co"

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20
