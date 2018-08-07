defmodule BlockChainExplorerWeb.TransactionControllerTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Transaction

  describe "transaction" do

    test "shows transactions" do
      transaction = Transaction.get_a_useful_transaction()
      address_str = Transaction.get_an_address transaction["vout"]
      conn = build_conn()
      conn = get conn, "/transactions/#{ address_str }"
      assert html_response(conn, 200) =~ "Transactions which refer to address"
    end

    test "shows a transaction" do
      transaction = Transaction.get_a_useful_transaction()
      conn = build_conn()
      conn = get conn, transaction_path(conn, :show,  transaction["txid"])
      <b>Txid:</b> <a href='/trans/d8c06430f5cd1f17231db71a498f80fdd65956cf9516c252c3b4600e62208569'>d8c06430f5cd1f17231db71a498f80fdd65956cf9516c252c3b4600e62208569
      page = html_response(conn, 200)
      assert page =~ ~r/Txid:.*href/
      assert page =~ "/trans/#{ transaction["txid"] }"
    end

    test "ajax" do
      transaction = Transaction.get_a_useful_transaction()
      address_str = Transaction.get_an_address transaction["vout"]
      address_str = String.slice address_str, 0..5
      conn = build_conn()
      conn = get conn, transaction_path(conn, :find, address_str)
      assert html_response(conn, 200) =~ "Transactions which refer to address"
    end

  end
end
