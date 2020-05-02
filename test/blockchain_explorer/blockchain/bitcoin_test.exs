defmodule BlockChainExplorer.BitcoinTest do
  use BlockChainExplorerWeb.ConnCase

  alias Bitcoin.Script

  alias BlockChainExplorer.Transaction
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.BitcoinUtils

  describe "bitcoin" do

    defp get_op( outputs ) do
      case outputs do
        [] -> nil
        [ hd | tl ] ->
          cond do
            String.contains?( hd.asm, "OP_" ) -> hd.asm
            true -> get_op( tl )
          end
      end
    end

    test "simple" do
      assert true == [2, 3, :OP_ADD, 5, :OP_EQUAL] |> Script.verify
      assert false ==[2, 3, :OP_ADD, 4, :OP_EQUAL] |> Script.verify
    end

    test "outputs" do
      trans = Transaction.seed_db_and_get_a_useful_transaction()
      op_asm = get_op Transaction.get_outputs( trans.id )
      assert true == String.starts_with?( op_asm, "OP_" )
      parts = String.split( op_asm, " " )
      operator = Enum.at parts, 0
      content = Enum.at parts, 1
      hex_list = BitcoinUtils.make_hex_list content
      assert (String.size content) * 2 == length hex_list
    end

  end
end
