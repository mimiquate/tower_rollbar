defmodule TowerRollbar.Reporter do
  @behaviour Tower.Reporter

  alias TowerRollbar.Rollbar

  @impl true
  def report_exception(exception, stacktrace, metadata \\ %{})
      when is_exception(exception) and is_list(stacktrace) do
    if enabled?() do
      Rollbar.Client.post(
        "/item",
        Rollbar.Item.from_exception(exception, stacktrace, plug_conn: plug_conn(metadata))
      )
    else
      IO.puts("Tower.Rollbar NOT enabled, ignoring...")
    end
  end

  @impl true
  def report_throw(reason, stacktrace, metadata \\ %{}) when is_list(stacktrace) do
    if enabled?() do
      Rollbar.Client.post(
        "/item",
        Rollbar.Item.from_throw(reason, stacktrace, plug_conn: plug_conn(metadata))
      )
    else
      IO.puts("Tower.Rollbar NOT enabled, ignoring...")
    end
  end

  @impl true
  def report_exit(reason, stacktrace, metadata \\ %{}) when is_list(stacktrace) do
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
  def report_message(level, message, metadata \\ %{})

  def report_message(level, message, _metadata) when is_binary(message) do
    if enabled?() do
      Rollbar.Client.post(
        "/item",
        Rollbar.Item.from_message(message, level: level)
      )
    else
      IO.puts("Tower.Rollbar NOT enabled, ignoring...")
    end
  end

  def report_message(level, message, metadata) when is_list(message) or is_map(message) do
    report_message(level, inspect(message), metadata)
  end

  defp plug_conn(%{conn: conn}) do
    conn
  end

  defp plug_conn(_) do
    nil
  end

  defp enabled? do
    Application.get_env(:tower_rollbar, :enabled, false)
  end
end
