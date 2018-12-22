defmodule BlockChainExplorer.DbTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Transaction
  alias BlockChainExplorer.Address
  alias BlockChainExplorer.Output
  alias BlockChainExplorer.Input
  alias BlockChainExplorer.Block
  alias BlockChainExplorer.Repo
  alias BlockChainExplorer.Rpc
  import Ecto.Query

# This test illustrates the difference between the blocks you get from bitcoind,
# the ones you put in the database, and the ones you get from the database
  describe "db" do

    setup do
      Repo.delete_all(Block)
      Repo.delete_all(Transaction)
      Repo.delete_all(Address)
      Repo.delete_all(Output)
      Repo.delete_all(Input)
      {:ok, hello: "world"} # setup has to return an :ok tuple, it doesn't matter what
    end

    defp read_all_blocks_from_database do
      Repo.all(
        from b in Block,
        select: b,
        where: b.id > -1
      )
    end

    defp read_a_transaction_from_database( hash ) do
      Repo.all(
        from t in Transaction,
        select: t,
        where: t.hash == ^hash
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
      blocks = read_all_blocks_from_database()
      assert length(blocks) == 0
      tuple =
        Rpc.getbestblockhash()
        |> elem( 1 )
        |> Rpc.getblock()
      if elem( tuple, 0 ) != :ok, do: raise "Error getting block"
      block = elem( tuple, 1 )
      decoded = Block.convert_to_struct block
      Repo.insert ( decoded )
      blocks = read_all_blocks_from_database()
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
      Repo.insert ( decoded )
      err = try do
        Repo.insert ( decoded )
        raise "We should not have reached this line, because the previous line should have blown up"
      rescue
        e in Ecto.ConstraintError -> e
      end
      assert err.message =~ ~r/constraint error.+blocks_height_index/s
    end

    test "reading from database" do
      blocks = read_all_blocks_from_database()
      assert length( blocks ) == 0
      blocks = get_blocks_from_bitcoind 5
      assert length( blocks ) == 5
      decoded = Enum.map( blocks, &Block.convert_to_struct/1 )
      for block <- decoded do
        Repo.insert ( block )
      end
      blocks = read_all_blocks_from_database()
      assert length( blocks ) == 5
    end

# There are potentially three types of 'block' - a map from bitcoind, a struct from module Block, and a struct from the db
# This test may be ugly, but it shows how to convert from one block format to another
    test "trying to read from database, reading from bitcoind instead" do
      blocks = read_all_blocks_from_database()
      assert length(blocks) == 0
      blocks = get_blocks_from_bitcoind 5
      assert length( blocks ) == 5
      bitcoind_block = List.last blocks

# %{"bits" => "207fffff", "chainwork" => "confirmations" => 5, "tx" => ["6c19eb77fc79b459046b9f62492fcdf9eff85eb005b15cd9ccd49529b9c58ce3"]...
      keys = Map.keys bitcoind_block
      assert ! Enum.member?( keys, "__meta__" )
      assert ! Enum.member?( keys, :__meta__ )
      assert ! Enum.member?( keys, "id" )
      assert ! Enum.member?( keys, :id )
      assert ! Enum.member?( keys, "block" )
      assert ! Enum.member?( keys, :block )
      assert Enum.member?( keys, "hash" )
      not_db_block = Blockchain.get_from_db_or_bitcoind_by_hash( bitcoind_block["hash"] )

# This doesn't work:      Repo.insert ( bitcoind_block )
      insertable_block = Block.convert_to_struct bitcoind_block
      assert not_db_block == insertable_block

# %BlockChainExplorer.Block{__meta__: #Ecto.Schema.Metadata<:built, "blocks">, bits: "207fffff", block: "bits=\"207fffff\"..."...}
      keys = Map.keys insertable_block
      assert Enum.member?( keys, :__meta__ )
      assert Enum.member?( keys, :block )
      assert Enum.member?( keys, :id )
      assert Enum.member?( keys, :inserted_at )
      assert Enum.member?( keys, :updated_at )
      assert insertable_block.id == nil
      assert insertable_block.block != nil

      map = Block.convert_to_map( ["bits=\"207fffff\"",  "mediantime=1545168218", "inserted_at=", "difficulty=9.4"] )
      assert map == [               bits: "207fffff",     mediantime: 1545168218,  inserted_at: "",difficulty: 9.4]
      db_block = Blockchain.get_from_db_or_bitcoind_by_hash( bitcoind_block["hash"] )
      assert db_block != bitcoind_block
      assert db_block != insertable_block

      keys = Map.keys db_block
      assert Enum.member?( keys, :__meta__ )
      assert Enum.member?( keys, :block )
      assert Enum.member?( keys, :id )
      assert db_block.id != nil
      block_str = db_block.block
      block_map = Block.convert_block_str_to_map( block_str )

# These four blocks are closely related
      assert block_map[ :hash ] == bitcoind_block["hash"]
      assert block_map[ :previousblockhash ] == db_block.previousblockhash
      assert block_map[ :difficulty ] == not_db_block.difficulty
      assert block_map[ :mediantime ] == insertable_block.mediantime

      assert db_block != insertable_block
      db_block = Map.delete( db_block, :__meta__ )
      db_block = Map.delete( db_block, :block )
      db_block = Map.delete( db_block, :id )
      db_block = Map.delete( db_block, :inserted_at )
      db_block = Map.delete( db_block, :updated_at )
      insertable_block = Block.convert_struct( insertable_block )
      assert db_block == insertable_block
    end

    test "convert_to_struct will convert any type of block to the same insertable object" do
      tuple =
        Rpc.getbestblockhash()
        |> elem( 1 )
        |> Rpc.getblock()
      bitcoind_block = elem( tuple, 1 )
      insertable_block = Block.convert_to_struct bitcoind_block
      assert insertable_block.hash == bitcoind_block[ "hash" ]
      Repo.insert( insertable_block )

      blocks = read_all_blocks_from_database()
      db_block = List.first blocks
      db_block = Block.convert_to_struct db_block
      assert insertable_block.hash == db_block.hash
      double_conversion = Block.convert_to_struct insertable_block
      assert insertable_block.hash == double_conversion.hash
    end

    test "finding transactions inserts them in the db" do
      transaction = Transaction.seed_db_and_get_a_useful_transaction()
      hash = transaction.hash
      list = read_a_transaction_from_database hash
      db_transaction = List.first list
      assert db_transaction.hash == hash
      transaction = Transaction.seed_db_and_get_a_useful_transaction()
      assert transaction["hash"] == hash
    end

  end
end
