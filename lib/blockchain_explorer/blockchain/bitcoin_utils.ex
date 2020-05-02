defmodule BlockChainExplorer.BitcoinUtils do

  def make_hex_list( str ) do
    str
    |> String.codepoints
    |> Enum.chunk(2)
    |> Enum.map(&Enum.join/1)
  end


end
