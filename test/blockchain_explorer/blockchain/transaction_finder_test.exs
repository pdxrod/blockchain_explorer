defmodule BlockChainExplorer.TransactionFinderTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Transaction
  alias BlockChainExplorer.TransactionFinder

  describe "transaction finder test" do

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
      trans = get_a_useful_transaction()
      address_str = get_an_address trans.outputs
      address_str = String.slice address_str, 0..5
      task = TransactionFinder.find_transactions address_str
      try do
        Task.await task
      catch :exit, _ -> IO.puts "\nExit find"
      end
    end

  end
end
