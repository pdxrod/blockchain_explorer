defmodule BlockChainExplorerWeb.TransactionView do
  use BlockChainExplorerWeb, :view

  def mark_up_transaction( transaction ) do
    """
    Vsize:   #{ transaction.vsize }<br />
    Version: #{ transaction.version }<br />
    Txid:    #{ transaction.txid }<br />
    Size:    #{ transaction.size }<br />
    Hash:    #{ transaction.hash }<br /> <br />
    """
  end

  def mark_up_outputs( outputs_list ) do
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
        #{ output.n }<br />
        Value: #{ output.value }<br />
        Addresses: <br />
    """ <> mark_up_addresses( output.scriptpubkey.addresses )
  end

  defp mark_up_addresses( addresses_list ) do
    case addresses_list do
      [ head | tail ] -> "&nbsp;&nbsp;#{ head }<br />\n " <> mark_up_addresses( tail )
      _ -> "<br />\n "
    end
  end

  defp mark_input( input ) do
    """
    Sequence: #{ input.sequence }   <br />
    Txid:     #{ input.txid     }   <br />
    Scriptsig:                      <br />
    &nbsp;&nbsp;asm: #{ input.scriptsig["asm"] }<br />
    &nbsp;&nbsp;hex: #{ input.scriptsig["hex"] }<br /> <br />
    """
  end
end
