defmodule BlockChainExplorerWeb.TransactionController do
  use BlockChainExplorerWeb, :controller
  alias BlockChainExplorer.Transaction

  def show(conn, %{"id" => hash}) do
    conn = assign(conn, :error, "")
    tuple = Transaction.get_transaction_tuple hash
    decoded = Transaction.decode_transaction tuple
    render(conn, "show.html", transaction: decoded)
  end

end
