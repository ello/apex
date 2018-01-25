defmodule Ello.V3.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ello_v3,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Ello.V3.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:absinthe_plug, "~> 1.4"},
      {:plug,          "~> 1.3"},
      {:ello_core,   in_umbrella: true},
      {:ello_stream, in_umbrella: true},
      {:ello_search, in_umbrella: true},
    ]
  end
end
