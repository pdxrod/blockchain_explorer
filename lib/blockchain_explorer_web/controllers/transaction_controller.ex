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

# This may be called when a user enters a partial address on the home page, or when they click on an address on the transactions
    def index(conn, %{"address_str" => address_str}) do
      conn = assign(conn, :error, "")
      task = TransactionFinder.find_transactions address_str
      try do
        Task.await task, 7000
        catch :exit, _ -> IO.puts "\nExit index"
      end
      transactions = TransactionFinder.peek( address_str )
      decoded = {}
      if Utils.notmt?( transactions ) do
        for num <- 0..tuple_size( transactions ) - 1 do
          trans = Transaction.decode elem( transactions, num )
          decoded = Tuple.append( decoded, trans )
        end
      end
      render( conn, "index.html", transactions: decoded, address: address_str )
    end

    def find(conn, %{"address_str" => address_str}) do
      conn = assign(conn, :error, "")

IO.puts "\nfind 1"

      task = TransactionFinder.find_transactions address_str


IO.puts "\nfind 2"

      try do
        Task.await task, 7000
      catch :exit, _ -> IO.puts "\nExit find"
      end

IO.puts "\nfind 3"


      transactions = TransactionFinder.peek( address_str )

IO.puts "\nfind 4"

      render( conn, "json.html", transactions: transactions )
    end

end
