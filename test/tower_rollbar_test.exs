defmodule TowerRollbarTest do
  use ExUnit.Case
  doctest TowerRollbar

  import ExUnit.CaptureLog, only: [capture_log: 1]

  setup do
    {:ok, test_server} = TestServer.start()

    Application.put_env(:tower, :reporters, [TowerRollbar])
    Application.put_env(:tower_rollbar, :rollbar_base_url, TestServer.url(test_server))
    Application.put_env(:tower_rollbar, :environment, :test)
    Application.put_env(:tower_rollbar, :access_token, "fake-token")

    {:ok, test_server: test_server}
  end

  test "reports arithmetic error", %{test_server: test_server} do
    waiting_for(fn done ->
      TestServer.add(
        test_server,
        "/item",
        via: :post,
        to: fn conn ->
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
            } = TowerRollbar.json_module().decode!(body)
          )

          assert(
            %{
              "method" =>
                ~s(anonymous fn/0 in TowerRollbarTest."test reports arithmetic error"/1),
              "filename" => "test/tower_rollbar_test.exs",
              "lineno" => 66
            } = List.last(frames)
          )

          done.()

          conn
          |> Plug.Conn.put_resp_content_type("application/json")
          |> Plug.Conn.resp(200, TowerRollbar.json_module().encode!(%{"ok" => true}))
        end
      )

      capture_log(fn ->
        in_unlinked_process(fn ->
          1 / 0
        end)
      end)
    end)
  end

  test "reports throw", %{test_server: test_server} do
    waiting_for(fn done ->
      TestServer.add(
        test_server,
        "/item",
        via: :post,
        to: fn conn ->
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
                      "class" => "(throw)",
                      "message" => "\"something\""
                    },
                    "frames" => frames
                  }
                }
              }
            } = TowerRollbar.json_module().decode!(body)
          )

          assert(
            %{
              "method" => ~s(anonymous fn/0 in TowerRollbarTest."test reports throw"/1),
              "filename" => "test/tower_rollbar_test.exs",
              "lineno" => 119
            } = List.last(frames)
          )

          done.()

          conn
          |> Plug.Conn.put_resp_content_type("application/json")
          |> Plug.Conn.resp(200, TowerRollbar.json_module().encode!(%{"ok" => true}))
        end
      )

      capture_log(fn ->
        in_unlinked_process(fn ->
          throw("something")
        end)
      end)
    end)
  end

  test "reports abnormal exit", %{test_server: test_server} do
    waiting_for(fn done ->
      TestServer.add(
        test_server,
        "/item",
        via: :post,
        to: fn conn ->
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
                      "class" => "(exit)",
                      "message" => ":abnormal"
                    },
                    "frames" => frames
                  }
                }
              }
            } = TowerRollbar.json_module().decode!(body)
          )

          assert(
            %{
              "method" => ~s(anonymous fn/0 in TowerRollbarTest."test reports abnormal exit"/1),
              "filename" => "test/tower_rollbar_test.exs",
              "lineno" => 172
            } = List.last(frames)
          )

          done.()

          conn
          |> Plug.Conn.put_resp_content_type("application/json")
          |> Plug.Conn.resp(200, TowerRollbar.json_module().encode!(%{"ok" => true}))
        end
      )

      capture_log(fn ->
        in_unlinked_process(fn ->
          exit(:abnormal)
        end)
      end)
    end)
  end

  test "reports :gen_server bad exit", %{test_server: test_server} do
    waiting_for(fn done ->
      TestServer.add(
        test_server,
        "/item",
        via: :post,
        to: fn conn ->
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
                      "class" => "(exit)",
                      "message" => "bad return value: \"bad value\""
                    },
                    "frames" => frames
                  }
                }
              }
            } = TowerRollbar.json_module().decode!(body)
          )

          assert(
            %{
              "method" =>
                ~s(anonymous fn/0 in TowerRollbarTest."test reports :gen_server bad exit"/1),
              "filename" => "test/tower_rollbar_test.exs",
              "lineno" => 226
            } = List.last(frames)
          )

          done.()

          conn
          |> Plug.Conn.put_resp_content_type("application/json")
          |> Plug.Conn.resp(200, TowerRollbar.json_module().encode!(%{"ok" => true}))
        end
      )

      capture_log(fn ->
        in_unlinked_process(fn ->
          exit({:bad_return_value, "bad value"})
        end)
      end)
    end)
  end

  test "error report includes request data when available via Plug.Cowboy", %{
    test_server: test_server
  } do
    # An ephemeral port hopefully not being in the host running this code
    plug_port = 51111
    url = "http://127.0.0.1:#{plug_port}/arithmetic-error"

    waiting_for(fn done ->
      TestServer.add(
        test_server,
        "/item",
        via: :post,
        to: fn conn ->
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
            } = TowerRollbar.json_module().decode!(body)
          )

          assert(
            %{
              "filename" => "test/support/error_test_plug.ex",
              "lineno" => 8,
              "method" => "anonymous fn/2 in TowerRollbar.ErrorTestPlug.do_match/4"
            } = List.last(frames)
          )

          done.()

          conn
          |> Plug.Conn.put_resp_content_type("application/json")
          |> Plug.Conn.resp(200, TowerRollbar.json_module().encode!(%{"ok" => true}))
        end
      )

      start_supervised!(
        {Plug.Cowboy, plug: TowerRollbar.ErrorTestPlug, scheme: :http, port: plug_port}
      )

      capture_log(fn ->
        {:ok, _response} = :httpc.request(:get, {url, [{~c"user-agent", "httpc client"}]}, [], [])
      end)
    end)
  end

  test "throw report includes request data when available via Plug.Cowboy", %{
    test_server: test_server
  } do
    # An ephemeral port hopefully not being in the host running this code
    plug_port = 51111
    url = "http://127.0.0.1:#{plug_port}/uncaught-throw"

    waiting_for(fn done ->
      TestServer.add(
        test_server,
        "/item",
        via: :post,
        to: fn conn ->
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
                      "class" => "(throw)",
                      "message" => "\"from inside a plug\""
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
            } = TowerRollbar.json_module().decode!(body)
          )

          assert(
            %{
              "filename" => "test/support/error_test_plug.ex",
              "lineno" => 14,
              "method" => "anonymous fn/2 in TowerRollbar.ErrorTestPlug.do_match/4"
            } = List.last(frames)
          )

          done.()

          conn
          |> Plug.Conn.put_resp_content_type("application/json")
          |> Plug.Conn.resp(200, TowerRollbar.json_module().encode!(%{"ok" => true}))
        end
      )

      start_supervised!(
        {Plug.Cowboy, plug: TowerRollbar.ErrorTestPlug, scheme: :http, port: plug_port}
      )

      capture_log(fn ->
        {:ok, _response} = :httpc.request(:get, {url, [{~c"user-agent", "httpc client"}]}, [], [])
      end)
    end)
  end

  test "abnormal exit report includes request data when available via Plug.Cowboy", %{
    test_server: test_server
  } do
    # An ephemeral port hopefully not being in the host running this code
    plug_port = 51111
    url = "http://127.0.0.1:#{plug_port}/abnormal-exit"

    waiting_for(fn done ->
      TestServer.add(
        test_server,
        "/item",
        via: :post,
        to: fn conn ->
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
                      "class" => "(exit)",
                      "message" => ":abnormal"
                    },
                    # Plug.Cowboy doesn't provide stacktrace for exits
                    "frames" => []
                  }
                },
                "request" => %{
                  "method" => "GET",
                  "url" => ^url,
                  "headers" => %{"user-agent" => "httpc client"},
                  "user_ip" => "127.0.0.1"
                }
              }
            } = TowerRollbar.json_module().decode!(body)
          )

          done.()

          conn
          |> Plug.Conn.put_resp_content_type("application/json")
          |> Plug.Conn.resp(200, TowerRollbar.json_module().encode!(%{"ok" => true}))
        end
      )

      start_supervised!(
        {Plug.Cowboy, plug: TowerRollbar.ErrorTestPlug, scheme: :http, port: plug_port}
      )

      capture_log(fn ->
        {:ok, _response} = :httpc.request(:get, {url, [{~c"user-agent", "httpc client"}]}, [], [])
      end)
    end)
  end

  test "reports arithmetic error when a Plug.Conn IS present with Bandit", %{
    test_server: test_server
  } do
    # An ephemeral port hopefully not being in the host running this code
    plug_port = 51111
    url = "http://127.0.0.1:#{plug_port}/arithmetic-error"

    waiting_for(fn done ->
      TestServer.add(
        test_server,
        "/item",
        via: :post,
        to: fn conn ->
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
            } = TowerRollbar.json_module().decode!(body)
          )

          assert(
            %{
              "filename" => "test/support/error_test_plug.ex",
              "lineno" => 8,
              "method" => "anonymous fn/2 in TowerRollbar.ErrorTestPlug.do_match/4"
            } = List.last(frames)
          )

          done.()

          conn
          |> Plug.Conn.put_resp_content_type("application/json")
          |> Plug.Conn.resp(200, TowerRollbar.json_module().encode!(%{"ok" => true}))
        end
      )

      capture_log(fn ->
        start_supervised!(
          {Bandit, plug: TowerRollbar.ErrorTestPlug, scheme: :http, port: plug_port}
        )

        {:ok, _response} = :httpc.request(:get, {url, [{~c"user-agent", "httpc client"}]}, [], [])
      end)
    end)
  end

  test "reports throw with Bandit", %{test_server: test_server} do
    # An ephemeral port hopefully not being in the host running this code
    plug_port = 51111
    url = "http://127.0.0.1:#{plug_port}/uncaught-throw"

    waiting_for(fn done ->
      TestServer.add(
        test_server,
        "/item",
        via: :post,
        to: fn conn ->
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
                      "class" => "(throw)",
                      "message" => "\"from inside a plug\""
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
            } = TowerRollbar.json_module().decode!(body)
          )

          assert(
            %{
              "filename" => "test/support/error_test_plug.ex",
              "lineno" => 14,
              "method" => "anonymous fn/2 in TowerRollbar.ErrorTestPlug.do_match/4"
            } = List.last(frames)
          )

          done.()

          conn
          |> Plug.Conn.put_resp_content_type("application/json")
          |> Plug.Conn.resp(200, TowerRollbar.json_module().encode!(%{"ok" => true}))
        end
      )

      capture_log(fn ->
        start_supervised!(
          {Bandit, plug: TowerRollbar.ErrorTestPlug, scheme: :http, port: plug_port}
        )

        {:ok, _response} = :httpc.request(:get, {url, [{~c"user-agent", "httpc client"}]}, [], [])
      end)
    end)
  end

  test "reports message", %{test_server: test_server} do
    waiting_for(fn done ->
      TestServer.add(
        test_server,
        "/item",
        via: :post,
        to: fn conn ->
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
            } = TowerRollbar.json_module().decode!(body)
          )

          done.()

          conn
          |> Plug.Conn.put_resp_content_type("application/json")
          |> Plug.Conn.resp(200, TowerRollbar.json_module().encode!(%{"ok" => true}))
        end
      )

      Tower.report_message(:info, "something interesting happened")
    end)
  end

  test "properly reports elixir terms in metadata whithout a JSON native formatting", %{
    test_server: test_server
  } do
    waiting_for(fn done ->
      TestServer.add(
        test_server,
        "/item",
        via: :post,
        to: fn conn ->
          {:ok, body, conn} = Plug.Conn.read_body(conn)

          assert(
            %{
              "data" => %{
                "environment" => "test",
                "level" => "info",
                "body" => %{
                  "message" => %{
                    "body" => "something"
                  }
                },
                "custom" => %{
                  "metadata" => %{
                    "function" => "#Function<" <> _,
                    "pid" => "#PID<" <> _,
                    "port" => "#Port<" <> _,
                    "ref" => "#Reference<" <> _,
                    "{:one, :two}" => "{:three, :four}"
                  }
                }
              }
            } = TowerRollbar.json_module().decode!(body)
          )

          done.()

          conn
          |> Plug.Conn.put_resp_content_type("application/json")
          |> Plug.Conn.resp(200, TowerRollbar.json_module().encode!(%{"ok" => true}))
        end
      )

      Tower.report_message(
        :info,
        "something",
        metadata: %{
          :function => fn x -> x end,
          :pid => self(),
          :port => hd(Port.list()),
          :ref => make_ref(),
          {:one, :two} => {:three, :four}
        }
      )
    end)
  end

  defp in_unlinked_process(fun) when is_function(fun, 0) do
    {:ok, pid} = Task.Supervisor.start_link()

    pid
    |> Task.Supervisor.async_nolink(fun)
    |> Task.yield()
  end

  defp waiting_for(fun) do
    # ref message synchronization trick copied from
    # https://github.com/PSPDFKit-labs/bypass/issues/112
    parent = self()
    ref = make_ref()

    fun.(fn ->
      send(parent, {ref, :sent})
    end)

    assert_receive({^ref, :sent}, 500)
  end
end
