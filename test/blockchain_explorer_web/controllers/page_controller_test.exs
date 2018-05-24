defmodule BlockChainExplorerWeb.PageControllerTest do
  use BlockChainExplorerWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 302) =~ ~r/You are being.+\/blocks.+redirected/
  end
end
