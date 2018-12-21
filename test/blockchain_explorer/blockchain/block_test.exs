defmodule BlockChainExplorer.BlockTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Transaction
  alias BlockChainExplorer.Block
  alias BlockChainExplorer.Utils

  describe "blocks" do

    test "convert_to_struct works" do
      result = Blockchain.get_highest_block_from_db_or_bitcoind()
      block = Block.convert_to_struct result # though it already is converted
      blocks = Blockchain.get_n_blocks( block, 20 )
      for num <- 10..19 do
        block = Enum.at( blocks, num )
        assert String.length( block.block ) > 0
        tx = Transaction.get_transaction_strs( block )
        assert length( tx ) > 0
        assert Utils.notmt? block.weight
        assert Utils.notmt? block.versionhex
        assert Utils.notmt? block.version
      	assert block.time > 0
        assert block.strippedsize > 0
        assert block.size > 0
        assert Utils.notmt? block.previousblockhash
        assert block.nonce > -1
        assert Utils.notmt? block.nextblockhash
        assert Utils.notmt? block.merkleroot
        assert block.mediantime > 0
      	assert block.height > 0
        assert Utils.notmt? block.hash
        assert block.difficulty > 0.0
        assert block.confirmations > 0
      	assert Utils.notmt? block.chainwork
        assert Utils.notmt? block.bits
      end
    end

  end
end
