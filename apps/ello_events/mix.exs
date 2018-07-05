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
     elixirc_options: [warnings_as_errors: Mix.env == :test],
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
      {:uuid,    "~> 1.0"},
      {:jason,   "~> 1.0"},
      {:phoenix, "~> 1.3.0"},

      {:ello_core, in_umbrella: true},
    ]
  end
end
