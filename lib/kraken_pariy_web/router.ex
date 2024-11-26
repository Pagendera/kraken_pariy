defmodule KrakenPariyWeb.Router do
  use KrakenPariyWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {KrakenPariyWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", KrakenPariyWeb do
    pipe_through :browser

    live "/", HomeLive, :home
  end
end
