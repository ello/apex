defmodule Ello.Events.Mixfile do
  use Mix.Project

  def project do
    [app: :ello_events,
     version: "0.1.0",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {Ello.Events.Application, []}]
  end

  defp deps do
    [
      {:uuid,   "~> 1.0"},
      {:poison, "~> 3.1"},

      {:ello_core, in_umbrella: true},
    ]
  end
end
