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

        if config_env() == :prod do
          config :tower_rollbar,
            access_token: System.get_env("ROLLBAR_SERVER_ACCESS_TOKEN"),
            environment: System.get_env("DEPLOYMENT_ENV", to_string(config_env()))
        end
        """
      )
    end

    test "modifies existing tower configs if available" do
      test_project(
        files: %{
          "config/config.exs" => """
          import Config

          config :tower, reporters: [TowerEmail]
          """,
          "config/runtime.exs" => """
          import Config
          """
        }
      )
      |> Igniter.compose_task("tower_rollbar.install", [])
      |> assert_has_patch(
        "config/config.exs",
        """
        |import Config
        |
        - |config :tower, reporters: [TowerEmail]
        + |config :tower, reporters: [TowerEmail, TowerRollbar]
        """
      )
      |> assert_has_patch(
        "config/runtime.exs",
        """
        |import Config
        |
        + |if config_env() == :prod do
        + |  config :tower_rollbar,
        + |    access_token: System.get_env("ROLLBAR_SERVER_ACCESS_TOKEN"),
        + |    environment: System.get_env("DEPLOYMENT_ENV", to_string(config_env()))
        + |end
        + |
        """
      )
    end

    test "modifies existing tower configs if config_env() == :prod block exists" do
      test_project(
        files: %{
          "config/config.exs" => """
          import Config

          config :tower, reporters: [TowerEmail]
          """,
          "config/runtime.exs" => """
          import Config

          if config_env() == :prod do
            IO.puts("hello")
          end
          """
        }
      )
      |> Igniter.compose_task("tower_rollbar.install", [])
      |> assert_has_patch(
        "config/config.exs",
        """
        |import Config
        |
        - |config :tower, reporters: [TowerEmail]
        + |config :tower, reporters: [TowerEmail, TowerRollbar]
        """
      )
      |> assert_has_patch(
        "config/runtime.exs",
        """
        |if config_env() == :prod do
        |  IO.puts("hello")
        + |
        + |  config :tower_rollbar,
        + |    access_token: System.get_env("ROLLBAR_SERVER_ACCESS_TOKEN"),
        + |    environment: System.get_env("DEPLOYMENT_ENV", to_string(config_env()))
        |end
        |
        """
      )
    end

    test "does not modify existing tower_rollbar configs if config_env() == :prod block exists" do
      test_project(
        files: %{
          "config/config.exs" => """
          import Config

          config :tower, reporters: [TowerEmail, TowerRollbar]
          """,
          "config/runtime.exs" => """
          import Config

          if config_env() == :prod do
            config :tower_rollbar,
              access_token: System.get_env("ROLLBAR_SERVER_ACCESS_TOKEN"),
              environment: System.get_env("DEPLOYMENT_ENV", to_string(config_env()))
          end
          """
        }
      )
      |> Igniter.compose_task("tower_rollbar.install", [])
      |> assert_unchanged()
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
