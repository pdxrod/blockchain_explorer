defmodule BlockChainExplorer.BlockchainTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Block
  alias BlockChainExplorer.Utils

  describe "blocks" do

    @our_block %{
      "weight" => "988",
      "versionHex" => "20000000",
      "version" => "536870912",
      "tx" => [
        "5c2660b4a8e165508f5e5e623bd554cc67ae1292394a791e8c69e9826ecea085"
      ],
      "time" => "1523531895",
      "strippedsize" => "238",
      "size" => "274",
      "previousblockhash" => "000000000384cd03e5eeb037a0d7220c8703a8dd7973ab49797bd2b1fd0aa823",
      "nonce" => "3885304124",
      "nextblockhash" => "00000000000002e2ee8daefc4c5e873f91ba3f934772ae29a44dcd13d47c841c",
      "merkleroot" => "5c2660b4a8e165508f5e5e623bd554cc67ae1292394a791e8c69e9826ecea085",
      "mediantime" => "1523530064",
      "height" => "1292532",
      "hash" => "00000000000002c4298b96bbca7bac080335c5d646a9cb42839baee31c418c80",
      "difficulty" => "5566188.854205163",
      "confirmations" => "6",
      "chainwork" => "00000000000000000000000000000000000000000000003a53d0f634b950ea79",
      "bits" => "1a03039b"
    }

    test "our block is a real one" do
      if Utils.mode != "regtest" do
        previous = Blockchain.get_next_or_previous_block( @our_block, "previousblockhash" )
        hash = previous[ "nextblockhash" ]
        assert hash == @our_block[ "hash" ]
      end
    end

    test "return block with a valid id" do
      block = Blockchain.get_highest_block_from_db_or_bitcoind()
      hash = block.hash
      assert hash =~ Utils.env :base_16_hash_regex
    end

    test "next block works" do
      block = Blockchain.get_highest_block_from_db_or_bitcoind()
      hash = block.nextblockhash
      assert nil == hash
      previous = Blockchain.get_next_or_previous_block( block, "previousblockhash" )
      hash = previous.nextblockhash
      assert hash =~ Utils.env :base_16_hash_regex
    end

    test "previous block works" do
      block = Blockchain.get_highest_block_from_db_or_bitcoind()
      hash = block.previousblockhash
      assert hash =~ Utils.env :base_16_hash_regex
    end

    test "hash works" do
      block = Blockchain.get_highest_block_from_db_or_bitcoind()
      hash = block.hash
      block = Blockchain.get_from_db_or_bitcoind_by_hash( hash )
      new_hash = block.hash
      assert new_hash =~ Utils.env :base_16_hash_regex
      assert new_hash == hash
    end

    test "fail to return the block with an fake id" do
      result = Blockchain.get_from_db_or_bitcoind_by_hash "f0000000000000000000000000000000000000000000000000000000000000ba"
      assert result == %{error: "Block not found in this blockchain"}
    end

    test "fail to return the block with a completely invalid id" do
      result = Blockchain.get_from_db_or_bitcoind_by_hash "Foo bar"
      assert result == %{error: "blockhash must be of length 64 (not 7, for 'Foo bar')"}
    end

    test "get n blocks backward works" do
      block = Blockchain.get_highest_block_from_db_or_bitcoind()
      old_hash = block.hash
      blocks = Blockchain.get_n_blocks(block, 3, "previousblockhash")
      assert length( blocks ) == 3
      blocks = Blockchain.get_n_blocks(block, 2, "previousblockhash")
      assert length( blocks ) == 2
      block = List.first blocks
      new_hash = block.hash
      assert old_hash == new_hash
      block = Enum.at( blocks, 1 )
      new_hash = block.hash
      assert old_hash != new_hash
      blocks = Blockchain.get_n_blocks(block, 100, "previousblockhash")
      assert length( blocks ) == 100
      blocks = Blockchain.get_n_blocks(block, -1, "previousblockhash")
      assert length( blocks ) == 1
      blocks = Blockchain.get_n_blocks(block, 1, "previousblockhash")
      assert length( blocks ) == 1
      blocks = Blockchain.get_n_blocks(block, 0, "previousblockhash")
      assert length( blocks ) == 1
    end

    test "get n blocks blows up given an inappropriate direction" do
      block = Blockchain.get_highest_block_from_db_or_bitcoind()
      err = try do
        Blockchain.get_n_blocks(block, 2, "foobar")
        raise "We should not have reached this line"
      rescue
        e in RuntimeError -> e
      end
      assert err.message == "direction should be previousblockhash or nextblockhash, not foobar"
    end

    test "get next or previous n blocks returns only genesis block if given genesis block" do
      block = Blockchain.get_lowest_block_from_db_or_bitcoind()
      blocks = Blockchain.get_next_or_previous_n_blocks(block, 5, "previousblockhash")
      assert length( blocks ) == 1
      assert List.first( blocks ).height == 0
    end

    test "get next or previous n blocks returns genesis block only once if given low block" do
      block = Blockchain.get_from_db_or_bitcoind_by_height 5
      blocks = Blockchain.get_next_or_previous_n_blocks(block, 10, "previousblockhash")
      assert length( blocks ) == 6
      assert List.first( blocks ).height == 5
      assert Enum.at( blocks, 4 ).height == 1
      assert List.last( blocks ).height == 0
    end

    test "get next or previous n blocks works with small values and nil" do
      block = Blockchain.get_highest_block_from_db_or_bitcoind()
      blocks = Blockchain.get_next_or_previous_n_blocks(block, 0)
      assert length( blocks ) == 1
      blocks = Blockchain.get_next_or_previous_n_blocks(nil, 0)
      assert length( blocks ) == 1
      blocks = Blockchain.get_next_or_previous_n_blocks(block, 1)
      assert length( blocks ) == 1
      blocks = Blockchain.get_next_or_previous_n_blocks(nil, 1)
      assert length( blocks ) == 1
      blocks = Blockchain.get_next_or_previous_n_blocks(block, 2)
      assert length( blocks ) == 2
      blocks = Blockchain.get_next_or_previous_n_blocks(nil, 2)
      assert length( blocks ) == 2
    end

    test "get next n blocks backward works" do
      block = Blockchain.get_highest_block_from_db_or_bitcoind()
      hash = block.hash
      blocks = Blockchain.get_next_or_previous_n_blocks(block, 20, "previousblockhash")
      assert length( blocks ) == 20
      block = List.first blocks
      first_hash = block.hash
      assert hash == first_hash
      block = Enum.at( blocks, 19 )
      last_hash = block.hash
      blocks = Blockchain.get_next_or_previous_n_blocks(block, 40, "previousblockhash")
      assert length( blocks ) == 40
      block = List.first blocks
      next_first_hash = block.hash
      assert last_hash == next_first_hash
    end

    test "get next n blocks with a nil block works" do
      one = Blockchain.get_n_blocks( nil, 4 )
      block = Blockchain.get_highest_block_from_db_or_bitcoind()
      two = Blockchain.get_next_or_previous_n_blocks( block, 4 )
      a_block = Block.remove_db_specific_keys List.last( one )
      a_nother_block = Block.remove_db_specific_keys List.last( two )
      assert a_block == a_nother_block
    end

# Sometimes you get two blocks identical except one has updated_at: ~N[2020-03-28 15:08:50.000000]
# and the other                                         updated_at: ~N[2020-03-28 15:08:50.489414]
    def equal_except_db_specific_keys( a_block, a_nother ) do
      first = Block.remove_db_specific_keys a_block
      second = Block.remove_db_specific_keys a_nother
      first == second
    end

    test "get next n blocks forward works" do
      original_block = Blockchain.get_highest_block_from_db_or_bitcoind()
      blocks = Blockchain.get_next_or_previous_n_blocks(original_block, 5, "previousblockhash", [original_block])
      first_block = Enum.at( blocks, 4 )
      blocks = Blockchain.get_next_or_previous_n_blocks(first_block, 5, "previousblockhash", [first_block])
      second_block = Enum.at( blocks, 4 )
      assert second_block != first_block
      blocks = Blockchain.get_next_or_previous_n_blocks( second_block, 5, "nextblockhash", [second_block] )
      new_block = Enum.at( blocks, 0 )
      assert new_block.hash == first_block.hash
      blocks = Blockchain.get_next_or_previous_n_blocks( new_block, 5, "nextblockhash", [new_block] )
      another_block = Enum.at( blocks, 0 )
      assert equal_except_db_specific_keys(another_block, original_block)
      blocks = Blockchain.get_next_or_previous_n_blocks( another_block, 5, "nextblockhash", [another_block] )
      assert length( blocks ) == 5
      assert List.first(blocks).hash == another_block.hash
      blocks = Blockchain.get_next_or_previous_n_blocks( another_block, 5, "nextblockhash" )
      assert List.first(blocks).hash == another_block.hash
    end

    test "get blocks functions don't need [ block ] as an argument" do
      block = Blockchain.get_highest_block_from_db_or_bitcoind()
      one = Blockchain.get_n_blocks(block, 4, "previousblockhash", [ block ])
      two = Blockchain.get_n_blocks(block, 4, "previousblockhash", [])
      one = Enum.map( one, &Block.remove_db_specific_keys( &1 ))
      two = Enum.map( two, &Block.remove_db_specific_keys( &1 ))
      assert one == two
      one = Blockchain.get_next_or_previous_n_blocks(block, 4, "previousblockhash", [ block ])
      two = Blockchain.get_next_or_previous_n_blocks(block, 4, "previousblockhash", [])
      assert one == two
    end

  end
end
