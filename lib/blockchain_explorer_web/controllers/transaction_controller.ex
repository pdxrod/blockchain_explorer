defmodule BlockChainExplorerWeb.TransactionController do
  use BlockChainExplorerWeb, :controller
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Transaction
  alias BlockChainExplorer.TransactionFinder

    def show(conn, %{"id" => hash}) do
      conn = assign(conn, :error, "")
      render( conn, "show.html", transaction:
       hash |> Transaction.get_transaction_tuple
            |> Transaction.decode_transaction_tuple )
    end

    def index(conn, _params) do
      conn = assign(conn, :error, "")
      transactions = TransactionFinder.get()
      transactions = if Utils.mt?( transactions ), do: { %Transaction{} }, else: transactions
      render( conn, "index.html", transactions: transactions )
    end

end
