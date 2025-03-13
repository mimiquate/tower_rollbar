defmodule TowerRollbar.Reporter do
  @moduledoc false

  alias TowerRollbar.Rollbar

  def report_event(%Tower.Event{} = event) do
    if Rollbar.Client.enabled?() do
      item = Rollbar.Item.from_event(event)

      async(fn ->
        {:ok, _} = Rollbar.Client.post("/item", item)
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
