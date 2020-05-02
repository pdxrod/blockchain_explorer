defmodule BlockChainExplorer.BitcoinUtils do

  defp combine_chunk( chunk ) do
    Enum.at( chunk, 0 ) <> Enum.at( chunk, 1 )
  end

  defp combine_chunks( list_of_lists ) do
    case list_of_lists do
      [] -> []
      [ hd | tl ] -> combine_chunk( hd ) ++ combine_chunks( tl )
    end
  end

  def make_hex_list( str ) do
    chars = String.split str, ''
    list_of_lists = Enum.chunk_every( chars, 2 )
    num_list = combine_chunks( list_of_lists )
    num_list
  end


end
