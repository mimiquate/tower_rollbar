defmodule TowerRollbar.MixProject do
  use Mix.Project

  @description "A Rollbar reporter for Tower error handler"
  @source_url "https://github.com/mimiquate/tower_rollbar"
  @version "0.2.0"

  def project do
    [
      app: :tower_rollbar,
      description: @description,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      package: package(),

      # Docs
      name: "TowerRollbar",
      source_url: @source_url,
      docs: docs()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :public_key, :inets],
      env: [
        rollbar_base_url: "https://api.rollbar.com/api/1"
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"},
      {:tower, "~> 0.4.0"},
      {:plug, "~> 1.14"},

      # Only needed for Erlang < 25
      {:castore, "~> 1.0", optional: true},

      # Dev
      {:ex_doc, "~> 0.34.2", only: :dev, runtime: false},
      {:blend, "~> 0.4.0", only: :dev},

      # Test
      {:bypass, "~> 2.1", only: :test},
      {:plug_cowboy, "~> 2.7", only: :test}
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end

  defp docs do
    [
      extras: ["README.md"]
    ]
  end
end
