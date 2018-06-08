defmodule BlockChainExplorer.UtilsTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Utils

  describe "utils" do

    defp a_recursive_method( a_list ) do
      case a_list do
        [] -> false
        [hd | tl] ->
          cond do
            hd[ "foo" ] && hd[ "foo" ] > 0 -> true
            true -> a_recursive_method( tl )
          end
      end
    end

    test "recurse method with empty list which should fail" do
      recurse( false, true, [], fn( list ) -> a_recursive_method( list ) end)
    end

    test "recurse method with list which should succeed" do

    end

    test "recurse method with list with foo but not > 0 so it should fail" do

    end

    test "recurse method with list with foo and > 0 so it should succeed" do

    end

  end
end
