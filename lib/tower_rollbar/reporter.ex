defmodule TowerRollbar.Reporter do
  @moduledoc false

  alias TowerRollbar.Rollbar

  def report_event(%Tower.Event{} = event) do
    if Rollbar.Client.enabled?() do
      {:ok, _} =
        Rollbar.Client.post(
          "/item",
          Rollbar.Item.from_event(event)
        )
    else
      IO.puts("TowerRollbar NOT enabled, ignoring...")
    end
  end
end
