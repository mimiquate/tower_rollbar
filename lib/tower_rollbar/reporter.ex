defmodule TowerRollbar.Reporter do
  @moduledoc false

  alias TowerRollbar.Rollbar
  require Logger

  def report_event(%Tower.Event{} = event) do
    if Rollbar.Client.enabled?() do
      item = Rollbar.Item.from_event(event)

      async(fn ->
        Rollbar.Client.post("/item", item)
        |> case do
          {:error, reason} ->
            log_report_error(reason)

          {:ok, {status_code, _, body}} when status_code in 400..599 ->
            body
            |> TowerRollbar.json_module().decode()
            |> case do
              {:ok, %{"err" => 1, "message" => message}} ->
                log_report_error(message)

              {:ok, decoded_body} ->
                log_report_error(decoded_body)

              {:error, _reason} ->
                log_report_error(body)
            end

          _ ->
            nil
        end
      end)
    else
      IO.puts("TowerRollbar NOT enabled, ignoring...")
    end
  end

  defp async(fun) do
    Tower.TaskSupervisor
    |> Task.Supervisor.start_child(fun)
  end

  defp log_report_error(reason) do
    Logger.error(
      "[TowerRollbar] Error reporting event to Rollbar with reason: #{inspect(reason)}"
    )
  end
end
