defmodule BlockChainExplorer.UtilsTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Utils

  describe "utils" do

    @empty_list []
    @list_with_no_foo_map [ %{bar: 0}, %{hello: "world"} ]
    @list_with_foo_map_not_0 [ %{bar: 0}, %{hello: "world", foo: 1} ]
    @list_with_foo_map_set_to_0 [ %{}, %{hello: "world", foo: 0}, %{bar: 1} ]

    test "typeof" do
      assert "binary" == Utils.typeof( "Hello" )
      assert "list" == Utils.typeof( 'Hello' )
      assert "list" == Utils.typeof( [:a, :b] )
      assert "atom" == Utils.typeof( :foo )
      assert "map" == Utils.typeof( %{} )
      assert "map" == Utils.typeof( %{foo: :bar} )
      assert "tuple" == Utils.typeof( {:foo, "Hello"} )
    end

    test "mt?" do
      for thing <- [nil, "", '', %{}, [], {}] do
        assert Utils.mt? thing
        assert !(Utils.notmt? thing)
      end
      assert !(Utils.mt? "Hello")
      assert Utils.notmt? "Hello"
    end

    test "env" do
      assert Application.get_env( :blockchain_explorer, :bitcoin_url )
      assert Utils.env( :bitcoin_url ) == Application.get_env( :blockchain_explorer, :bitcoin_url )
    end

    test "is_in_list?" do
      assert ! Utils.is_in_list?( [], :foo )
      assert ! Utils.is_in_list?( [ :foo, :bar ], { :baz } )
      assert Utils.is_in_list?( [ :foo, :bar, {:baz} ], { :baz } )
    end

    test "Utils.is_in_tuple?" do
      assert ! Utils.is_in_tuple?( { }, :foo )
      assert ! Utils.is_in_tuple?( { :foo, :bar }, :baz )
      assert Utils.is_in_tuple?( { :foo, :bar, :baz }, :baz )
    end

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

    test "recurse method with list with foo 0 and anonymous function" do
      assert :bar == Utils.recurse( :foo, :bar, @list_with_foo_map_set_to_0, fn(map) -> map[ :foo ] == 0 end)
    end

    test "collections with Elixir 1.7.2" do
      tuple = Utils.tuple_test 0
      assert tuple == {:one}
      tuple = Utils.tuple_test 1
      assert tuple == {:one}
      tuple = Utils.tuple_test 2
      assert tuple == {:more_than_one}
      tuple = Utils.tuple_test 99
      assert tuple == {:more_than_one}
    end

    test "bitcoin mode" do
      result = Utils.mode
      assert result == "main" || result == "test" || result == "regtest"
    end

# Some of these are IRL errors
    @tests [ {  {:message, %{message: {:message, "message"}}},                       %{message: "message"} },
             {  {:error, :invalid, 0},                                               %{error: "0"} },
             {  {:error, %HTTPoison.Error{id: nil, reason: :timeout}} ,              %{error: "timeout"} },
             {  {:error, %HTTPoison.Error{id: nil, reason: :econnrefused}},          %{error: "econnrefused"} },
             {  {:error, %{"code" => -28, "message" => "Loading block index..."}},   %{error: "Loading block index..."} },
             {  {:error, %{"code" => -5, "message" => "Block not found"}},           %{error: "Block not found"} },
             {  {:error, %{"code" => -1, "message" => "JSON integer out of range"}}, %{error: "JSON integer out of range"} },
             {  {:error, %{"code" => -8, "message" => "Block height out of range"}}, %{error: "Block height out of range"} },
             {  {:error, %{connect: :econnrefused}},                                 %{error: "econnrefused"} },
             {  {:error, %{connect: 'econnrefused'}},                                %{error: "100"} } # Can you work out why?
           ]

    test "flatten not-ok tuple" do
      assert "#{[ 1, [1, "bar"], "baz"]}" == <<1, 1, 98, 97, 114, 98, 97, 122>>
      err = try do
        Utils.error {:ok, :this, "message"}
        raise "We should not have reached this line - the previous line should have resulted in an exception"
      rescue
        r in RuntimeError -> r
      end
      assert err.message == "Utils.error should not be used with tuples beginning with :ok"

      for pair <- @tests do
        reality = Utils.error elem( pair, 0 )
        desire = elem( pair, 1 )
        assert reality == desire
      end
    end

  end
end
