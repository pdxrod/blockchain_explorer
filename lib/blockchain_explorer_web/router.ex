defmodule BlockChainExplorerWeb.Router do
  use BlockChainExplorerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BlockChainExplorerWeb do
    pipe_through :browser
    resources "/", PageController, only: [:index]
    resources "/blocks", BlockController, only: [:index, :show]
    post "/blocks", BlockController, :index
    post "/list", BlockController, :list
    get "/list", BlockController, :list
    resources "/trans", TransactionController, only: [:show]
  end

end
