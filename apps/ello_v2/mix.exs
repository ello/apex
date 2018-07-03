defmodule Ello.V2.Mixfile do
  use Mix.Project

  def project do
    [app: :ello_v2,
     version: "0.0.1",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Ello.V2, []},
     extra_applications: [:logger]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.3"},
      {:phoenix_pubsub, "~> 1.0"},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:ex_json_schema, "~> 0.5.3", only: :test},
      {:httpoison, "~> 1.0"},
      {:html_sanitize_ex, "~> 1.0.0"},
      {:curtail, "~> 0.1"},
      {:phoenix_etag, "~> 0.1.0"},
      {:jason, "~> 1.0"},

      {:ello_core,   in_umbrella: true},
      {:ello_auth,   in_umbrella: true},
      {:ello_events, in_umbrella: true},
      {:ello_stream, in_umbrella: true},
      {:ello_search, in_umbrella: true},
      {:ello_grandstand, in_umbrella: true},
    ]
  end
end
