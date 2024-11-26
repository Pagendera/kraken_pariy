# Kraken test task

This project is  a small application that allows users to view the current prices from the **Kraken crypto exchange**.

## Features

- **Show all current prices** from the exchange.
- **WebSocket connections** to retrieve prices.
- **Update in real-time**

## Installation

1. **Clone the Repository**
3. **Run `mix setup` to install and setup dependencies**
4. **Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`**
5. **Use App through Browser (use http://localhost:4000 endpoint)**

 **Note**: For the data to start updating in real time, the app subscribes to all valid pairs via Kraken, which can take 5-10 minutes.
