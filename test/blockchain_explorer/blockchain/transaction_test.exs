defmodule BlockChainExplorer.TransactionTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Transaction

  describe "transaction" do

    test "check transaction" do
      decoded = Transaction.seed_db_and_get_a_useful_transaction() |> Transaction.convert_to_struct()
      assert Transaction.outputs_total_value( decoded ) > 0.0
      assert decoded.version > 0
      assert decoded.txid =~ Utils.env( :base_16_hash_regex )
      assert decoded.size > 0
      assert decoded.locktime == 0
      assert decoded.hash =~ Utils.env( :base_16_hash_regex )
    end

    test "outputs" do
      trans = Transaction.seed_db_and_get_a_useful_transaction()
      assert length( Transaction.get_addresses( trans.id )) > 0

      for output <- Transaction.get_outputs( trans.id ) do
        assert output.value >= 0.0
        assert Utils.notmt? output.hex
        assert Utils.notmt? output.asm
        assert String.contains?( output.asm, "OP_" )
        assert output.n > -1
      end
    end

    test "inputs" do
      decoded = Transaction.seed_db_and_get_a_useful_transaction() |> Transaction.convert_to_struct()
      inputs = Transaction.get_inputs decoded.id
      for input <- inputs do
        assert input.sequence > 0
        if Utils.mode != "regtest", do: assert input.scriptsig["asm"] && input.scriptsig["hex"]
      end
    end

  end
end
