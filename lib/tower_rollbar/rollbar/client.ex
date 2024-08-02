defmodule TowerRollbar.Rollbar.Client do
  @access_token_header ~c"X-Rollbar-Access-Token"

  def post(path, payload) when is_map(payload) do
    :httpc.request(
      :post,
      {
        ~c"#{base_url()}#{path}",
        [{@access_token_header, access_token()}],
        ~c"application/json",
        Jason.encode!(payload)
      },
      [
        ssl: tls_client_options()
      ],
      []
    )
    |> case do
      {:ok, result} ->
        result

      {:error, reason} ->
        reason
    end
  end

  cond do
    function_exported?(:public_key, :cacerts_get, 0) ->
      # Included in Erlang 25+
      defp tls_client_options do
        [
          verify: :verify_peer,
          cacerts: :public_key.cacerts_get()
        ]
      end

    Code.ensure_loaded?(CAStore) ->
      # Support Erlang < 25
      defp tls_client_options do
        [
          verify: :verify_peer,
          cacertfile: CAStore.file_path()
        ]
      end

    true ->
      raise "Please include castore package in your dependencies to make tower_rollbar work for Erlang/OTP #{System.otp_release()} or upgrade to Erlang/OTP 25+"
  end

  defp access_token do
    Application.fetch_env!(:tower_rollbar, :access_token)
  end

  defp base_url do
    Application.fetch_env!(:tower_rollbar, :rollbar_base_url)
  end
end
