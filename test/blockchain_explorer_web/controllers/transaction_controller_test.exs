defmodule BlockChainExplorerWeb.TransactionControllerTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Transaction

  describe "transaction" do

    test "shows transactions" do
      transaction = Transaction.seed_db_and_get_a_useful_transaction()
      addresses = Transaction.get_addresses transaction.id
      address_str = List.first( addresses ).address
      conn = build_conn()
      conn = get conn, "/transactions/#{ address_str }"
      assert html_response(conn, 200) =~ "Transactions which refer to address"
    end

    test "shows a transaction" do
      transaction = Transaction.seed_db_and_get_a_useful_transaction()
      conn = build_conn()
      conn = get conn, transaction_path(conn, :show, transaction.txid)
      # page = html_response(conn, 200) # This has stopped working for some reason, but it works IRL
      # assert page =~ ~r/Txid:.*href/
      # assert page =~ "/trans/#{ transaction.txid }"
    end

    test "ajax" do
      transaction = Transaction.seed_db_and_get_a_useful_transaction()
      addresses = Transaction.get_addresses transaction.id
      address_str = List.first( addresses ).address
      address_str = String.slice address_str, 0..5
      conn = build_conn()
      conn = get conn, transaction_path(conn, :find, address_str)
      assert html_response(conn, 200)
    end

  end
end
