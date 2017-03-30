# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :ello_stream, ecto_repos: []

config :ello_stream,
  prefix:                System.get_env("STREAM_SERVICE_PREFIX"),
  service_url:           System.get_env("STREAM_SERVICE_URL") || "http://localhost:8080",
  base_slop_factor:      String.to_float(System.get_env("ROSHI_BASE_SLOP_FACTOR") || "1.1"),
  nsfw_slop_factor:      String.to_float(System.get_env("ROSHI_NSFW_SLOP_FACTOR") || "0.15"),
  nudity_slop_factor:    String.to_float(System.get_env("ROSHI_NUDITY_SLOP_FACTOR") || "0.15"),
  block_slop_multiplier: String.to_float(System.get_env("ROSHI_BLOCK_SLOP_MULTIPLIER") || "0.001"),
  max_block_slop_factor: String.to_float(System.get_env("ROSHI_MAX_BLOCK_SLOP_FACTOR") || "1.1"),
  batches_per_request:   String.to_integer(System.get_env("ROSHI_BATCHES_PER_REQUEST") || "3"),
  roshi_pool_size:       String.to_integer(System.get_env("ROSHI_POOL_SIZE") || "100"),
  roshi_timeout:         String.to_integer(System.get_env("ROSHI_TIMEOUT") || "15000")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
