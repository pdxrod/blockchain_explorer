defmodule BlockChainExplorerWeb.BlockView do
  use BlockChainExplorerWeb, :view

  defp block_link( hash ), do: "<a href='/blocks/#{hash}'>#{hash}</a>"

  defp trans_link( hash ), do: "<code><a href='/trans/#{hash}'>#{hash}</a></code><br />"

  def mark_up_block( block ) do
    if %{ } == block do
      ""
    else
      """
      Height:         #{ block.height } <br />
      Hash:           #{ block_link( block.hash ) } <br />
      Previous block: #{ block_link( block.previousblockhash ) } <br />
      Next block:     #{ block_link( block.nextblockhash ) } <br />
      Weight:         #{ block.weight } <br />
      Versionhex:     #{ block.versionhex } <br />
      Version:        #{ block.version } <br />
      Transactions:                      <br />
      #{ mark_transactions( block.tx ) }
      Time:           #{ block.time } <br />
      Stripped size:  #{ block.strippedsize } <br />
      Size:           #{ block.size } <br />
      Nonce:          #{ block.nonce } <br />
      Merkle root:    #{ block.merkleroot } <br />
      Median time:    #{ block.mediantime } <br />
      Difficulty:     #{ block.difficulty } <br />
      Confirmations:  #{ block.confirmations } <br />
      Chainwork:      #{ block.chainwork } <br />
      Bits:           #{ block.bits } <br /><br />
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

  def previous_button( last ) do
    disabled = case last do
      true -> "disabled=\"disabled\""
      _ -> ""
    end
    "<button #{disabled} id=\"previous_top\" class=\"btn btn-primary\" data-csrf=\"#{ Plug.CSRFProtection.get_csrf_token }\" data-method=\"post\" data-to=\"/index?n=t\">previous &gt;</button>"
  end

end
