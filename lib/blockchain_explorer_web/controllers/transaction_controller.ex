defmodule BlockChainExplorerWeb.TransactionController do
  use BlockChainExplorerWeb, :controller
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Transaction
  alias BlockChainExplorer.TransactionFinder

    def show(conn, %{"id" => hash}) do
      conn = assign(conn, :error, "")
      transaction = Transaction.get_transaction_with_hash hash
      render( conn, "show.html", transaction: transaction )
    end

# This may be called when a user enters a partial address on the /blocks page, or when they click on an address in a transaction
    def index(conn, %{"address_str" => address_str}) do
      conn = assign(conn, :error, "")
      TransactionFinder.find_transactions address_str
      render( conn, "index.html", address: address_str )
    end

# This is called from Javascript
    def find(conn, %{"address_str" => address_str}) do
      conn = assign(conn, :error, "")
      transactions_tuple = TransactionFinder.peek( address_str )
      transactions_tuple = if Utils.mt?( transactions_tuple ), do: { }, else: transactions_tuple
      transactions_list = Tuple.to_list transactions_tuple
      render( conn, "find.html", transactions: transactions_list )
    end

end
