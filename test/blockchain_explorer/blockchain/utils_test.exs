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
      assert false == Utils.recurse( false, true, @empty_list, &a_condition/1 )
    end

    test "recurse method with no foo map which should fail" do
      assert false == Utils.recurse( false, true, @list_with_no_foo_map, &a_condition/1 )
    end

    test "recurse method with list with foo map but not 0 so it should fail" do
      assert false == Utils.recurse( false, true, @list_with_foo_map_not_0, &a_condition/1 )
    end

    test "recurse method with list with foo map not 0 and [] as its first parameter" do
      assert [] == Utils.recurse( [], true, @list_with_foo_map_not_0, &a_condition/1 )
    end

    test "recurse method with list with foo map and foo is 0 so it should succeed" do
      assert true == Utils.recurse( false, true, @list_with_foo_map_set_to_0, &a_condition/1 )
    end

    test "recurse method with list with foo 0 - should return the list if it succeeds" do
      assert @list_with_foo_map_set_to_0 == Utils.recurse( [], @list_with_foo_map_set_to_0, @list_with_foo_map_set_to_0, &a_condition/1 )
    end

  end
end
