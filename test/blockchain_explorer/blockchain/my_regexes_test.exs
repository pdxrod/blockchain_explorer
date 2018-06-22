defmodule BlockChainExplorer.MyRegexesTest do
  use BlockChainExplorerWeb.ConnCase

  describe "my regexes" do
    @base_58_address    "2MtiNuyRfvx8jHEpt3Zx5tCcEutJUh7gAmi"
    @base_58_invalid    "0OtiNuyRfvx8jHEpt3Zx5tCcEutJUh7gAmi"
    @base_58_exclusions ~w{ O I } # Some valid addresses include 0 or l
    @base_16_hash       "1f0d81065545bba0d42886b6f0fbf67cf5c5000dcfe663448ef4a37d031f9dea"
    @base_16_invalid    "0d81065545bba0d42886b6f0fbf67cf5c5g500dcfe663448ef4a37d031f9deaz"
    @base_16_too_short  "1f0d81065545bba0d42886b6f0fbf67cf5c5000dcfe663448ef4a37d031f9de"
    @base_16_too_long   "1f0d81065545bba0d42886b6f0fbf67cf5c5000dcfe663448ef4a37d031f9deaa"

    test "my base 10 regex is valid" do
      base_10_integer_regex = Application.get_env(:blockchain_explorer, :base_10_integer_regex)
      assert "9" =~ base_10_integer_regex
      assert "90" =~ base_10_integer_regex
      assert !("7f" =~ base_10_integer_regex)
      assert !( "" =~ base_10_integer_regex)
    end

    test "my base 58 regex is valid" do
      base_58_address_regex = Application.get_env(:blockchain_explorer, :base_58_address_regex)
      for ch <- @base_58_exclusions do
        assert ! String.contains?( @base_58_address, ch )
      end
      assert @base_58_address =~ base_58_address_regex
      assert !( "2MtiN" =~ base_58_address_regex )
      assert !( @base_58_invalid =~ base_58_address_regex )
    end

    test "my partial base 58 regex is valid" do
      base_58_partial_regex = Application.get_env(:blockchain_explorer, :base_58_partial_regex)
      assert @base_58_address =~ base_58_partial_regex
      assert "2MtiN" =~ base_58_partial_regex
      assert "44aaaa" =~ base_58_partial_regex
      assert "44aaa"  =~ base_58_partial_regex
      assert !( "44aa" =~ base_58_partial_regex )
      assert !( "" =~ base_58_partial_regex )
    end

    test "my base 16 tests are valid" do
      base_16_regex = Application.get_env(:blockchain_explorer, :base_16_regex)
      assert !( @base_16_invalid =~ base_16_regex )
      assert 64 == String.length @base_16_hash
      assert 64 > String.length @base_16_too_short
      assert 64 < String.length @base_16_too_long
    end

    test "my base 16 regex is valid" do
      base_16_hash_regex = Application.get_env(:blockchain_explorer, :base_16_hash_regex)
      assert @base_16_hash =~ base_16_hash_regex
      assert !( @base_16_invalid =~ base_16_hash_regex )
      assert !( @base_16_too_short =~ base_16_hash_regex )
      assert !( @base_16_too_long =~ base_16_hash_regex )
    end

  end
end
