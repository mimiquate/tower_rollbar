defmodule TowerRollbar.Reporter do
  @moduledoc """
  The reporter module that needs to be added to the list of Tower reporters.
  """

  @behaviour Tower.Reporter

  alias TowerRollbar.Rollbar

  @impl true
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
