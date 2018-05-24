defmodule BlockChainExplorerWeb.PageController do
  use BlockChainExplorerWeb, :controller

  def index(conn, _params) do
    redirect( conn, to: "/blocks" )
  end

end
