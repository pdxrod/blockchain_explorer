defmodule BlockChainExplorer.BitcoinUtils do

  def hex_list( str ) do
    str
    |> String.codepoints
    |> Enum.chunk(2)
    |> Enum.map(&Enum.join/1)
    |> Enum.map(&String.to_integer &1, 16)
  end

end
