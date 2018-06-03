defmodule BlockChainExplorerWeb.TransactionController do
  use BlockChainExplorerWeb, :controller
  alias BlockChainExplorer.Transaction

  def show(conn, %{"id" => hash}) do
    conn = assign(conn, :error, "")
    tuple = Transaction.get_transaction_tuple hash
    decoded = Transaction.decode_transaction tuple

IO.write "\nIn TransactionController - decoded is "
IO.inspect decoded

    render(conn, "show.html", transaction: decoded)
  end

end
