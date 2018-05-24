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
      hash = block[ "previousblockhash" ]
      result = Blockchain.getblock( hash )
      [ hd | tl ] = Transaction.get_transactions( block )
      tuple = Transaction.get_transaction( hd )
      decoded = Transaction.decode_transaction( block, tuple )
      assert decoded.block == block[ "height" ]
      assert Transaction.total_value( decoded.vout ) > 0.0
      assert decoded.confirmations > 0
      assert decoded.relay_time
      assert length( decoded.inputs ) > 0
      assert length( decoded.outputs ) > 0
      assert decoded.fee > 0.0
      assert decoded.size > 0
    end

  end
end
