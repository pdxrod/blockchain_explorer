defmodule BlockChainExplorer.Blockchain do
  alias BlockChainExplorer.Block
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Repo
  import Ecto.Query

  def bitcoin_rpc(method, params \\ []) do
    with url <- Utils.env( :bitcoin_url),
         command <- %{jsonrpc: "1.0", method: method, params: params},
         {:ok, body} <- Poison.encode(command),
         {:ok, response} <- HTTPoison.post(url, body),
         {:ok, metadata} <- Poison.decode(response.body),
         %{"error" => nil, "result" => result} <- metadata do
      {:ok, result}
    else
      %{"error" => reason} -> {:error, reason}
      error -> error
    end
  end

  def getbestblockhash, do: bitcoin_rpc("getbestblockhash")
  def getblockhash(height), do: bitcoin_rpc("getblockhash", [height])
  def getblock(hash), do: bitcoin_rpc("getblock", [hash])
  def getblockheader(hash), do: bitcoin_rpc("getblockheader", [hash])
  def getrawtransaction( trans ), do: bitcoin_rpc( "getrawtransaction", [trans] )
  def decoderawtransaction( hex ), do: bitcoin_rpc( "decoderawtransaction", [hex] )
  def sendtoaddress(address, amount), do: bitcoin_rpc( "sendtoaddress", [address, amount] )
  def getmininginfo, do: bitcoin_rpc("getmininginfo")

  def get_best_block do
    getbestblockhash()
    |> elem( 1 )
    |> getblock()
    |> elem( 1 )
  end

  def get_block( hash ) do
    result = Repo.all(
      from b in Block,
      select: b,
      where: b.hash == ^hash
    )
    if length( result ) == 0 do
      result = getblock( hash )
      block_map = elem( result, 1 )
      block = Block.decode_block block_map
      Repo.insert block
      block
    else
      List.first( result )
    end
  end

  def get_block_by_height( height ) do
    result = Repo.all(
      from b in Block,
      select: b,
      where: b.height == ^height
    )
    if length( result ) == 0 do
      case getblockhash( height ) do
        {:ok, hash} -> get_block( hash )
        other -> other
      end
    else
      List.first( result )
    end
  end

  def get_next_or_previous_block( block, direction ) do
    hash = block[ direction ]
    block = case get_block( hash ) do
      %{} ->
        block
      {:ok, map} ->
        map
      {:error, %{"code" => -1, "message" => "JSON value is not a string as expected"}} ->
        %{}
      {:error, %{id: nil, reason: :timeout}} ->
        %{}
      other ->
        raise IO.inspect( other )
    end
    block
  end

  defp quotes_if_needed( value ) do
    cond do
      Utils.typeof( value ) == "binary" -> "\"#{value}\""
      true -> value
    end
  end

  defp map_to_string( map ) do # It should be obvious what this does
    String.slice(Enum.reduce(map, "", fn({k, v}, acc) -> "#{acc}#{k}=#{quotes_if_needed(v)}," end), 0..-2)
  end

  def get_n_blocks( block, n, direction \\ "previousblockhash", blocks \\ [] ) do
    block = if block == nil, do: get_best_block(), else: block
    blocks = if length( blocks ) < 1, do: [ block ], else: blocks
    cond do
      n <= 1 ->
        blocks
      true ->
        if direction != "previousblockhash" && direction != "nextblockhash", do: raise "direction should be previousblockhash or nextblockhash, not #{ direction }"
        new_block = get_next_or_previous_block( block, direction )
        if map_size( new_block ) > 0 do
          blocks = case direction do
            "previousblockhash" -> blocks ++ [ new_block ]
            "nextblockhash"     -> [ new_block ] ++ blocks
          end
          get_n_blocks( new_block, n - 1, direction, blocks )
        else
          blocks
        end
    end
  end

  defp get_next_or_previous_n_blocks_empty( block, n, direction, blocks ) do
    block = if block == nil, do: get_best_block(), else: block
    blocks = if length( blocks ) < 1, do: [ block ], else: blocks
    if n <= 1 do
      blocks
    else
      if direction != "previousblockhash" && direction != "nextblockhash", do: raise "direction should be previousblockhash or nextblockhash, not #{ direction }"
      new_block = get_next_or_previous_block( block, direction )
      if map_size( new_block ) > 0 do
        blocks = case direction do
          "previousblockhash" -> blocks ++ [ new_block ]
          "nextblockhash"     -> [ new_block ] ++ blocks
        end
        get_next_or_previous_n_blocks_empty( new_block, n - 1, direction, blocks )
      else
        blocks
      end
    end
  end

  def get_next_or_previous_n_blocks( block, n, direction \\ "previousblockhash", blocks \\ [] ) do
    size = length( blocks )
    if size == 0 do
      get_next_or_previous_n_blocks_empty( block, n, direction, blocks )
    else
      num = if direction == "previousblockhash", do: size - 1, else: 0
      new_block = Enum.at( blocks, num )
      get_next_or_previous_n_blocks_empty( new_block, n, direction, [new_block] )
    end
  end

end
