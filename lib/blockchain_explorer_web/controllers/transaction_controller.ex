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
        Task.await task, 1000
        catch :exit, _ -> IO.puts "\nExit index"
      end
      transactions_tuple = TransactionFinder.peek( address_str )
      transactions_tuple = if Utils.mt?( transactions_tuple ), do: { }, else: transactions_tuple
      transactions_list = Tuple.to_list transactions_tuple
      decoded = Enum.map( transactions_list, fn( tran ) -> Transaction.decode( tran ) end)
      render( conn, "index.html", transactions: decoded, address: address_str )
    end

    def find(conn, %{"address_str" => address_str}) do
      conn = assign(conn, :error, "")
      task = TransactionFinder.find_transactions address_str
      try do
        Task.await task, 11_000
        catch :exit, _ -> IO.puts "\nExit find"
      end

      transactions_tuple = TransactionFinder.peek( address_str )
      transactions_tuple = if Utils.mt?( transactions_tuple ), do: { }, else: transactions_tuple
      transactions_list = Tuple.to_list transactions_tuple

IO.puts "\ntransaction controller find - transactions list is"
IO.inspect transactions_list

      render( conn, "find.html", transactions: transactions_list )
    end

end
