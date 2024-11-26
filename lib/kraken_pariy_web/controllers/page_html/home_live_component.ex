defmodule KrakenPariyWeb.HomeLiveComponent do
  use KrakenPariyWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <tr>
      <td><%= @pair.name %></td>
      <td><%= @pair.ask_price %></td>
      <td><%= @pair.bid_price %></td>
    </tr>
    """
  end
end
