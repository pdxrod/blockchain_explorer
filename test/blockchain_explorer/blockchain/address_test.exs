defmodule BlockChainExplorer.AddressTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Transaction
  alias BlockChainExplorer.Block
  alias BlockChainExplorer.Utils

  describe "addresses" do

    test "sending coins" do
      block = Blockchain.get_best_block()
      blocks = Blockchain.get_n_blocks( block, 100 )
      for num <- 0..99 do
        tuple = Enum.at( blocks, num )
        block = Block.decode_block tuple
        assert length( block.tx ) > 0
        tx_hash = Enum.at( block.tx, 0 )
        assert tx_hash =~ Utils.env :base_16_hash_regex
        tx_tuple = Transaction.get_transaction_tuple tx_hash
        decoded = Transaction.decode_transaction_tuple tx_tuple
        for output <- decoded.outputs do
          if output && output.scriptpubkey && output.scriptpubkey.addresses && length( output.scriptpubkey.addresses ) > 0 do
            address = Enum.at( output.scriptpubkey.addresses, 0 )
            Blockchain.sendtoaddress(address, :rand.uniform( 6 ) + 1)
          end
        end
      end
    end

  end
end
