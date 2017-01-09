defmodule Ello.Mixfile do
  use Mix.Project

  def project do
    [apps_path: "apps",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  defp deps do
    []
  end

  defp aliases do
    [
      "server": ["phoenix.server"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"],
    ]
  end
end
