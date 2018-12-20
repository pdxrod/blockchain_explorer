defmodule BlockChainExplorer.DbTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Block
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Repo
  alias BlockChainExplorer.Rpc
  alias BlockChainExplorer.Db
  import Ecto.Query

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

    test "trying to insert the same block into the database twice" do

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

    test "trying to read from database, reading from bitcoind instead" do

    end

  end
end
