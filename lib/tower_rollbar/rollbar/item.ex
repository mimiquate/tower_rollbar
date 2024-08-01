defmodule TowerRollbar.Rollbar.Item do
  def from_exception(exception, stacktrace, options \\ [])
      when is_exception(exception) and is_list(stacktrace) do
    trace(inspect(exception.__struct__), Exception.message(exception), stacktrace, options)
  end

  def from_throw(reason, stacktrace, options \\ []) when is_list(stacktrace) do
    trace("uncaught throw", reason, stacktrace, options)
  end

  def from_exit(reason, stacktrace, options \\ []) when is_list(stacktrace) do
    trace("exit", reason, stacktrace, options)
  end

  def from_message(message, options \\ [])

  def from_message(message, options) when is_binary(message) do
    %{
      "message" => %{
        "body" => message
      }
    }
    |> item_from_body(Keyword.merge([level: :info], options))
  end

  def from_message(message, options) when is_list(message) do
    from_message(inspect(message), options)
  end

  defp trace(class, reason, stacktrace, options) do
    %{
      "trace" => %{
        "frames" => frames(stacktrace),
        "exception" => %{
          "class" => class,
          "message" => reason
        }
      }
    }
    |> item_from_body(Keyword.merge([level: :error], options))
  end

  defp item_from_body(body, options) when is_map(body) do
    plug_conn = Keyword.get(options, :plug_conn)
    level = Keyword.get(options, :level)
    custom = Keyword.get(options, :custom)
    person = Keyword.get(options, :person)

    %{
      "data" =>
        %{
          "environment" => environment(),
          "timestamp" => :os.system_time(:second),
          "body" => body
        }
        |> maybe_put_request_data(plug_conn)
        |> maybe_put_level(level)
        |> maybe_put_custom(custom)
        |> maybe_put_person(person)
    }
  end

  defp maybe_put_level(item, level) when is_atom(level) and level != nil do
    item
    |> Map.put("level", Atom.to_string(level))
  end

  defp maybe_put_level(item, _) do
    item
  end

  defp maybe_put_custom(item, custom) when is_map(custom) do
    item
    |> Map.put("custom", custom)
  end

  defp maybe_put_custom(item, _) do
    item
  end

  defp maybe_put_person(item, person) when is_map(person) do
    item
    |> Map.put("person", person)
  end

  defp maybe_put_person(item, _) do
    item
  end

  defp maybe_put_request_data(item, %Plug.Conn{} = conn) do
    item
    |> Map.put("request", request_data(conn))
  end

  defp maybe_put_request_data(item, _) do
    item
  end

  defp request_data(%Plug.Conn{} = conn) do
    conn =
      conn
      |> Plug.Conn.fetch_cookies()
      |> Plug.Conn.fetch_query_params()

    %{
      "cookies" => conn.req_cookies,
      "url" => "#{conn.scheme}://#{conn.host}:#{conn.port}#{conn.request_path}",
      "user_ip" => conn.remote_ip |> :inet.ntoa() |> List.to_string(),
      "headers" => conn.req_headers |> Enum.into(%{}),
      "method" => conn.method,
      "params" =>
        case conn.params do
          %Plug.Conn.Unfetched{aspect: :params} -> "unfetched"
          other -> other
        end
    }
  end

  defp frames(stacktrace) do
    stacktrace
    |> Enum.map(fn {m, f, a, location} ->
      frame = %{
        "method" => Exception.format_mfa(m, f, a)
      }

      frame =
        if location[:file] do
          Map.put(frame, "filename", to_string(location[:file]))
        else
          frame
        end

      if location[:line] do
        Map.put(frame, "lineno", location[:line])
      else
        frame
      end
    end)
    |> Enum.reverse()
  end

  defp environment do
    Application.fetch_env!(:tower_rollbar, :environment)
  end
end
