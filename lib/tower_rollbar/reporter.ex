defmodule TowerRollbar.Reporter do
  @behaviour Tower.Reporter

  @impl true
  def report_exception(exception, stacktrace, metadata \\ %{}) when is_exception(exception) and is_list(stacktrace) do
    Rollbax.Client.emit(
      :error,
      :os.system_time(:second),
      %{
        "trace" => %{
          # "frames" => trace_frames(stacktrace),
          "exception" => %{
            "class" => inspect(exception.__struct__),
            "message" => Exception.message(exception)
          }
        }
      },
      custom_data(metadata),
      occurrence_data(metadata)
    )
  end

  defp custom_data(%{pid: pid, mfa: {m, f, arity}}) do
    %{
      name: pid,
      function: inspect(Function.capture(m, f, arity))
    }
  end

  defp custom_data(_) do
    %{}
  end

  defp occurrence_data(%{conn: conn}) do
    conn =
      conn
      |> Plug.Conn.fetch_cookies()
      |> Plug.Conn.fetch_query_params()

    %{
      "request" => %{
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
      },
      "person" => %{
        "id" => conn.assigns[:user_id]
      }
    }
  end

  defp occurrence_data(_) do
    %{}
  end
end
