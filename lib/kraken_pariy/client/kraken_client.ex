defmodule KrakenPariy.Client.KrakenClient do
  
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
