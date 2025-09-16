if Code.ensure_loaded?(Igniter) && Code.ensure_loaded?(Tower.Igniter) do
  defmodule Mix.Tasks.TowerRollbar.Install do
    @example "mix igniter.install tower_rollbar"

    @shortdoc "Installs TowerRollbar. Invoke with `mix igniter.install tower_rollbar`"
    @moduledoc """
    #{@shortdoc}

    ## Example

    ```bash
    #{@example}
    ```
    """

    use Igniter.Mix.Task

    import Tower.Igniter

    @default_runtime_config """
    import Config

    if config_env() == :prod do
      config :tower_rollbar,
        access_token: System.get_env("ROLLBAR_SERVER_ACCESS_TOKEN"),
        environment: System.get_env("DEPLOYMENT_ENV", to_string(config_env()))
    end
    """

    @prod_config_patterns [
      """
      if config_env() == :prod do
        __cursor__()
      end
      """,
      """
      if :prod == config_env() do
        __cursor__()
      end
      """
    ]

    @rollbar_config_code """
    config :tower_rollbar,
      access_token: System.get_env("ROLLBAR_SERVER_ACCESS_TOKEN"),
      environment: System.get_env("DEPLOYMENT_ENV", to_string(config_env()))
    """

    @impl Igniter.Mix.Task
    def info(_argv, _composing_task) do
      %Igniter.Mix.Task.Info{
        group: :tower,
        adds_deps: [],
        installs: [],
        example: @example,
        positional: [],
        composes: [],
        schema: [],
        defaults: [],
        aliases: [],
        required: []
      }
    end

    @impl Igniter.Mix.Task
    def igniter(igniter) do
      igniter
      |> add_reporter_to_config(TowerRollbar)
      |> configure_runtime()
    end

    defp configure_runtime(igniter) do
      if runtime_config_exists?(igniter) do
        igniter
      else
        add_runtime_config(igniter)
      end
    end

    defp runtime_config_exists?(igniter) do
      Igniter.Project.Config.configures_key?(
        igniter,
        "runtime.exs",
        :tower_rollbar,
        [:access_token]
      )
    end

    defp add_runtime_config(igniter) do
      Igniter.create_or_update_elixir_file(
        igniter,
        "config/runtime.exs",
        @default_runtime_config,
        &update_runtime_config/1
      )
    end

    defp update_runtime_config(zipper) do
      if Igniter.Project.Config.configures_key?(zipper, :tower_rollbar, :access_token) do
        {:ok, zipper}
      else
        add_config_to_prod_block(zipper)
      end
    end

    defp add_config_to_prod_block(zipper) do
      zipper
      |> Igniter.Code.Common.move_to_cursor_match_in_scope(@prod_config_patterns)
      |> case do
        {:ok, zipper} ->
          handle_existing_prod_block(zipper)

        :error ->
          add_prod_block_with_config(zipper)
      end
    end

    defp handle_existing_prod_block(zipper) do
      if Igniter.Project.Config.configures_key?(zipper, :tower_rollbar, :access_token) do
        {:ok, zipper}
      else
        update_existing_config_or_add_new(zipper)
      end
    end

    defp update_existing_config_or_add_new(zipper) do
      case find_existing_rollbar_config(zipper) do
        {:ok, _zipper} ->
          update_existing_rollbar_config(zipper)

        _ ->
          Igniter.Code.Common.add_code(zipper, @rollbar_config_code)
      end
    end

    defp find_existing_rollbar_config(zipper) do
      Igniter.Code.Function.move_to_function_call_in_current_scope(
        zipper,
        :=,
        2,
        fn call ->
          Igniter.Code.Function.argument_equals?(call, 0, :tower_rollbar)
        end
      )
    end

    defp update_existing_rollbar_config(zipper) do
      zipper
      |> Igniter.Project.Config.modify_config_code(
        [:access_token],
        :tower_rollbar,
        Sourceror.parse_string!(~s[System.get_env("ROLLBAR_SERVER_ACCESS_TOKEN")])
      )
      |> Igniter.Project.Config.modify_config_code(
        [:environment],
        :tower_rollbar,
        Sourceror.parse_string!(~s[System.get_env("DEPLOYMENT_ENV", to_string(config_env()))])
      )
      |> then(&{:ok, &1})
    end

    defp add_prod_block_with_config(zipper) do
      Igniter.Code.Common.add_code(
        zipper,
        """
        if config_env() == :prod do
          #{@rollbar_config_code}
        end
        """
      )
    end
  end
else
  defmodule Mix.Tasks.TowerRollbar.Install do
    @example "mix igniter.install tower_rollbar"

    @shortdoc "Installs TowerRollbar. Invoke with `mix igniter.install tower_rollbar`"

    @moduledoc """
    #{@shortdoc}

    ## Example

    ```bash
    #{@example}
    ```
    """

    use Mix.Task

    @impl Mix.Task
    def run(_argv) do
      Mix.shell().error("""
      The task 'tower_rollbar.install' requires igniter and tower > 0.8.3. Please install igniter or update tower and try again.

      For more information, see: https://hexdocs.pm/igniter/readme.html#installation
      """)

      exit({:shutdown, 1})
    end
  end
end
