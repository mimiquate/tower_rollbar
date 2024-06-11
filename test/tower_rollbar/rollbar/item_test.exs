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
                   "frames" => [
                     %{
                       "method" => _,
                       "filename" => "lib/ex_unit/runner.ex",
                       "lineno" => _
                     },
                     %{
                       "method" => _,
                       "filename" => "timer.erl",
                       "lineno" => _
                     },
                     %{
                       "method" => _,
                       "filename" => "lib/ex_unit/runner.ex",
                       "lineno" => _
                     },
                     %{
                       "method" => ~s(TowerRollbar.Rollbar.ItemTest."test from_exception"/1),
                       "filename" => "test/tower_rollbar/rollbar/item_test.exs",
                       "lineno" => 12
                     }
                   ],
                   "exception" => %{
                     "class" => "RuntimeError",
                     "message" => "a test"
                   }
                 }
               }
             }
           } = item
  end

  test "from_message" do
    Application.put_env(:tower_rollbar, :environment, "test")

    item = Rollbar.Item.from_message("something interesting happened")

    assert %{
             "data" => %{
               "environment" => "test",
               "timestamp" => _,
               "level" => "info",
               "body" => %{
                 "message" => %{
                   "body" => "something interesting happened"
                 }
               }
             }
           } = item
  end
end
