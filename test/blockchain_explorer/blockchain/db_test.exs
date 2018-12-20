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

    test "reading from database" do
    end

    test "trying to read from database, reading from bitcoind instead" do

    end

  end
end
