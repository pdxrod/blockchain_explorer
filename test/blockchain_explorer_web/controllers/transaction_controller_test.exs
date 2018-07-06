defmodule BlockChainExplorerWeb.TransactionControllerTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Transaction

  defp get_a_useful_transaction do
    block = Blockchain.get_best_block()
    Blockchain.get_n_blocks( block, 100 ) |>
    Transaction.transaction_with_everything_in_it_from_tuple |>
    Transaction.get_transaction_tuple |>
    Transaction.decode_transaction_tuple
  end

  describe "transaction" do
    test "shows transactions", %{conn: conn} do
    end
    
    test "shows a transaction", %{conn: conn} do
      transaction = get_a_useful_transaction()
      conn = get conn, transaction_path(conn, :show, transaction.txid)
      assert html_response(conn, 200) =~ "Txid:    #{ transaction.txid }"
    end
  end

end
