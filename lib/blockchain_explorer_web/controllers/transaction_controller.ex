defmodule BlockChainExplorerWeb.TransactionController do
  use BlockChainExplorerWeb, :controller
  alias BlockChainExplorer.Transaction
  alias BlockChainExplorer.TransactionFinder

    def show(conn, %{"id" => hash}) do
      conn = assign(conn, :error, "")
      render( conn, "show.html", transaction:
       hash |> Transaction.get_transaction_tuple
            |> Transaction.decode_transaction_tuple )
    end

# This may be called with a user enters a partial address on the home page, or when they click on an address on the transactions
    def index(conn, %{"address_str" => address_str}) do
      conn = assign(conn, :error, "")
      task = TransactionFinder.find_transactions address_str
      try do
        Task.await task, 7000
      catch :exit, _ -> IO.puts "\nExit index"
      end
      transactions = TransactionFinder.peek( address_str )
      render( conn, "index.html", transactions: transactions, address: address_str )
    end

    def find(conn, %{"address_str" => address_str}) do
      conn = assign(conn, :error, "")
      task = TransactionFinder.find_transactions address_str
      try do
        Task.await task, 7000
      catch :exit, _ -> IO.puts "\nExit find"
      end
      transactions = TransactionFinder.peek( address_str )
      render( conn, "index.html", transactions: transactions, address: address_str )
    end

end
