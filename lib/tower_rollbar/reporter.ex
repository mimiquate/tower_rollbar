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
          {:error, reason} = response ->
            Logger.warning("[TowerRollbar] Failed to report event to Rollbar: #{inspect(reason)}")

            response

          response ->
            response
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
