defmodule TowerRollbarTest do
  use ExUnit.Case
  doctest TowerRollbar

  setup do
    bypass = Bypass.open()

    Application.put_env(:tower, :reporters, [TowerRollbar.Reporter])
    Application.put_env(:tower_rollbar, :rollbar_base_url, "http://localhost:#{bypass.port}/")
    Application.put_env(:tower_rollbar, :environment, :test)
    Application.put_env(:tower_rollbar, :access_token, "fake-token")
    Application.put_env(:tower_rollbar, :enabled, true)

    Tower.attach()

    on_exit(fn ->
      Tower.detach()
    end)

    {:ok, bypass: bypass}
  end

  @tag capture_log: true
  test "reports arithmetic error", %{bypass: bypass} do
    # ref message synchronization trick copied from
    # https://github.com/PSPDFKit-labs/bypass/issues/112
    parent = self()
    ref = make_ref()

    Bypass.expect_once(bypass, "POST", "/item", fn conn ->
      {:ok, body, conn} = Plug.Conn.read_body(conn)

      assert(
        %{
          "data" => %{
            "environment" => "test",
            "timestamp" => _,
            "level" => "error",
            "body" => %{
              "trace" => %{
                "exception" => %{
                  "class" => "ArithmeticError",
                  "message" => "bad argument in arithmetic expression"
                },
                "frames" => [
                  %{
                    "method" => _,
                    "filename" => _,
                    "lineno" => _
                  },
                  %{
                    "method" => _,
                    "filename" => _,
                    "lineno" => _
                  },
                  %{
                    "method" =>
                      ~s(anonymous fn/0 in TowerRollbarTest."test reports arithmetic error"/1),
                    "filename" => "test/tower_rollbar_test.exs",
                    "lineno" => 77
                  }
                ]
              }
            }
          }
        } = Jason.decode!(body)
      )

      send(parent, {ref, :sent})

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(200, Jason.encode!(%{"ok" => true}))
    end)

    in_unlinked_process(fn ->
      1 / 0
    end)

    assert_receive({^ref, :sent}, 500)
  end

  defp in_unlinked_process(fun) when is_function(fun, 0) do
    {:ok, pid} = Task.Supervisor.start_link()

    pid
    |> Task.Supervisor.async_nolink(fun)
    |> Task.yield()
  end
end
