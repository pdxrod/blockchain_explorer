defmodule BlockChainExplorerWeb.BlockControllerTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Blockchain

  describe "show" do
    test "shows a block", %{conn: conn} do
      result = Blockchain.get_latest_block()
      block = elem( result, 1 )
      blocks = Blockchain.get_n_blocks( block, 2 )
      block = elem( blocks, 1 )
      conn = get conn, block_path(conn, :show, block[ "hash" ] )
      assert html_response(conn, 200) =~ ~r/Height:.*[0-9]+/
    end
  end

  describe "list" do
    test "lists several block hashes", %{conn: conn} do
      conn = get conn, block_path(conn, :list)
      assert html_response(conn, 200) =~ ~r/[0-9a-f]+[0-9a-f]+/
    end
  end

end
