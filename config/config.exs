# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# By default, the umbrella project as well as each child
# application will require this configuration file, ensuring
# they all use the same configuration. While one could
# configure all applications here, we prefer to delegate
# back to each application for organization purposes.
import_config "../apps/*/config/config.exs"

# If local overrides exist, load them last. When in an app directory (/apps/ello_v2/) we must check down a dir.
if File.exists?("config/config.local.exs") || File.exists?("../../config/config.local.exs") do
  import_config "config.local.exs"
end
