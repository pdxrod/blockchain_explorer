defmodule BlockChainExplorer.DbTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Block
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Repo
  alias BlockChainExplorer.Rpc
  alias BlockChainExplorer.Db
  import Ecto.Query

# This test illustrates the difference between the blocks you get from bitcoind,
# the ones you put in the database, and the ones you get from the database
  describe "db" do

    setup do
      Repo.delete_all(Block)
      {:ok, hello: "world"} # setup has to return something, for some reason
    end

    defp read_all_blocks_from_database do
      Repo.all(
        from b in Block,
        select: b,
        where: b.id > -1
      )
    end

    defp get_blocks_from_bitcoind( num, hash \\ nil ) do
      case num do
        0 -> []
        _ ->
          case hash do
            nil ->
              tuple =
                Rpc.getbestblockhash()
                |> elem( 1 )
                |> Rpc.getblock()
              if elem( tuple, 0 ) != :ok, do: raise "Error getting block"
              block = elem( tuple, 1 )
              [ block ] ++ get_blocks_from_bitcoind( num - 1, block[ "previousblockhash" ] )
            _ ->
              tuple = Rpc.getblock( hash )
              if elem( tuple, 0 ) != :ok, do: raise "Error getting block"
              block = elem( tuple, 1 )
              [ block ] ++ get_blocks_from_bitcoind( num - 1, block[ "previousblockhash" ] )
          end
      end
    end

    test "inserting into database" do
      blocks = read_all_blocks_from_database
      assert length(blocks) == 0
      tuple =
        Rpc.getbestblockhash()
        |> elem( 1 )
        |> Rpc.getblock()
      if elem( tuple, 0 ) != :ok, do: raise "Error getting block"
      block = elem( tuple, 1 )
      decoded = Block.convert_to_struct block
      Db.insert( decoded )
      blocks = read_all_blocks_from_database
      assert length(blocks) == 1
    end

    test "trying to insert the same block into the database twice, and failing" do
      tuple =
        Rpc.getbestblockhash()
        |> elem( 1 )
        |> Rpc.getblock()
      if elem( tuple, 0 ) != :ok, do: raise "Error getting block"
      block = elem( tuple, 1 )
      decoded = Block.convert_to_struct block
      Db.insert( decoded )
      err = try do
        Db.insert( decoded )
        raise "We should not have reached this line, because the previous line should have blown up"
      rescue
        e in Ecto.ConstraintError -> e
      end
      assert err.message =~ ~r/constraint error.+blocks_height_index/s
    end

    test "reading from database" do
      blocks = read_all_blocks_from_database
      assert length( blocks ) == 0
      blocks = get_blocks_from_bitcoind 5
      assert length( blocks ) == 5
      decoded = Enum.map( blocks, &Block.convert_to_struct/1 )
      for block <- decoded do
        Db.insert( block )
      end
      blocks = read_all_blocks_from_database
      assert length( blocks ) == 5
    end

# There are potentially three types of 'block' - a map from bitcoind, a struct from module Block, and a struct from the db
    test "trying to read from database, reading from bitcoind instead" do
      blocks = read_all_blocks_from_database
      assert length(blocks) == 0
      blocks = get_blocks_from_bitcoind 5
      assert length( blocks ) == 5
      bitcoind_block = List.last blocks
# %{"bits" => "207fffff", "chainwork" => "00000000000000000000000000000000000000000000000000000000000008f4", "confirmations" => 5, "difficulty" => 4.656542373906925e-10, "hash" => "0cfae879e0292aee2226463d889642d8fb7b9660b0e256b84e4830a75b12d543", "height" => 1145, "mediantime" => 1545168218, "merkleroot" => "6c19eb77fc79b459046b9f62492fcdf9eff85eb005b15cd9ccd49529b9c58ce3", "nextblockhash" => "5d9bcc9820beff2d41bcae40d36863a9d9406a739fe8db6508b770487bb8dcf4", "nonce" => 1, "previousblockhash" => "6444357300c564899d117cf4fa10ff122822a6375d52a1c9e8a63ce2c7f85f98", "size" => 264, "strippedsize" => 228, "time" => 1545168219, "tx" => ["6c19eb77fc79b459046b9f62492fcdf9eff85eb005b15cd9ccd49529b9c58ce3"], "version" => 536870912, "versionHex" => "20000000", "weight" => 948}
      keys = Map.keys bitcoind_block
      assert ! Enum.member?( keys, "__meta__" )
      assert ! Enum.member?( keys, :__meta__ )
      assert ! Enum.member?( keys, "id" )
      assert ! Enum.member?( keys, :id )
      assert ! Enum.member?( keys, "block" )
      assert ! Enum.member?( keys, :block )
      assert Enum.member?( keys, "hash" )
      not_db_block = Blockchain.get_from_db_or_bitcoind_by_hash( bitcoind_block["hash"] )
      assert not_db_block == bitcoind_block

# insert it into the db, and show that get_from_db_or_bitcoind_by_hash gets it from the db
# The whole block from bitcoind is put in the block column in the db
# This doesn't work:      Db.insert( bitcoind_block )

      insertable_block = Block.convert_to_struct bitcoind_block
      keys = Map.keys insertable_block
      assert Enum.member?( keys, :__meta__ )
      assert Enum.member?( keys, :block )
      assert Enum.member?( keys, :id )
      assert insertable_block.id == nil
      Db.insert( insertable_block )

# %BlockChainExplorer.Block{__meta__: #Ecto.Schema.Metadata<:built, "blocks">, bits: "207fffff", block: "bits=\"207fffff\",chainwork=\"00000000000000000000000000000000000000000000000000000000000008f4\",confirmations=5,difficulty=4.656542373906925e-10,hash=\"0cfae879e0292aee2226463d889642d8fb7b9660b0e256b84e4830a75b12d543\",height=1145,mediantime=1545168218,merkleroot=\"6c19eb77fc79b459046b9f62492fcdf9eff85eb005b15cd9ccd49529b9c58ce3\",nextblockhash=\"5d9bcc9820beff2d41bcae40d36863a9d9406a739fe8db6508b770487bb8dcf4\",nonce=1,previousblockhash=\"6444357300c564899d117cf4fa10ff122822a6375d52a1c9e8a63ce2c7f85f98\",size=264,strippedsize=228,time=1545168219,tx=6c19eb77fc79b459046b9f62492fcdf9eff85eb005b15cd9ccd49529b9c58ce3,version=536870912,versionHex=\"20000000\",weight=948", chainwork: "00000000000000000000000000000000000000000000000000000000000008f4", confirmations: 5, difficulty: 4.656542373906925e-10, hash: "0cfae879e0292aee2226463d889642d8fb7b9660b0e256b84e4830a75b12d543", height: 1145, id: nil, inserted_at: nil, mediantime: 1545168218, merkleroot: "6c19eb77fc79b459046b9f62492fcdf9eff85eb005b15cd9ccd49529b9c58ce3", nextblockhash: "5d9bcc9820beff2d41bcae40d36863a9d9406a739fe8db6508b770487bb8dcf4", nonce: 1, previousblockhash: "6444357300c564899d117cf4fa10ff122822a6375d52a1c9e8a63ce2c7f85f98", size: 264, strippedsize: 228, time: 1545168219, tx: "6c19eb77fc79b459046b9f62492fcdf9eff85eb005b15cd9ccd49529b9c58ce3", updated_at: nil, version: 536870912, versionhex: "20000000", weight: 948}

      db_block = Blockchain.get_from_db_or_bitcoind_by_hash( bitcoind_block["hash"] )
      assert db_block != bitcoind_block
      assert db_block != insertable_block

      keys = Map.keys db_block
      assert Enum.member?( keys, :__meta__ )
      assert Enum.member?( keys, :block )
      assert Enum.member?( keys, :id )
      assert db_block.id != nil
      block_str = db_block.block
# Test that bitcoind_block is represented as a comma-separated list

      db_block = Map.delete( db_block, :__meta__ )
      db_block = Map.delete( db_block, :block )
      db_block = Map.delete( db_block, :id )
      db_block = Map.delete( db_block, :inserted_at )
      db_block = Map.delete( db_block, :updated_at )
      insertable_block = Map.delete( insertable_block, :__meta__ )
      insertable_block = Map.delete( insertable_block, :block )
      insertable_block = Map.delete( insertable_block, :id )
      insertable_block = Map.delete( insertable_block, :inserted_at )
      insertable_block = Map.delete( insertable_block, :updated_at )
      assert db_block == insertable_block

    end

  end
end
