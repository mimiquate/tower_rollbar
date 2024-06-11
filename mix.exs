defmodule TowerRollbar.MixProject do
  use Mix.Project

  @description "Error and message reporting to Rollbar"
  @source_url "https://github.com/mimiquate/tower_rollbar"
  @version "0.1.0"

  def project do
    [
      app: :tower_rollbar,
      description: @description,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),

      # Docs
      name: "TowerRollbar",
      source_url: @source_url,
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :public_key, :inets]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"},
      {:tower, github: "mimiquate/tower"},
      {:plug, "~> 1.16"},

      # Only needed for Erlang < 25
      {:castore, "~> 1.0", optional: true}
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
