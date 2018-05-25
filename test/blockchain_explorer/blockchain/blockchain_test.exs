defmodule BlockChainExplorer.BlockchainTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Blockchain

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

    defp get_best_block do
      result = Blockchain.getbestblockhash()
      hash = elem( result, 1 )
      result = Blockchain.getblock( hash )
      elem( result, 1 )
    end

    test "our block is a real one" do
      previous = Blockchain.get_next_or_previous_block( @our_block, :backward )
      hash = previous[ "nextblockhash" ]
      assert hash == @our_block[ "hash" ]
    end

    test "return block with a valid id" do
      block = get_best_block()
      hash = block[ "hash" ]
      assert hash =~ ~r/[0-9a-f]+/
    end

    test "next block works" do
      block = get_best_block()
      hash = block[ "nextblockhash" ]
      assert nil == hash
      previous = Blockchain.get_next_or_previous_block( block, :backward )
      hash = previous[ "nextblockhash" ]
      assert hash =~ ~r/[0-9a-f]+/
    end

    test "previous block works" do
      block = get_best_block()
      hash = block[ "previousblockhash" ]
      assert hash =~ ~r/[0-9a-f]+/
    end

    test "hash works" do
      block = get_best_block()
      hash = block[ "hash" ]
      result = Blockchain.getblock( hash )
      block = elem( result, 1 )
      new_hash = block[ "hash" ]
      assert new_hash =~ ~r/[0-9a-f]+/
      assert new_hash == hash
    end

    test "fail to return the block with an fake id" do
      result = Blockchain.getblock "f0000000000000000000000000000000000000000000000000000000000000ba"
      assert result == {:error, %{"code" => -5, "message" => "Block not found"}}
    end

    test "fail to return the block with a completely invalid id" do
      result = Blockchain.getblock "Foo bar"
      assert result == {:error, %{"code" => -5, "message" => "Block not found"}}
    end

    test "get n blocks backward works" do
      block = get_best_block()
      old_hash = block[ "hash" ]
      blocks = Blockchain.get_n_blocks(block, {}, 3, :backward)
      assert tuple_size( blocks ) == 3
      blocks = Blockchain.get_n_blocks(block, {block}, 2, :backward)
      assert tuple_size( blocks ) == 2
      block = elem( blocks, 0 )
      new_hash = block[ "hash" ]
      assert old_hash == new_hash
      block = elem( blocks, 1 )
      new_hash = block[ "hash" ]
      assert old_hash != new_hash
      blocks = Blockchain.get_n_blocks(block, {block}, 9, :backward)
      assert tuple_size( blocks ) == 9
      blocks = Blockchain.get_n_blocks(block, {}, -1, :backward)
      assert tuple_size( blocks ) == 0
      blocks = Blockchain.get_n_blocks(block, {block}, 1, :backward)
      assert tuple_size( blocks ) == 1
      blocks = Blockchain.get_n_blocks(block, {}, 0, :backward)
      assert tuple_size( blocks ) == 0
    end

    test "get n blocks blows up given an inappropriate direction" do
      block = get_best_block()
      err = try do
        Blockchain.get_n_blocks(block, {block}, 2, :latest)
        raise "We should not have reached this line"
      rescue
        e in RuntimeError -> e
      end
      assert err.message == "direction should be forward or backward, not latest"
    end

    test "get next n blocks backward works" do
      block = get_best_block()
      hash = block[ "hash" ]
      blocks = Blockchain.get_next_or_previous_n_blocks(block, {block}, 20, :backward)
      assert tuple_size( blocks ) == 20
      block = elem( blocks, 0 )
      first_hash = block[ "hash" ]
      assert hash == first_hash
      block = elem( blocks, 19 )
      last_hash = block[ "hash" ]
      blocks = Blockchain.get_next_or_previous_n_blocks(block, {block}, 40, :backward)
      assert tuple_size( blocks ) == 40
      block = elem( blocks, 0 )
      next_first_hash = block[ "hash" ]
      assert last_hash == next_first_hash
    end

    test "get next n blocks forward works" do
      original_block = get_best_block()
      blocks = Blockchain.get_next_or_previous_n_blocks(original_block, {original_block}, 5, :backward)
      first_block = elem( blocks, 4 )
      blocks = Blockchain.get_next_or_previous_n_blocks(first_block, {first_block}, 5, :backward)
      second_block = elem( blocks, 4 )
      assert second_block != first_block
      blocks = Blockchain.get_next_or_previous_n_blocks( second_block, {second_block}, 5, :forward )
      new_block = elem( blocks, 0 )
      assert new_block[ "hash" ] == first_block[ "hash" ]
      blocks = Blockchain.get_next_or_previous_n_blocks( new_block, {new_block}, 5, :forward )
      another_block = elem( blocks, 0 )
      assert another_block == original_block
      blocks = Blockchain.get_next_or_previous_n_blocks( another_block, {another_block}, 5, :forward )
      assert blocks == {another_block}
      blocks = Blockchain.get_next_or_previous_n_blocks( another_block, {}, 5, :forward )
      assert blocks == { }
    end

  end
end
