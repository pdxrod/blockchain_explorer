defmodule BlockChainExplorerWeb.TransactionController do
  use BlockChainExplorerWeb, :controller

  def show(conn, %{"id" => hash}) do
    conn = assign(conn, :error, "")

    render(conn, "show.html", transaction: hash)
  end

end
