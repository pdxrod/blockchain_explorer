defmodule BlockChainExplorer.TransactionFinderTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Utils


  alias BlockChainExplorer.Transaction
  alias BlockChainExplorer.TransactionFinder

  describe "transaction finder test" do

    defp at_least_one_output_has_at_least_one_address( transaction ) do
      addresses = Transaction.get_addresses transaction.id
      Utils.notmt? addresses
    end

    @loop 9           # should correspond to LOOP and TIME in the Javascript
    @time 5_000

    @tag timeout: :infinity
    test "two simultaneous puts and finds" do
      a_transaction = Transaction.seed_db_and_get_a_useful_transaction()
      if (Utils.mt? a_transaction), do: raise "Unable to find a transaction with inputs and outputs"
      addresses = Transaction.get_addresses a_transaction.id
      address = List.first addresses
      address_str = address.address
      address_str = String.slice address_str, 0..4

      TransactionFinder.put address_str, a_transaction
      transactions = Transaction.get_transactions
      a_nother_transaction = List.last transactions
      assert a_transaction.txid != a_nother_transaction.txid
      TransactionFinder.put "2Mud", a_nother_transaction

      TransactionFinder.find_transactions address_str
      TransactionFinder.find_transactions "2Mud"
      for n <- 1..@loop do
        TransactionFinder.peek( "2Mud" )
        :timer.sleep( @time )
        if n == @loop do
          transaction = TransactionFinder.peek( "2Mud" )
          assert Utils.notmt? transaction
        end
      end

      transactions = TransactionFinder.peek( address_str )
      trans = elem( transactions, 0 )
      assert at_least_one_output_has_at_least_one_address( trans )
    end

  end
end
