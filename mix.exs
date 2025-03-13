defmodule TowerRollbar.MixProject do
  use Mix.Project

  @description "Error tracking and reporting to Rollbar"
  @source_url "https://github.com/mimiquate/tower_rollbar"
  @changelog_url @source_url <> "/blob/-/CHANGELOG.md"
  @version "0.6.3"

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
        access_token: nil,
        rollbar_base_url: "https://api.rollbar.com/api/1"
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tower, "~> 0.7.1 or ~> 0.8.0"},
      {:plug, "~> 1.14"},

      # Optional
      # Only needed for Elixir < 1.18
      {:jason, "~> 1.4", optional: true},
      # Only needed for Erlang < 25
      {:castore, "~> 1.0", optional: true},

      # Dev
      {:ex_doc, "~> 0.37.1", only: :dev, runtime: false},
      {:blend, "~> 0.4.0", only: :dev},

      # Test
      {:test_server, "~> 0.1.20", only: :test},
      {:plug_cowboy, "~> 2.7", only: :test},
      {:bandit, "~> 1.5", only: :test}
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => @changelog_url
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end
end
