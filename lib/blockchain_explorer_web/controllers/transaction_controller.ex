defmodule BlockChainExplorerWeb.TransactionController do
  use BlockChainExplorerWeb, :controller

  def show(conn, %{"id" => hash}) do
    conn = assign(conn, :error, "")
# Get transaction details from transaction hash

    render(conn, "show.html", transaction: hash)
  end

end
