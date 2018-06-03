defmodule BlockChainExplorerWeb.TransactionView do
  use BlockChainExplorerWeb, :view

  def mark_up_outputs( outputs_list ) do

IO.write "mark_up_outputs outputs_list - "
IO.inspect outputs_list

    case outputs_list do
      [ head | tail ] -> mark_output( head ) <> mark_up_outputs( tail )
      _ -> ""
    end
  end

  def mark_up_inputs( inputs_list ) do
    case inputs_list do
      [ head | tail ] -> mark_input( head ) <> mark_up_inputs( tail )
      _ -> ""
    end
  end

  defp mark_output( output ) do
    """
        N: #{ output.n }<br />\n
        Addresses: <br />\n
    """ <> mark_up_addresses( output.scriptpubkey.addresses )
  end

  defp mark_up_addresses( addresses_list ) do
    case addresses_list do
      [ head | tail ] -> "#{ head }<br />\n" <> mark_up_addresses( tail )
      _ -> ""
    end
  end

  defp mark_input( input ) do
    """
    Sequence: #{ input.sequence }   <br />
    Txid:     #{ input.txid     }   <br />\n
    Scriptsig:                      <br />
    asm: #{ input.scriptsig["asm"] }<br />\n
    hex: #{ input.scriptsig["hex"] }<br />\n
    """
  end
end
