defmodule TowerRollbar.MixProject do
  use Mix.Project

  def project do
    [
      app: :tower_rollbar,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tower, github: "mimiquate/tower"},
      {:plug, "~> 1.16"},

      # Included only for Rollbax.Client for now.
      # Consider implementing our own client?
      {:rollbax, "~> 0.11.0"}
    ]
  end
end
