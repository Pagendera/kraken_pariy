defmodule KrakenPariyWeb.HomeLive do
  use KrakenPariyWeb, :live_view
  require Logger
  alias KrakenPariy.Client.KrakenClient

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: KrakenPariy.WebSocket.subscribe()

    trade_pairs =
      KrakenClient.fetch_trade_pairs_with_price()
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
end
