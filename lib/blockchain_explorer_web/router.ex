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
    get "/", PageController, :index
    post "/blocks", BlockController, :show
    get "/blocks", BlockController, :show
    post "/blocks/:id", BlockController, :show
    get "/blocks/:id", BlockController, :show
    post "/index", BlockController, :index
    get "/index", BlockController, :index
    get "/transactions/:address_str", TransactionController, :index
    get "/find/:address_str", TransactionController, :find
    resources "/trans", TransactionController, only: [:show]
  end

end
