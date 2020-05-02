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
    str
    |> String.codepoints
    |> Enum.chunk(2)
    |> Enum.map(&Enum.join/1)
  end


end
