defmodule Ello.Core.Mixfile do
  use Mix.Project

  def project do
    [app: :ello_core,
     version: "0.1.0",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     elixirc_options: [warnings_as_errors: Mix.env == :test],
     aliases: aliases(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def elixirc_paths(:test), do: ["lib", "test/support"]
  def elixirc_paths(_),     do: ["lib"]

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger],
     mod: {Ello.Core.Application, []}]
  end

  def aliases do
    [
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  defp deps do
    [
      {:phoenix_ecto, "~> 4.0"},
      {:postgrex,     ">= 0.0.0"},
      {:redix,        "~> 0.10"},
      {:jason,        "~> 1.0"},
      {:ex_machina,   "~> 2.3"},
      {:timex,        "~> 3.0"},
      {:ecto,         "~> 3.0"},
      {:ecto_sql,     "~> 3.0"},

      # 2019-05-07 - the 'newrelic' repo has out of date dependencies, disabling
      # newrelic until we have bandwidth to update our code, maybe to new_relic
      # {:newrelic_phoenix, github: "ello/newrelic_phoenix", branch: "master"},
    ]
  end
end
