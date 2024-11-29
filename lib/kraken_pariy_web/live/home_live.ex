defmodule KrakenPariyWeb.HomeLive do
  use KrakenPariyWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: KrakenPariy.WebSocket.subscribe()

    trade_pairs =
      fetch_trade_pairs_with_price()
    {
      :ok,
      socket
      |> stream(:trade_pairs, trade_pairs)
    }
  end

  @impl true
  def handle_info({:pair_updated, pair}, socket) do
    {
      :noreply,
      socket
      |> stream_delete(:trade_pairs, pair)
      |> stream_insert(:trade_pairs, pair, at: 0)
    }
  end

  def fetch_trade_pairs_with_price() do
    with {:pairs_names_fetch, trade_pairs} <- {:pairs_names_fetch, fetch_trade_pairs_names()},
         {:ok, %{body: body}} <- HTTPoison.get("https://api.kraken.com/0/public/Ticker?pair=#{Map.keys(trade_pairs) |> Enum.join(",")}"),
         {:ok, %{"result" => result}} <- Jason.decode(body) do
      result
      |> Enum.with_index(fn {name, ticker}, index ->
        %{
          id: index,
          name: trade_pairs[name]["wsname"],
          ask_price: ticker["a"] |> List.first(),
          bid_price: ticker["b"] |> List.first()
        }
      end)
    else
      _ -> []
    end
  end

  def fetch_trade_pairs_names do
    with {:ok, %{body: body}} <- HTTPoison.get("https://api.kraken.com/0/public/AssetPairs"),
         {:ok, %{"result" => result}} <- Jason.decode(body) do
      result
    else
      _ -> []
    end
  end
end
