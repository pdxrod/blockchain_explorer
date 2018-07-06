defmodule BlockChainExplorerWeb.TransactionController do
  use BlockChainExplorerWeb, :controller
  alias BlockChainExplorer.Transaction

    def show(conn, %{"id" => hash}) do
      conn = assign(conn, :error, "")
      render( conn, "show.html", transaction:
       hash |> Transaction.get_transaction_tuple
            |> Transaction.decode_transaction )
    end

    def index(conn, _params) do
      conn = assign(conn, :error, "")
      render( conn, "index.html", transactions: { %Transaction{} } )
    end

end
