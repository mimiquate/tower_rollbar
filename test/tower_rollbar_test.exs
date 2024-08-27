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
  test "reports arithmetic error when a Plug.Conn NOT present", %{bypass: bypass} do
    # ref message synchronization trick copied from
    # https://github.com/PSPDFKit-labs/bypass/issues/112
    parent = self()
    ref = make_ref()

    Bypass.expect_once(bypass, "POST", "/item", fn conn ->
      {:ok, body, conn} = Plug.Conn.read_body(conn)

      assert(
        %{
          "data" => %{
            "uuid" => _,
            "environment" => "test",
            "timestamp" => _,
            "level" => "error",
            "body" => %{
              "trace" => %{
                "exception" => %{
                  "class" => "ArithmeticError",
                  "message" => "bad argument in arithmetic expression"
                },
                "frames" => frames
              }
            }
          }
        } = Jason.decode!(body)
      )

      assert(
        %{
          "method" =>
            ~s(anonymous fn/0 in TowerRollbarTest."test reports arithmetic error when a Plug.Conn NOT present"/1),
          "filename" => "test/tower_rollbar_test.exs",
          "lineno" => 70
        } = List.last(frames)
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

  @tag capture_log: true
  test "reports arithmetic error when a Plug.Conn IS present with Plug.Cowboy", %{bypass: bypass} do
    # ref message synchronization trick copied from
    # https://github.com/PSPDFKit-labs/bypass/issues/112
    parent = self()
    ref = make_ref()
    # An ephemeral port hopefully not being in the host running this code
    plug_port = 51111
    url = "http://127.0.0.1:#{plug_port}/arithmetic-error"

    Bypass.expect_once(bypass, "POST", "/item", fn conn ->
      {:ok, body, conn} = Plug.Conn.read_body(conn)

      assert(
        %{
          "data" => %{
            "uuid" => _,
            "environment" => "test",
            "timestamp" => _,
            "level" => "error",
            "body" => %{
              "trace" => %{
                "exception" => %{
                  "class" => "ArithmeticError",
                  "message" => "bad argument in arithmetic expression"
                },
                "frames" => frames
              }
            },
            "request" => %{
              "method" => "GET",
              "url" => ^url,
              "headers" => %{"user-agent" => "httpc client"},
              "user_ip" => "127.0.0.1"
            }
          }
        } = Jason.decode!(body)
      )

      assert(
        %{
          "filename" => "test/support/error_test_plug.ex",
          "lineno" => 8,
          "method" => "anonymous fn/2 in TowerRollbar.ErrorTestPlug.do_match/4"
        } = List.last(frames)
      )

      send(parent, {ref, :sent})

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(200, Jason.encode!(%{"ok" => true}))
    end)

    start_supervised!(
      {Plug.Cowboy, plug: TowerRollbar.ErrorTestPlug, scheme: :http, port: plug_port}
    )

    {:ok, _response} = :httpc.request(:get, {url, [{~c"user-agent", "httpc client"}]}, [], [])

    assert_receive({^ref, :sent}, 500)
  end

  @tag capture_log: true
  test "reports arithmetic error when a Plug.Conn IS present with Bandit", %{bypass: bypass} do
    # ref message synchronization trick copied from
    # https://github.com/PSPDFKit-labs/bypass/issues/112
    parent = self()
    ref = make_ref()
    # An ephemeral port hopefully not being in the host running this code
    plug_port = 51111
    url = "http://127.0.0.1:#{plug_port}/arithmetic-error"

    Bypass.expect_once(bypass, "POST", "/item", fn conn ->
      {:ok, body, conn} = Plug.Conn.read_body(conn)

      assert(
        %{
          "data" => %{
            "uuid" => _,
            "environment" => "test",
            "timestamp" => _,
            "level" => "error",
            "body" => %{
              "trace" => %{
                "exception" => %{
                  "class" => "ArithmeticError",
                  "message" => "bad argument in arithmetic expression"
                },
                "frames" => frames
              }
            },
            "request" => %{
              "method" => "GET",
              "url" => ^url,
              "headers" => %{"user-agent" => "httpc client"},
              "user_ip" => "127.0.0.1"
            }
          }
        } = Jason.decode!(body)
      )

      assert(
        %{
          "filename" => "test/support/error_test_plug.ex",
          "lineno" => 8,
          "method" => "anonymous fn/2 in TowerRollbar.ErrorTestPlug.do_match/4"
        } = List.last(frames)
      )

      send(parent, {ref, :sent})

      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(200, Jason.encode!(%{"ok" => true}))
    end)

    start_supervised!({Bandit, plug: TowerRollbar.ErrorTestPlug, scheme: :http, port: plug_port})

    {:ok, _response} = :httpc.request(:get, {url, [{~c"user-agent", "httpc client"}]}, [], [])

    assert_receive({^ref, :sent}, 500)
  end

  test "reports message", %{bypass: bypass} do
    # ref message synchronization trick copied from
    # https://github.com/PSPDFKit-labs/bypass/issues/112
    parent = self()
    ref = make_ref()

    Bypass.expect_once(bypass, "POST", "/item", fn conn ->
      {:ok, body, conn} = Plug.Conn.read_body(conn)

      assert(
        %{
          "data" => %{
            "uuid" => _,
            "environment" => "test",
            "timestamp" => _,
            "level" => "info",
            "body" => %{
              "message" => %{
                "body" => "something interesting happened"
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

    Tower.handle_message(:info, "something interesting happened")

    assert_receive({^ref, :sent}, 500)
  end

  defp in_unlinked_process(fun) when is_function(fun, 0) do
    {:ok, pid} = Task.Supervisor.start_link()

    pid
    |> Task.Supervisor.async_nolink(fun)
    |> Task.yield()
  end
end
