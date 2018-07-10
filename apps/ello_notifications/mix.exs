defmodule Ello.Notifications.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ello_notifications,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env),
      elixirc_options: [warnings_as_errors: Mix.env == :test],
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def elixirc_paths(:test), do: ["lib", "test/support"]
  def elixirc_paths(_),     do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Ello.Notifications.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.0"},
      {:jason, "~> 1.0"},

      {:ello_core, in_umbrella: true},
    ]
  end
end
