defmodule Ello.Search.Mixfile do
  use Mix.Project

  def project do
    [app: :ello_search,
     version: "0.1.0",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     elixirc_options: [warnings_as_errors: Mix.env == :test],
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
     mod: {Ello.Search.Application, []}]
  end

  defp deps do
    [
      {:elastix, "~> 0.7.1"},
      {:ex_aws, "~> 2.1"},
      {:jason,  "~> 1.0"},
      {:timex, "~> 3.0"},
      {:html_sanitize_ex, "~> 1.0.0"},

      {:ello_core, in_umbrella: true},
    ]
  end
end
