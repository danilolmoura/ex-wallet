defmodule ExWalletWeb.Router do
  use ExWalletWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ExWalletWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExWalletWeb do
    pipe_through :browser

    live("/", EthLive.TransactionStatus)
    get "/*any", PageController, :always_redirect
  end
end
