defmodule KrakenPariy.WebSocketTest do
  use ExUnit.Case
  import Mock

  test "start_link/1 initiates WebSocket connection" do
    with_mock WebSockex, [start_link: fn _, _, _ -> {:ok, :pid} end] do
      assert {:ok, :pid} = KrakenPariy.WebSocket.start_link(nil)
    end
  end

  test "handle_frame/2 processes valid trade pair data" do
    with_mock KrakenPariyWeb.HomeLive, [
      fetch_trade_pairs_with_price: fn ->
        [
          %{name: "XBT/USD", ask_price: "50000", bid_price: "49999"},
          %{name: "ETH/USD", ask_price: "3000", bid_price: "2999"}
        ]
      end
    ] do
      frame_data = Jason.encode!(%{
        "data" => [%{
          "ask" => "50001",
          "bid" => "50000",
          "symbol" => "XBT/USD"
        }]
      })

      with_mock Phoenix.PubSub, [broadcast: fn _, _, _ -> :ok end] do
        {:ok, _state} = KrakenPariy.WebSocket.handle_frame({:text, frame_data}, nil)

        assert called Phoenix.PubSub.broadcast(
          KrakenPariy.PubSub,
          "trade_pairs",
          {:pair_updated, %{
            name: "XBT/USD",
            ask_price: "50001",
            bid_price: "50000"
          }}
        )
      end
    end
  end

  test "handle_info/2 sends WebSocket subscription request" do
    with_mock KrakenPariyWeb.HomeLive, [
      fetch_trade_pairs_names: fn -> %{
        "XBTUSD" => %{"wsname" => "XBT/USD"},
        "ETHUSD" => %{"wsname" => "ETH/USD"}
      } end
    ] do
      expected_subscribe = Jason.encode!(%{
        "method" => "subscribe",
        "params" => %{
          "channel" => "ticker",
          "symbol" => ["ETH/USD", "XBT/USD"]
        }
      })

      {:reply, {:text, subscribe_request}, _state} =
        KrakenPariy.WebSocket.handle_info(:subscribe, nil)

      assert Jason.decode!(subscribe_request) == Jason.decode!(expected_subscribe)
    end
  end
end
