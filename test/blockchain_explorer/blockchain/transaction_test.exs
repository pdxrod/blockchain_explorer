defmodule BlockChainExplorer.TransactionTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Transaction

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
            hd =~ ~r/[1-9a-km-zA-HJ-NP-Z]+/ -> true # alphanumeric, no 0 O I l
            true -> has_valid_addresses?( tl )
          end
      end
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
      assert decoded.txid =~ ~r/[0-9a-f]+/
      assert decoded.size > 0
      assert decoded.locktime == 0
      assert decoded.hash =~ ~r/[0-9a-f]+/
    end

    test "outputs" do
      decoded = get_a_useful_transaction()
      assert Transaction.has_output_addresses?( decoded.outputs )
      for output <- decoded.outputs do
        assert has_valid_addresses?( output.scriptpubkey.addresses )
        assert output.value >= 0.0
        assert output.scriptpubkey.type != nil
  #      assert output.scriptpubkey.reqsigs > 0
        assert output.scriptpubkey.hex != nil
        assert output.scriptpubkey.asm != nil
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
