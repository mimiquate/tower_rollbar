defmodule TowerRollbar do
  @moduledoc """
  A [Rollbar](https://rollbar.com) reporter for `Tower` error handler.

  ## Example

      config :tower, :reporters, [TowerRollbar]
  """

  @behaviour Tower.Reporter

  @impl true
  defdelegate report_event(event), to: TowerRollbar.Reporter
end
