defmodule BlockChainExplorer.TransactionTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Transaction
  alias BlockChainExplorer.Transaction.Output

  describe "transaction" do

    defp get_a_useful_transaction do
      result = Blockchain.get_latest_block()
      block = elem( result, 1 )
      blocks = Blockchain.get_n_blocks( block, 100 )
      trans = Transaction.transaction_with_everything_in_it_from_tuple( blocks )
      tuple = Transaction.get_transaction_tuple( trans )
      Transaction.decode_transaction( tuple )
    end

    defp has_valid_addresses?( addresses_str_list ) do
      case addresses_str_list do
        [] -> false
        [ hd | tl ] ->
          cond do
            hd =~ Utils.env( :base_58_address_regex ) -> true
            true -> has_valid_addresses?( tl )
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
      result = Blockchain.get_latest_block()
      assert :ok == elem( result, 0 )
      block = elem( result, 1 )
      hash = block[ "previousblockhash" ]
      result = Blockchain.getblock( hash )
      assert :ok == elem( result, 0 )
      transactions = Transaction.get_transaction_strs( block )
      assert length( transactions ) > 0
    end

    test "check transaction" do
      decoded = get_a_useful_transaction()
      assert Transaction.outputs_total_value( decoded ) > 0.0
      assert decoded.version > 0
      assert decoded.txid =~ Utils.env( :base_16_hash_regex )
      assert decoded.size > 0
      assert decoded.locktime == 0
      assert decoded.hash =~ Utils.env( :base_16_hash_regex )
    end

    test "outputs" do
      decoded = get_a_useful_transaction()
      assert Transaction.has_output_addresses?( decoded.outputs )
      for output <- decoded.outputs do
        assert has_valid_addresses?( output.scriptpubkey.addresses )
        assert output.value >= 0.0
        assert Utils.notmt? output.scriptpubkey.type
  #      assert output.scriptpubkey.reqsigs > 0
        assert Utils.notmt? output.scriptpubkey.hex
        assert Utils.notmt? output.scriptpubkey.asm
        assert output.n > -1
      end
    end

    test "inputs" do
      decoded = get_a_useful_transaction()
      for input <- decoded.inputs do
        assert input.sequence > 0
        assert input.scriptsig["asm"] && input.scriptsig["hex"]
      end
    end

  end
end
