defmodule BlockChainExplorerWeb.BlockControllerTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Blockchain

  @create_attrs %{id: "df3fbbad4f73b73654518c7b53c82d8fe23f02416554a5bc244fd0266ff9442d"}

  def fixture(:block) do
    {:ok, block} = Blockchain.create_block(@create_attrs)
    block
  end

  describe "index" do
    test "lists some blocks", %{conn: conn} do
      conn = get conn, block_path(conn, :index)
      assert html_response(conn, 200) =~ ~r/Blocks:.+[0-9a-f]+/
    end
  end

  describe "show" do
    test "shows a block", %{conn: conn} do
      conn = get conn, block_path(conn, :show, @create_attrs[ :id ])
      assert html_response(conn, 200) =~ ~r/Block:/
    end
  end

  describe "list" do
    test "lists several block hashes", %{conn: conn} do
      conn = get conn, block_path(conn, :list)
      assert html_response(conn, 200) =~ ~r/[0-9a-f]+[0-9a-f]+/
    end
  end

end
