defmodule BlockChainExplorerWeb.TransactionController do
  use BlockChainExplorerWeb, :controller
  alias BlockChainExplorer.Transaction

  def show(conn, %{"id" => hash}) do
    conn = assign(conn, :error, "")
    render( conn, "show.html", transaction:
     hash |> Transaction.get_transaction_tuple
          |> Transaction.decode_transaction )
  end

end
