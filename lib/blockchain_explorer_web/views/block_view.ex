defmodule BlockChainExplorerWeb.BlockView do
  use BlockChainExplorerWeb, :view

  defp block_link( hash ), do: "<a href='/blocks/#{hash}'>#{hash}</a>"

  defp trans_link( hash ), do: "<a href='/trans/#{hash}'>#{hash}</a><br />"

  def mark_up_block( block ) do
    if %{ } == block do
      ""
    else
      """
      Height:         #{ block.height }
      Hash:           #{ block_link( block.hash ) }
      Previous block: #{ block_link( block.previousblockhash ) }
      Next block:     #{ block_link( block.nextblockhash ) }
      Weight:         #{ block.weight }
      Versionhex:     #{ block.versionhex }
      Version:        #{ block.version }
      Transactions:
      #{ mark_transactions( block.tx ) }
      Time:           #{ block.time }
      Stripped size:  #{ block.strippedsize }
      Size:           #{ block.size }
      Nonce:          #{ block.nonce }
      Merkle root:    #{ block.merkleroot }
      Median time:    #{ block.mediantime }
      Difficulty:     #{ block.difficulty }
      Confirmations:  #{ block.confirmations }
      Chainwork:      #{ block.chainwork }
      Bits:           #{ block.bits }<br />
      <hr />
      """
    end
  end

  def mark_blocks( blocks ) do
    case blocks do
      [ head | tail ] -> mark_up_block( head ) <> mark_blocks( tail )
      _ -> ""
    end
  end

  defp mark_transactions( list ) do
    case list do
      [ head | tail ] -> trans_link( head ) <> mark_transactions( tail )
      _ -> ""
    end
  end

  def mark_up_hash( block ) do
    block_link( block[ "hash" ] )
  end

  def next_button( latest ) do
    disabled = case latest do
      true -> "disabled=\"disabled\""
      _ -> ""
    end
    "<button #{disabled} id=\"next_top\" class=\"btn btn-primary\" data-csrf=\"#{ Plug.CSRFProtection.get_csrf_token }\" data-method=\"post\" data-to=\"/index?p=t\">&lt; next</button>"
  end

  def previous_button() do
    "<button id=\"previous_top\" class=\"btn btn-primary\" data-csrf=\"#{ Plug.CSRFProtection.get_csrf_token }\" data-method=\"post\" data-to=\"/index?n=t\">previous &gt;</button>"
  end

end
