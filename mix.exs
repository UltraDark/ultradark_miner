defmodule Miner.Mixfile do
  use Mix.Project

  def project do
    [
      app: :elixium_miner,
      version: "1.0.2",
      elixir: "~> 1.7",
      start_permanent: true,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Miner, []},
      extra_applications: [
        :ssl,
        :logger,
        :inets,
        :crypto,
        :elixium_core
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:local_dependency, path: "../elixium_core", app: false},
      #{:elixium_core, "~> 0.3"},
      {:decimal, "~> 1.0"},
      {:poison, "~> 3.1"},
      {:distillery, "~> 2.0"}
    ]
  end
end
