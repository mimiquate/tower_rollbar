defmodule TowerRollbar.Reporter do
  @moduledoc """
  The reporter module that needs to be added to the list of Tower reporters.
  """

  @behaviour Tower.Reporter

  alias TowerRollbar.Rollbar

  @impl true
  def report_event(%Tower.Event{} = event) do
    if enabled?() do
      {:ok, _} =
        Rollbar.Client.post(
          "/item",
          Rollbar.Item.from_event(event)
        )
    else
      IO.puts("Tower.Rollbar NOT enabled, ignoring...")
    end
  end

  defp enabled? do
    Application.get_env(:tower_rollbar, :enabled, false)
  end
end
