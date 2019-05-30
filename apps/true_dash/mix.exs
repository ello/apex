defmodule TH.TrueDash.Mixfile do
  use Mix.Project

  def project do
    [app: :true_dash,
     version: "0.1.0",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     elixirc_options: [warnings_as_errors: Mix.env == :test],
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def elixirc_paths(:test), do: ["lib", "web", "test/support"]
  def elixirc_paths(_),     do: ["lib", "web"]

  def application do
    [mod: {TH.TrueDash, []},
     extra_applications: [:logger]]
  end

  defp deps do
    [
      {:phoenix, "~> 1.3.3"},
      {:cowboy, "~> 1.0"},
      {:httpoison, "~> 1.4"},
      {:hackney, "~> 1.12"},
      {:nimble_csv, "~> 0.6.0"},
      {:html_entities, "~> 0.4.0"},

      {:ello_auth,   in_umbrella: true},
    ]
  end
end
