defmodule Ello.Dispatch.Mixfile do
  use Mix.Project

  def project do
    [app: :ello_dispatch,
     version: "0.1.0",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.4",
     elixirc_options: [warnings_as_errors: Mix.env == :test],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Type "mix help compile.app" for more information
  def application do
    [extra_applications: [:logger],
     mod: {Ello.Dispatch.Application, []}]
  end

  # Type "mix help deps" for examples and options
  defp deps do
    [
      {:cowboy, "~> 1.1"},
      {:plug,   "~> 1.3"},
      {:phoenix, "~> 1.3.3"},
      {:honeybadger, "~> 0.7"},
      {:cors_plug, "~> 1.1"},

      {:newrelic_phoenix, github: "ello/newrelic_phoenix", branch: "master"},

      {:ello_v2,    in_umbrella: true},
      {:ello_v3,    in_umbrella: true},
      {:ello_feeds, in_umbrella: true},
      {:ello_serve, in_umbrella: true},

      {:th_dash, in_umbrella: true},
    ]
  end
end
