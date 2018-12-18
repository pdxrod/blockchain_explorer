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

  def get_block_by_height( height ) do
    case getblockhash( height ) do
      {:ok, hash} -> getblock( hash )
      other -> other
    end
  end

  def get_next_or_previous_block( block, direction ) do
    hash = block[ direction ]
    block = case getblock( hash ) do
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

  defp map_to_string( map ) do
    String.slice(Enum.reduce(map, "", fn({k, v}, acc) -> "#{acc}#{k}=#{quotes_if_needed(v)}," end), 0..-2)
  end

# If it's in the database, return it. If it isn't, insert it and return it. height is unique in db.
  defp find_or_insert_block( block ) do
    height = block[ "height" ]
    result = Repo.all(
      from b in Block,
      select: b,
      where: b.height == ^height
    )
    if length( result ) == 0 do
#      IO.puts "Adding block to db\n"
      db_block = %Block{height: block[ "height" ], bits: block["bits"], block: map_to_string(block), chainwork: block["chainwork"],
                     confirmations: block["confirmations"], difficulty: block["difficulty"], hash: block["hash"],
                     mediantime: block["mediantime"], merkleroot: block["merkleroot"], nextblockhash: block["nextblockhash"],
                     nonce: block["nonce"], previousblockhash: block["previousblockhash"], size: block["size"], weight: block["weight"],
                     strippedsize: block["strippedsize"], time: block["time"], version: block["version"], versionhex: block["versionhex"]}
      Repo.insert db_block
      db_block
    else
      db_block = List.first( result )
#      IO.puts "Found height, id #{ db_block.height } #{ db_block.id }"
#      IO.puts "Not adding block to db\n"
      db_block
    end
  end

  def get_n_blocks( block, n, direction \\ "previousblockhash", blocks \\ [] ) do
    block = if block == nil, do: get_best_block(), else: block

    db_block = find_or_insert_block( block )

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
