defmodule BlockChainExplorer.BlockTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Block
  alias BlockChainExplorer.Utils

  describe "blocks" do

    test "decode_block works" do
      block = Blockchain.get_best_block()
      blocks = Blockchain.get_n_blocks( block, 30 )
      for num <- 20..29 do
        tuple = Enum.at( blocks, num ) 
        block = Block.decode_block tuple
        assert Utils.notmt? block.weight
        assert Utils.notmt? block.versionhex
        assert Utils.notmt? block.version
        assert length( block.tx ) > 0
      	assert block.time > 0
        assert block.strippedsize > 0
        assert block.size > 0
        assert Utils.notmt? block.previousblockhash
        assert block.nonce > 0
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
