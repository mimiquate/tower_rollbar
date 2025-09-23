# TODO: Remove this conditonal once we only run tests against tower v0.8+
if Code.ensure_loaded?(Tower.Igniter) do
  defmodule Mix.Tasks.TowerRollbar.Task.InstallTest do
    use ExUnit.Case, async: true
    import Igniter.Test

    test "generates everything from scratch" do
      test_project()
      |> Igniter.compose_task("tower_rollbar.install", [])
      |> assert_creates(
        "config/config.exs",
        """
        import Config
        config :tower, reporters: [TowerRollbar]
        """
      )
      |> assert_creates(
        "config/runtime.exs",
        """
        import Config

        config :tower_rollbar,
          access_token: System.get_env("ROLLBAR_SERVER_ACCESS_TOKEN"),
          environment: System.get_env("DEPLOYMENT_ENV", to_string(config_env()))
        """
      )
    end

    test "is idempotent" do
      test_project()
      |> Igniter.compose_task("tower_rollbar.install", [])
      |> apply_igniter!()
      |> Igniter.compose_task("tower_rollbar.install", [])
      |> assert_unchanged()
    end
  end
end
