# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :ello_stream,
  prefix: nil,
  env: Mix.env, #todo, normalize to rails v
  base_slop_factor:      String.to_float(System.get_env("ROSHI_BASE_SLOP_FACTOR") || "1.1"),
  nsfw_slop_factor:      String.to_float(System.get_env("ROSHI_NSFW_SLOP_FACTOR") || "0.25"),
  nudity_slop_factor:    String.to_float(System.get_env("ROSHI_NUDITY_SLOP_FACTOR") || "0.25"),
  block_slop_multiplier: String.to_float(System.get_env("ROSHI_BLOCK_SLOP_MULTIPLIER") || "0.001"),
  max_block_slop_factor: String.to_float(System.get_env("ROSHI_MAX_BLOCK_SLOP_FACTOR") || "1.1"),
  batches_per_request:   String.to_integer(System.get_env("ROSHI_BATCHES_PER_REQUEST") || "3")

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :ello_stream, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:ello_stream, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
