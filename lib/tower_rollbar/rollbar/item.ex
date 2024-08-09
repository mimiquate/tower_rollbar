defmodule TowerRollbar.Rollbar.Item do
  def from_event(%Tower.Event{kind: :error, reason: exception, stacktrace: stacktrace} = event) do
    trace(
      inspect(exception.__struct__),
      Exception.message(exception),
      stacktrace,
      options_from_event(event)
    )
  end

  def from_event(%Tower.Event{kind: :throw, reason: reason, stacktrace: stacktrace} = event) do
    trace("uncaught throw", reason, stacktrace, options_from_event(event))
  end

  def from_event(%Tower.Event{kind: :exit, reason: reason, stacktrace: stacktrace} = event) do
    trace("exit", reason, stacktrace, options_from_event(event))
  end

  def from_event(%Tower.Event{kind: :message, level: level, reason: reason} = event) do
    message =
      if is_binary(reason) do
        reason
      else
        inspect(reason)
      end

    %{
      "message" => %{
        "body" => message
      }
    }
    |> item_from_body(Keyword.merge([level: level], options_from_event(event)))
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
    %{
      "data" =>
        %{
          "environment" => environment(),
          # TODO: Use Tower.Event time if present
          "timestamp" => :os.system_time(:second),
          "body" => body
        }
        |> maybe_put_request_data(Keyword.get(options, :plug_conn))
        |> maybe_put_level(Keyword.get(options, :level))
        |> maybe_put_custom(Keyword.get(options, :custom))
        |> maybe_put_person(Keyword.get(options, :person))
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
      |> Plug.Conn.fetch_query_params()

    %{
      "url" => "#{conn.scheme}://#{conn.host}:#{conn.port}#{conn.request_path}",
      "user_ip" => conn.remote_ip |> :inet.ntoa() |> List.to_string(),
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

  defp options_from_event(%{id: id, log_event: log_event, metadata: metadata}) do
    [
      plug_conn: plug_conn(log_event),
      person: %{"id" => Map.get(metadata, :user_id, nil)},
      custom: %{"id" => id, "metadata" => metadata}
    ]
  end

  defp plug_conn(%{meta: %{conn: conn}}) do
    conn
  end

  defp plug_conn(_) do
    nil
  end
end
