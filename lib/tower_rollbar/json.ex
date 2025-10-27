defmodule TowerRollbar.JSON do
  cond do
    Code.ensure_loaded?(JSON) ->
      defdelegate decode!(value), to: JSON

      def encode!(value) do
        JSON.encode!(value, &encoder/2)
      end

      defp encoder(value, encoder) do
        try do
          JSON.protocol_encode(value, encoder)
        catch
          _, _ ->
            value
            |> inspect()
            |> JSON.protocol_encode(encoder)
        end
      end

    Code.ensure_loaded?(Jason) ->
      defdelegate encode!(value), to: Jason
      defdelegate decode!(value), to: Jason

    true ->
      raise "You need to include jason package in your dependencies to make tower_rollbar work with your current Elixir (#{System.version()}) or upgrade to Elixir 1.18+"
  end
end
