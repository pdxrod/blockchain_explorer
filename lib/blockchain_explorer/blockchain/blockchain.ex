defmodule BlockChainExplorer.Blockchain do
  alias BlockChainExplorer.Utils

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
      other ->
        raise "Error calling RPC function getblock: #{ elem(other, 1)["message"] }"
    end
    block
  end

  def get_n_blocks( block, n, direction \\ "previousblockhash", blocks \\ {} ) do
    block = if block == nil, do: get_best_block(), else: block
    blocks = if tuple_size( blocks ) < 1, do: {block}, else: blocks
    cond do
      n <= 1 ->
        blocks
      true ->
        if direction != "previousblockhash" && direction != "nextblockhash", do: raise "direction should be previousblockhash or nextblockhash, not #{ direction }"
        new_block = get_next_or_previous_block( block, direction )
        if map_size( new_block ) > 0 do
          blocks = case direction do
            "previousblockhash" -> Tuple.append( blocks, new_block )
            "nextblockhash" -> Tuple.insert_at( blocks, 0, new_block )
          end
          get_n_blocks( new_block, n - 1, direction, blocks )
        else
          blocks
        end
    end
  end

  defp get_next_or_previous_n_blocks_empty( block, n, direction, blocks ) do
    block = if block == nil, do: get_best_block(), else: block
    blocks = if tuple_size( blocks ) < 1, do: {block}, else: blocks

    IO.write "\nget_next_or_previous_n_blocks_empty "
    IO.inspect block
    IO.write "#{n} #{direction} blocks is "
    IO.inspect blocks
    IO.puts "tuple_size blocks is #{tuple_size blocks}\n"

    if n <= 1 do

    IO.puts "returning blocks because n <= 1\n"

      blocks
    else
      if direction != "previousblockhash" && direction != "nextblockhash", do: raise "direction should be previousblockhash or nextblockhash, not #{ direction }"
      new_block = get_next_or_previous_block( block, direction )
      if map_size( new_block ) > 0 do
        blocks = case direction do
          "previousblockhash" -> Tuple.append( blocks, new_block )
          "nextblockhash" -> Tuple.insert_at( blocks, 0, new_block )
        end
        get_next_or_previous_n_blocks_empty( new_block, n - 1, direction, blocks )
      else
        blocks
      end
    end
  end

  def get_next_or_previous_n_blocks( block, n, direction \\ "previousblockhash", blocks \\ {} ) do
    size = tuple_size( blocks )
    if size == 0 do
      result = get_next_or_previous_n_blocks_empty( block, n, direction, blocks )

IO.puts "\nget_next_or_previous_n_blocks returning result of size #{tuple_size result}\n"

      result

    else
      num = if direction == "previousblockhash", do: size - 1, else: 0
      new_block = elem( blocks, num )
      get_next_or_previous_n_blocks_empty( new_block, n, direction, {new_block} )
    end
  end

end
