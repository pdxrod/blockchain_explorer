defmodule BlockChainExplorer.Blockchain do

  def bitcoin_rpc(method, params \\ []) do
    with url <- Application.get_env(:blockchain_explorer, :bitcoin_url),
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

  def get_latest_block do
    case getbestblockhash() do
      {:ok, hash} -> getblock( hash )
      other -> other
    end
  end

  def get_next_or_previous_block( block, direction ) do
    which_way = cond do
      direction == :backward -> "previousblockhash"
      direction == :forward -> "nextblockhash"
      true -> raise "direction should be forward or backward, not #{ direction }"
    end
    hash = block[ which_way ]
    block = case getblock( hash ) do
      {:ok, map} ->
        map
      {:error, %{"code" => -1, "message" => "JSON value is not a string as expected"}} ->
        %{}
      other ->
        raise "Error calling RPC function getblock: #{ elem(other, 1)["message"] }"
    end
    block
  end

  def get_n_blocks( block, blocks, n, direction \\ :backward ) do
    if tuple_size( blocks ) < 1, do: blocks = {block}
    cond do
      n <= 1 ->
        blocks
      true ->
        new_block = get_next_or_previous_block( block, direction )
        if map_size( new_block ) > 0 do
          blocks = case direction do
            :backward -> Tuple.append( blocks, new_block )
            :forward -> Tuple.insert_at( blocks, 0, new_block )
            _ -> raise "direction should be forward or backward, not #{ direction }"
          end
          get_n_blocks( new_block, blocks, n - 1, direction )
        else
          blocks
        end
    end
  end

  defp get_next_or_previous_n_blocks_empty( block, blocks, n, direction ) do
    if n <= 1 do
      blocks
    else
      new_block = get_next_or_previous_block( block, direction )
      if map_size( new_block ) > 0 do
        blocks = case direction do
          :backward -> Tuple.append( blocks, new_block )
          :forward -> Tuple.insert_at( blocks, 0, new_block )
          _ -> raise "direction should be forward or backward, not #{ direction }"
        end
        get_next_or_previous_n_blocks_empty( new_block, blocks, n - 1, direction )
      else
        blocks
      end
    end
  end

  def get_next_or_previous_n_blocks( block, blocks, n, direction ) do
    size = tuple_size( blocks )
    if size == 0 do
      get_next_or_previous_n_blocks_empty( block, {}, n, direction )
    else
      num = if direction == :backward, do: size - 1, else: 0
      new_block = elem( blocks, num )
      get_next_or_previous_n_blocks_empty( new_block, {new_block}, n, direction )
    end
  end

end
