defmodule TowerRollbar.Reporter do
  @behaviour Tower.Reporter

  alias TowerRollbar.Rollbar

  @impl true
  def report_event(%Tower.Event{
        kind: :error,
        reason: exception,
        stacktrace: stacktrace,
        metadata: metadata
      }) do
    if enabled?() do
      Rollbar.Client.post(
        "/item",
        Rollbar.Item.from_exception(exception, stacktrace, plug_conn: plug_conn(metadata))
      )
    else
      IO.puts("Tower.Rollbar NOT enabled, ignoring...")
    end
  end

  def report_event(%Tower.Event{
        kind: :throw,
        reason: reason,
        stacktrace: stacktrace,
        metadata: metadata
      }) do
    if enabled?() do
      Rollbar.Client.post(
        "/item",
        Rollbar.Item.from_throw(reason, stacktrace, plug_conn: plug_conn(metadata))
      )
    else
      IO.puts("Tower.Rollbar NOT enabled, ignoring...")
    end
  end

  def report_event(%Tower.Event{
        kind: :exit,
        reason: reason,
        stacktrace: stacktrace,
        metadata: metadata
      }) do
    if enabled?() do
      Rollbar.Client.post(
        "/item",
        Rollbar.Item.from_exit(reason, stacktrace, plug_conn: plug_conn(metadata))
      )
    else
      IO.puts("Tower.Rollbar NOT enabled, ignoring...")
    end
  end

  @impl true
  def report_event(%Tower.Event{kind: :message, level: level, reason: message}) do
    if enabled?() do
      Rollbar.Client.post(
        "/item",
        Rollbar.Item.from_message(message, level: level)
      )
    else
      IO.puts("Tower.Rollbar NOT enabled, ignoring...")
    end
  end

  defp plug_conn(%{log_event: %{meta: %{conn: conn}}}) do
    conn
  end

  defp plug_conn(_) do
    nil
  end

  defp enabled? do
    Application.get_env(:tower_rollbar, :enabled, false)
  end
end
