defmodule BlockChainExplorer.BitcoinUtils do
  alias BlockChainExplorer.Utils

  def hex_list( str ) do
    if String.length( str ) == 0 do
      []
    else
      if rem( String.length( str ), 2 ) != 0 do
        raise "Argument must be a string with an even number of characters for converting to a sequence of hex numbers"
      end
      unless str =~ Utils.env :base_16_regex do
        raise "#{str} is not a valid hex string"
      end
      str
        |> String.codepoints
        |> Enum.chunk(2)
        |> Enum.map(&Enum.join/1)
        |> Enum.map(&String.to_integer &1, 16)
    end
  end

end
