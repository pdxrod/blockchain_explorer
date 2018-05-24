defmodule BlockChainExplorer.TransactionTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Transaction

  describe "transaction" do

    test "get the transactions on a block" do
      result = Blockchain.get_latest_block()
      assert :ok == elem( result, 0 )
      block = elem( result, 1 )
      hash = block[ "previousblockhash" ]
      result = Blockchain.getblock( hash )
      assert :ok == elem( result, 0 )
      transactions = Transaction.get_transactions( block )
      assert length( transactions ) > 0
    end

    test "decode a transaction" do
      result = Blockchain.get_latest_block()
      block = elem( result, 1 )
      [ hd | _ ] = Transaction.get_transactions( block )
      tuple = Transaction.get_transaction( hd )
      decoded = Transaction.decode_transaction( tuple )
      assert Transaction.total_value( decoded.outputs ) > 0.0
      assert List.first( decoded.inputs )[ "sequence" ] > 0
      assert decoded.version > 0
      assert decoded.txid =~ ~r/[0-9a-f]+/
      assert decoded.size > 0
      assert decoded.hash =~ ~r/[0-9a-f]+/
    end

  end
end
