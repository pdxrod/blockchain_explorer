defmodule BlockChainExplorerWeb.TransactionControllerTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Transaction

  describe "transaction" do

    test "shows transactions" do
      transaction = Transaction.get_a_useful_transaction()
      address_str = Transaction.get_an_address transaction["vout"]
      conn = build_conn()
      conn = get conn, "/transactions/#{ address_str }"
      assert html_response(conn, 200) =~ "Txid:    #{ transaction["txid"] }"
    end

    test "shows a transaction" do
      transaction = Transaction.get_a_useful_transaction()
      conn = build_conn()
      conn = get conn, transaction_path(conn, :show,  transaction["txid"])
      assert html_response(conn, 200) =~ "Txid:    #{ transaction["txid"] }"
    end

  end
end
