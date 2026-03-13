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
          {:error, _} = response ->
            Logger.error("Network error")
            response

          {:ok, {{_, status_code, _}, _, body}} when status_code in 400..599 ->
            body
            |> TowerRollbar.json_module().decode!()
            |> case do
              %{"err" => 1, "message" => message} ->
                Logger.error(message)

              _ ->
                Logger.error("Error")
            end

            nil

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
end
