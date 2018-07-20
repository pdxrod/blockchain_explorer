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
      transactions_tuple = TransactionFinder.peek( address_str )
      transactions_list = Tuple.to_list transactions_tuple
      decoded = if Utils.notmt?( transactions_list ) do
                  Enum.map( transactions_list, fn( tran ) -> Transaction.decode( tran ) end)
                else
                  []
                end
IO.puts "transaction controller index"
IO.inspect decoded

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
