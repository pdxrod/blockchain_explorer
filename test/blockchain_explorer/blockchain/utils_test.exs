defmodule BlockChainExplorer.UtilsTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Utils

  describe "utils" do

    @empty_list []
    @list_with_no_foo_map [ %{bar: 0}, %{hello: "world"} ]
    @list_with_foo_map_not_0 [ %{bar: 0}, %{hello: "world", foo: 1} ]
    @list_with_foo_map_set_to_0 [ %{}, %{hello: "world", foo: 0}, %{bar: 1} ]

# Does this map have a key :foo with value zero?
    defp a_condition( a_map ) do
      a_map[ :foo ] == 0
    end

    test "recurse method with empty list which should fail" do
      assert ! Utils.recurse( false, true, @empty_list, Enum.map( @empty_list, fn( map ) -> a_condition( map ) end))
    end

    test "recurse method with no foo map which should fail" do

    end

    test "recurse method with list with foo map but not 0 so it should fail" do

    end

    test "recurse method with list with foo map and foo is 0 so it should succeed" do

    end

  end
end
