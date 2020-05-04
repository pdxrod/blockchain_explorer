defmodule BlockChainExplorer.BitcoinUtilsTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.BitcoinUtils

  describe "utils" do

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
        assert true == false # If this line is ever reached, the test fails
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
