defmodule KrakenPariyWeb.HomeLiveTest do
  use ExUnit.Case, async: true
  import Mock

  setup do
    mock_response = %{
      "result" => %{
        "XBTUSD" => %{
          "a" => ["50001"],
          "b" => ["50000"],
          "wsname" => "XBT/USD"
        },
        "ETHUSD" => %{
          "a" => ["3001"],
          "b" => ["3000"],
          "wsname" => "ETH/USD"
        }
      }
    }

    {:ok, mock_response: mock_response}
  end

  test "fetch_trade_pairs_names/0 retrieves asset pairs", %{mock_response: mock_response} do
    with_mock HTTPoison, [get: fn _ -> {:ok, %{body: Jason.encode!(mock_response)}} end] do
      result = KrakenPariyWeb.HomeLive.fetch_trade_pairs_names()

      assert Enum.sort(Map.keys(result)) == Enum.sort(["XBTUSD", "ETHUSD"])
      assert result["XBTUSD"]["wsname"] == "XBT/USD"
    end
  end

  test "fetch_trade_pairs_with_price/0 retrieves ticker prices", %{mock_response: mock_response} do
    with_mock HTTPoison, [get: fn _ -> {:ok, %{body: Jason.encode!(mock_response)}} end] do
      result = KrakenPariyWeb.HomeLive.fetch_trade_pairs_with_price()

      assert length(result) == 2
      first_pair = List.first(Enum.sort_by(result, & &1.name))

      assert first_pair.name == "ETH/USD"
      assert first_pair.ask_price == "3001"
      assert first_pair.bid_price == "3000"
    end
  end
end
