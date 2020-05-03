defmodule BlockChainExplorer.BitcoinUtilsTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.BitcoinUtils

  describe "utils" do

    @empty_list []
    @list_with_no_foo_map [ %{bar: 0}, %{hello: "world"} ]
    @list_with_foo_map_not_0 [ %{bar: 0}, %{hello: "world", foo: 1} ]
    @list_with_foo_map_set_to_0 [ %{}, %{hello: "world", foo: 0}, %{bar: 1} ]

    test "bitcoin utils good" do
      list = BitcoinUtils.hex_list nil
      assert [] == list
      list = BitcoinUtils.hex_list "a0110f00"
      assert [160, 17, 15, 0] == list
      list = BitcoinUtils.hex_list ""
      assert [] == list
    end

    test "bitcoin utils bad" do
      err = try do
        BitcoinUtils.hex_list "a"
        assert true == false
      rescue
        r in RuntimeError -> r
      end
      assert err.message =~ ~r/even number of characters/
      err = try do
        BitcoinUtils.hex_list "a12"
        assert true == false
      rescue
        r in RuntimeError -> r
      end
      assert err.message =~ ~r/even number of characters/
      err = try do
        BitcoinUtils.hex_list "g12f"
        assert true == false
      rescue
        r in RuntimeError -> r
      end
      assert err.message =~ ~r/not a valid hex string/
    end
  end
end
