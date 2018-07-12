defmodule BlockChainExplorer.TransactionTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Transaction
  alias BlockChainExplorer.Transaction.Output

  describe "transaction" do

    defp has_a_valid_address?( addresses_str_list ) do
      case addresses_str_list do
        nil -> false
        [] -> false
        [ hd | tl ] ->
          cond do
            hd =~ Utils.env( :base_58_address_regex ) -> true
            true -> has_a_valid_address?( tl )
          end
      end
    end

    defp at_least_one_output_has_a_valid_address?( outputs ) do
      case outputs do
        nil -> false
        [] -> false
        [ output | more_outputs ] ->
          cond do
            Utils.mt?( output.scriptpubkey ) -> false
            Utils.mt?( output.scriptpubkey.addresses ) -> false
            has_a_valid_address?( output.scriptpubkey.addresses ) -> true
            true -> at_least_one_output_has_a_valid_address?( more_outputs )
          end
      end
    end

    test "has_output_addresses?" do
      mt_list = []
      assert false == Transaction.has_output_addresses?( mt_list )

      output_modules_no_addresses = [ %Output{
        value: 0.78152,
        scriptpubkey: %{
          hex: "a9141a30c2cb52f5bd4fcbd8697b37b636f9b73ebedf87",
          asm: "OP_HASH160 1a30c2cb52f5bd4fcbd8697b37b636f9b73ebedf OP_EQUAL",
          "addresses": []
        },
        n: 0
      }]
      assert false == Transaction.has_output_addresses?( output_modules_no_addresses )

      list_with_valid_output_module = [ %Output{}, %Output{
        value: 0.78152,
        scriptpubkey: %{
          hex: "a9141a30c2cb52f5bd4fcbd8697b37b636f9b73ebedf87",
          asm: "OP_HASH160 1a30c2cb52f5bd4fcbd8697b37b636f9b73ebedf OP_EQUAL",
          "addresses": [
            "2MudhyEqJ7RzedMPXrReNXDcJ9Hch1AUqdv"
          ]
        },
        n: 0
      }]
      assert true == Transaction.has_output_addresses?( list_with_valid_output_module )
    end

    test "get the transactions on a block" do
      block = Blockchain.get_best_block()
      hash = block[ "previousblockhash" ]
      result = Blockchain.getblock( hash )
      assert :ok == elem( result, 0 )
      transactions = Transaction.get_transaction_strs( block )
      assert length( transactions ) > 0
    end

    test "check transaction" do
      decoded = Transaction.get_a_useful_transaction()
      assert Transaction.outputs_total_value( decoded ) > 0.0
      assert decoded.version > 0
      assert decoded.txid =~ Utils.env( :base_16_hash_regex )
      assert decoded.size > 0
      assert decoded.locktime == 0
      assert decoded.hash =~ Utils.env( :base_16_hash_regex )
    end

    test "outputs" do
      decoded = Transaction.get_a_useful_transaction()
      assert Transaction.has_output_addresses?( decoded.outputs )
      assert at_least_one_output_has_a_valid_address?( decoded.outputs )
      for output <- decoded.outputs do
  #      assert has_a_valid_address?( output.scriptpubkey.addresses )
        assert output.value >= 0.0
        assert Utils.notmt? output.scriptpubkey.type
        assert Utils.notmt? output.scriptpubkey.hex
        assert Utils.notmt? output.scriptpubkey.asm
        assert String.contains?( output.scriptpubkey.asm, "OP_" )
        assert output.n > -1
      end
    end

    test "inputs" do
      decoded = Transaction.get_a_useful_transaction()
      for input <- decoded.inputs do
        assert input.sequence > 0
        assert input.scriptsig["asm"] && input.scriptsig["hex"]
      end
    end

  end
end
