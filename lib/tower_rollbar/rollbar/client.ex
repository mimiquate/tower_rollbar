defmodule TowerRollbar.Rollbar.Client do
  @base_url "https://api.rollbar.com/api/1"
  @access_token_header ~c"X-Rollbar-Access-Token"

  def post(path, payload) when is_map(payload) do
    case :httpc.request(
      :post,
      {
        ~c"#{@base_url}#{path}",
        [{@access_token_header, access_token()}],
        ~c"application/json",
        Jason.encode!(payload)
      },
      [
        ssl: [
          cacerts: :public_key.cacerts_get()
        ]
      ],
      []
    ) do
      {:ok, result} ->
        result
        |> IO.inspect()

      {:error, reason} ->
        reason
        |> IO.inspect()
    end
  end

  defp access_token do
    Application.fetch_env!(:tower_rollbar, :access_token)
  end
end
