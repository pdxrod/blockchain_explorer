defmodule BlockChainExplorer.TransactionFinderTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Transaction
  alias BlockChainExplorer.TransactionFinder

  describe "transaction finder test" do

    @a_transaction %{
      "vsize": 184,
      "vout": [
        %{
          "value": 0.78152,
          "scriptPubKey": %{
            "type": "scripthash",
            "reqSigs": 1,
            "hex": "a9141a30c2cb52f5bd4fcbd8697b37b636f9b73ebedf87",
            "asm": "OP_HASH160 1a30c2cb52f5bd4fcbd8697b37b636f9b73ebedf OP_EQUAL",
            "addresses": [ "2MudhyEqJ7RzedMPXrReNXDcJ9Hch1AUqdv" ]
          },
          "n": 0
        },
        %{
          "value": 0.0,
          "scriptPubKey": %{
            "type": "nulldata",
            "hex": "6a24aa21a9ed4967c81d1c2ae8c9a438982483213e5ada29ee685780a397a8cd22ce9e262255",
            "asm": "OP_RETURN aa21a9ed4967c81d1c2ae8c9a438982483213e5ada29ee685780a397a8cd22ce9e262255"
          },
          "n": 1
        }
      ],
      "vin": [
        %{
          "sequence": 4294967295,
          "coinbase": "03190b14042126065b726567696f6e312f50726f6a65637420425443506f6f6c2f020df278d618000000000000"
        }
      ],
      "version": 2,
      "txid": "53a9f958519b4cbecb34c1315980e833a67b6aa5c9e242aab74f49d0a5e9bfb6",
      "size": 211,
      "locktime": 0,
      "hash": "98e8e6534e0fb4a515f314ea7bd7f8d4b63803894feca243c8c9608e0aa8e679"
    }

    defp get_a_useful_transaction do
      Blockchain.get_n_blocks( nil, 100 )
      |> Transaction.transaction_with_everything_in_it_from_tuple()
      |> Transaction.get_transaction_tuple()
      |> Transaction.decode_transaction_tuple()
    end

    def get_an_address( outputs ) do
      [ hd | tl ] = outputs
      addresses = hd.scriptpubkey.addresses
      case addresses do
        nil -> get_an_address( tl )
        [] -> get_an_address( tl )
        _ -> List.first addresses
      end
    end

    test "find" do
      a_transaction = get_a_useful_transaction()
      address_str = get_an_address a_transaction.outputs
      address_str = String.slice address_str, 0..5
      task = TransactionFinder.find_transactions address_str
      try do
        Task.await task
      catch :exit, _ -> IO.puts "\nExit find"
      end
      transactions = TransactionFinder.peek( address_str )
      trans = elem( transactions, 0 )
      assert trans.hash
      assert trans.size
    end

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
      a_transaction = Transaction.decode @a_transaction
      TransactionFinder.put "2Mud", a_transaction
      assert {a_transaction} == TransactionFinder.peek( "2Mud" )
      a_transaction = get_a_useful_transaction()
      address_str = get_an_address a_transaction.outputs
      address_str = String.slice address_str, 0..4
      TransactionFinder.put address_str, a_transaction
      assert {a_transaction} == TransactionFinder.peek( address_str )
    end

  end
end
