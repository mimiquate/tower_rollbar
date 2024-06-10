defmodule TowerRollbar.Rollbar.Client do
  @base_url "https://api.rollbar.com/api/1"
  @access_token_header "X-Rollbar-Access-Token"

  def post(path, payload) when is_map(payload) do
    :httpc.request(
      :post,
      {
        @base_url <> path,
        [],
        "application/json",
        Jason.encode!(payload)
      },
      [],
      []
    )
  end
end
