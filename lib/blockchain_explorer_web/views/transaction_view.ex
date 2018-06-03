defmodule BlockChainExplorerWeb.TransactionView do
  use BlockChainExplorerWeb, :view

  def mark_up_inputs( inputs_list ) do
    if length( inputs_list ) > 0 do
      case inputs_list do
        [ head | tail ] -> Enum.join( [mark_input( head )], mark_up_inputs( tail )) 
        _ -> []
      end
    else
      ""
    end
  end

  defp mark_input( input ) do
    """
    Sequence: #{ input.sequence }   <br />
    Txid:     #{ input.txid     }   <br />
    Scriptsig:                      <br />
    asm: #{ input.scriptsig["asm"] }<br />
    hex: #{ input.scriptsig["hex"] }<br />
    """
  end
end
