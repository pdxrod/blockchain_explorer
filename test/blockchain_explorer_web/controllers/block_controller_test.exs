defmodule BlockChainExplorerWeb.BlockControllerTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Blockchain

  describe "show" do
    test "shows a block", %{conn: conn} do
      block = Blockchain.get_highest_block_from_db_or_bitcoind()
      blocks = Blockchain.get_n_blocks( block, 2 )
      block = List.first blocks
      conn = get conn, block_path(conn, :show, id: block.hash )
      assert html_response(conn, 200) =~ ~r/Height:.*[0-9]+/
    end
  end

  describe "index" do
    test "lists several block hashes", %{conn: conn} do
      conn = get conn, block_path(conn, :index)
      assert html_response(conn, 200) =~ ~r/[0-9a-f]+[0-9a-f]+/
    end
  end

end
