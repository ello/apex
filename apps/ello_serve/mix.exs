defmodule Ello.Serve.Mixfile do
  use Mix.Project

  def project do
    [app: :ello_serve,
     version: "0.0.1",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.2",
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
    [mod: {Ello.Serve, []},
     extra_applications: [:logger]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  defp deps do
    [
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_html, "~> 2.10"},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:jason, "~> 1.0"},
      {:html_sanitize_ex, "~> 1.0.0"},
      {:timex, "~> 3.0"},

      {:ello_core, in_umbrella: true},
      {:ello_auth, in_umbrella: true},
      {:ello_search, in_umbrella: true},
      {:ello_stream, in_umbrella: true},
      {:ello_v2, in_umbrella: true}, # for image_url generation
   ]
  end
end
