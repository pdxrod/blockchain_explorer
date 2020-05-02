defmodule BlockChainExplorer.BitcoinUtils do

  def hex_list( str ) do
    if rem( String.length( str ), 2 ) != 0 do
      raise "Argument must be a string with an even number of characters for converting to a sequence of hex number"
    end
    str
    |> String.codepoints
    |> Enum.chunk(2)
    |> Enum.map(&Enum.join/1)
    |> Enum.map(&String.to_integer &1, 16)
  end

end
