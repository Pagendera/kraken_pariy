defmodule KrakenPariy.WebSocket do
  use WebSockex
  require Logger

  def start_link(_), do: WebSockex.start_link("wss://ws.kraken.com/v2", __MODULE__, nil)

  @impl true
  def handle_connect(_conn, state) do
    Logger.info("Connected...")
    send(self(), :subscribe)
    {:ok, state}
  end

  @impl true
  def handle_frame({:text, pair}, state) do
    trade_pairs = KrakenPariyWeb.HomeLive.fetch_trade_pairs_with_price()

    pair
    |> Jason.decode()
    |> case do
      {:ok, %{"data" => [%{"ask" => ask_price, "bid" => bid_price, "symbol" => name}]}} ->
        pair =
          trade_pairs
          |> Enum.find(& &1[:name] == name)
          if pair[:ask_price] !== ask_price || pair[:bid_price] !== bid_price do
            pair_updated =
              pair
              |> Map.merge(%{
                ask_price: ask_price,
                bid_price: bid_price
              })
            broadcast({:ok, pair_updated}, :pair_updated)
          end
      _ ->
        nil
    end

    {:ok, state}
  end

  @impl true
  def handle_info(:subscribe, state) do
    subscribe =
      Jason.encode!(%{
        "method" => "subscribe",
        "params" => %{
          "channel" => "ticker",
          "symbol" => KrakenPariyWeb.HomeLive.fetch_trade_pairs_names() |> Map.values() |> Enum.map(& &1["wsname"])
        }
      })

    {:reply, {:text, subscribe}, state}
  end

  def subscribe do
    Phoenix.PubSub.subscribe(KrakenPariy.PubSub, "trade_pairs")
  end

  defp broadcast({:ok, pair}, event) do
    Phoenix.PubSub.broadcast(KrakenPariy.PubSub, "trade_pairs", {event, pair})
  end
end
