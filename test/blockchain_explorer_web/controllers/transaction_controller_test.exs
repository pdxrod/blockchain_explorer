defmodule BlockChainExplorerWeb.TransactionControllerTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Transaction

  describe "transaction" do
    test "shows transactions" do
    end

    test "shows a transaction" do
      transaction = Transaction.get_a_useful_transaction()
      conn = build_conn()
      conn = get conn, transaction_path(conn, :show, transaction.txid)
      assert html_response(conn, 200) =~ "Txid:    #{ transaction.txid }"
    end
  end

end
