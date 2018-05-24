defmodule BlockChainExplorerWeb.BlockView do
  use BlockChainExplorerWeb, :view

  defp block_link(hash), do: "<a href='/blocks/#{hash}'>#{hash}</a>"

  defp trans_link( hash ), do: ["<a href='/trans/#{hash}'>#{hash}</a>"]

  def mark_up_block(block) do
    if map_size( block ) > 0 do
      block
      |> Map.put( "previousblockhash", block_link( block["previousblockhash"] ))
      |> Map.put( "nextblockhash", block_link( block["nextblockhash"] ))
      |> Map.put( "hash", block_link( block["hash"] ))
      |> mark_up_transactions()
      |> Poison.encode!( pretty: true )
    else
      ""
    end
  end

  defp mark_transactions( list ) do
    case list do
      [ head | tail ] -> trans_link( head ) ++ mark_transactions( tail )
      _ -> []
    end
  end

  defp mark_up_transactions( block ) do
    list = block[ "tx" ]
    list = mark_transactions( list )
    Map.put( block, "tx", list )
  end

  def mark_up_hash( block ) do
    block_link( block[ "hash" ] )
  end

end
