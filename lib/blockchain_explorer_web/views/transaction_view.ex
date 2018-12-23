defmodule BlockChainExplorerWeb.TransactionView do
  use BlockChainExplorerWeb, :view

# IF transaction vin has coinbase, it's the first transaction in this block
# "vin": [  %{
#  "sequence": 4294967295,
#  "coinbase": "03190b14042126065b726567696f6e312f50726f6a65637420425443506f6f6c2f020df278d618000000000000"}
# ]

  defp trans_link( hash ), do: ["<a href='/trans/#{hash}'>#{hash}</a><br />"]

  defp addr_link( addr ), do: "<a href='/transactions/#{addr}'>#{addr}</a><br />"

  def mark_up_transaction( transaction ) do
    """
    <b>Txid:</b> #{ trans_link transaction.txid }   <br />
    Vsize:       #{ transaction.vsize }  <br />
    Version:     #{ transaction.version} <br />
    Size:        #{ transaction.size }   <br />
    Hash:        #{ transaction.hash }   <br /><br />
    """ <> "Outputs:<br/>\n" <> mark_up_outputs( transaction, Transaction.get_outputs( transaction.id )) <>
           "Inputs:<br/>\n"  <> mark_up_inputs( transaction, Transaction.get_inputs( transaction.id ))
  end

  defp mark_up_outputs( transaction, outputs ) do
    case outputs do
      [ head | tail ] -> mark_output( transaction, head ) <> mark_up_outputs( transaction, tail )
      _ -> ""
    end
  end

  defp mark_up_inputs( transaction, inputs ) do
    case inputs do
      [ head | tail ] -> mark_input( transaction, head ) <> mark_up_inputs( transaction, tail )
      _ -> ""
    end
  end

  defp asm_truncate( long_str ) do
    String.slice( long_str, 0..31 ) <> "..."
  end

  defp mark_output( transaction, output ) do
    """
        #{ output.n }<br />
        Value: #{ output.value }<br />
        Asm:
        <span id="#{ transaction.txid }_output_asm" style="display :none">#{ output.asm }</span>
        &nbsp;&nbsp;#{ asm_truncate output.asm }<br />
        Addresses: <br />
    """ <> mark_up_addresses( output.addresses )
  end

  defp mark_up_addresses( addresses_list ) do
    case addresses_list do
      [ head | tail ] -> "&nbsp;&nbsp;#{ addr_link( head ) }\n" <> mark_up_addresses( tail )
      _ -> "<br />\n "
    end
  end

  defp mark_input( transaction, input ) do
    """
    Sequence: #{ input.sequence           }<br />
    Coinbase: #{ input.coinbase           }<br />
    Txid:     #{ trans_link input.txid    }
    Asm:
    <span id="#{ transaction.txid }_input_asm" style="display: none">#{ input.scriptsig["asm"] }</span>
    &nbsp;&nbsp;#{ asm_truncate input.scriptsig["asm"] }<br />
    Hex:
    <span id-"#{ transaction.txid }_input_hex" style="display :none">#{ input.scriptsig["hex"] }</span>
    &nbsp;&nbsp;#{ asm_truncate input.scriptsig["hex"] }<br /><br />
    """
  end
end
