defmodule TowerRollbar.Rollbar.ItemTest do
  use ExUnit.Case
  doctest TowerRollbar.Rollbar.Item

  alias TowerRollbar.Rollbar

  test "from_exception" do
    Application.put_env(:tower_rollbar, :environment, "test")

    item =
      try do
        raise "a test"
      rescue
        exception in RuntimeError ->
          Rollbar.Item.from_exception(exception, __STACKTRACE__)
      end

    assert %{
      "data" => %{
        "environment" => "test",
        "timestamp" => _,
        "level" => "error",
        "body" => %{
          "trace" => %{
            "frames" => [],
            "exception" => %{
              "class" => "RuntimeError",
              "message" => "a test"
            }
          }
        }
      }
    } = item
  end
end
