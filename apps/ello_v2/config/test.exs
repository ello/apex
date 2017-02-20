use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ello_v2, Ello.V2.Endpoint,
  http: [port: nil],
  server: false

config :ello_v2,
  social_icons_host: "social-icons.ello.co",
  asset_host: "assets.ello.co",
  webapp_host: "ello.co"

# Print only warnings and errors during test
config :logger, level: :warn


# Get json schemas from ninja.
config :ex_json_schema,
  :remote_schema_resolver, fn(url) ->
    Ello.V2.JsonSchema.resolve(url)
  end
