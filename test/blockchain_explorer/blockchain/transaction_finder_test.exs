defmodule BlockChainExplorer.TransactionFinderTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Utils


  alias BlockChainExplorer.Transaction
  alias BlockChainExplorer.TransactionFinder

  describe "transaction finder test" do

    @a_transaction %{
      "vsize" => 184,
      "vout" => [
        %{
          "value" => 0.78152,
          "scriptPubKey" => %{
            "type" => "scripthash",
            "reqSigs" => 1,
            "hex" => "a9141a30c2cb52f5bd4fcbd8697b37b636f9b73ebedf87",
            "asm" => "OP_HASH160 1a30c2cb52f5bd4fcbd8697b37b636f9b73ebedf OP_EQUAL",
            "addresses" => [ "2MudhyEqJ7RzedMPXrReNXDcJ9Hch1AUqdv" ]
          },
          "n" => 0
        },
        %{
          "value" => 0.0,
          "scriptPubKey" => %{
            "type" => "nulldata",
            "hex" => "6a24aa21a9ed4967c81d1c2ae8c9a438982483213e5ada29ee685780a397a8cd22ce9e262255",
            "asm" => "OP_RETURN aa21a9ed4967c81d1c2ae8c9a438982483213e5ada29ee685780a397a8cd22ce9e262255"
          },
          "n" => 1
        }
      ],
      "vin" => [
        %{
          "sequence" => 4294967295,
          "coinbase" => "03190b14042126065b726567696f6e312f50726f6a65637420425443506f6f6c2f020df278d618000000000000"
        }
      ],
      "version" => 2,
      "txid" => "53a9f958519b4cbecb34c1315980e833a67b6aa5c9e242aab74f49d0a5e9bfb6",
      "size" => 211,
      "locktime" => 0,
      "hash" => "98e8e6534e0fb4a515f314ea7bd7f8d4b63803894feca243c8c9608e0aa8e679"
    }

    @a_transaction_without_addresses %{
      "vsize" => 184,
      "vout" => [
        %{
          "value" => 0.78152,
          "scriptPubKey" => %{
            "type" => "scripthash",
            "reqSigs" => 1,
            "hex" => "a9141a30c2cb52f5bd4fcbd8697b37b636f9b73ebedf87",
            "asm" => "OP_HASH160 1a30c2cb52f5bd4fcbd8697b37b636f9b73ebedf OP_EQUAL",
            "addresses" => [ ]
          },
          "n" => 0
        },
        %{
          "value" => 0.0,
          "scriptPubKey" => %{
            "type" => "nulldata",
            "hex" => "6a24aa21a9ed4967c81d1c2ae8c9a438982483213e5ada29ee685780a397a8cd22ce9e262255",
            "asm" => "OP_RETURN aa21a9ed4967c81d1c2ae8c9a438982483213e5ada29ee685780a397a8cd22ce9e262255"
          },
          "n" => 1
        }
      ],
      "vin" => [
        %{
          "sequence" => 4294967295,
          "coinbase" => "03190b14042126065b726567696f6e312f50726f6a65637420425443506f6f6c2f020df278d618000000000000"
        }
      ],
      "version" => 2,
      "txid" => "53a9f958519b4cbecb34c1315980e833a67b6aa5c9e242aab74f49d0a5e9bfb6",
      "size" => 211,
      "locktime" => 0,
      "hash" => "98e8e6534e0fb4a515f314ea7bd7f8d4b63803894feca243c8c9608e0aa8e679"
    }

    test "only accepts transactions" do
      err = try do
        TransactionFinder.put "2Mud", "This is not a transaction"
        raise "We should not have reached this line"
      rescue
        e in RuntimeError -> e
      end
      assert err.message == "TransactionFinder only accepts transactions"
    end

    test "stack" do
      TransactionFinder.put "2Mud", @a_transaction
      tuple = TransactionFinder.peek( "2Mud" )
      assert elem( tuple, 0 ) == @a_transaction
      a_transaction = Transaction.get_a_useful_transaction()
      address_str = Transaction.get_an_address a_transaction["vout"]
      address_str = String.slice address_str, 0..4
      TransactionFinder.put address_str, a_transaction
      tuple = TransactionFinder.peek( address_str )
      assert elem( tuple, 0 ) == a_transaction
    end

    defp at_least_one_output_has_at_least_one_address( outputs ) do
      if Utils.mt? outputs do
        false
      else
        [ hd | tl ] = outputs
        cond do
          Utils.notmt?( hd["scriptPubKey"]["addresses"] ) -> true
          true -> at_least_one_output_has_at_least_one_address( tl )
        end
      end
    end

    test "at_least_one_output_has_at_least_one_address" do
      assert at_least_one_output_has_at_least_one_address( @a_transaction["vout"] )
      assert ! at_least_one_output_has_at_least_one_address( @a_transaction_without_addresses["vout"] )
    end

    # Should be the same as LOOP and TIME in the Javascript
    @loop 12
    @time 12_000

    @tag timeout: :infinity
    test "two simultaneous puts and finds" do
      a_transaction = Transaction.get_a_useful_transaction()
      address_str = Transaction.get_an_address a_transaction["vout"]
      address_str = String.slice address_str, 0..4
      TransactionFinder.put address_str, a_transaction
      TransactionFinder.put "2Mud", @a_transaction
      TransactionFinder.find_transactions address_str
      TransactionFinder.find_transactions "2mud"
      for n <- 1..@loop do
        TransactionFinder.peek( "2Mud" )
        :timer.sleep( @time )
        if n == @loop do
          transactions = TransactionFinder.peek( "2Mud" )
          trans = elem( transactions, 0 )
          assert at_least_one_output_has_at_least_one_address( trans["vout"] )
        end
      end
      transactions = TransactionFinder.peek( address_str )
      trans = elem( transactions, 0 )
      assert at_least_one_output_has_at_least_one_address( trans["vout"] )
    end

  end
end
