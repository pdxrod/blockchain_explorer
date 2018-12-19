defmodule BlockChainExplorer.Blockchain do
  alias BlockChainExplorer.Block
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Repo
  alias BlockChainExplorer.Rpc
  import Ecto.Query

  def get_best_block do
    Rpc.getbestblockhash()
    |> elem( 1 )
    |> get_block_by_hash()
  end

  def get_block_by_hash( hash ) do
    result = Repo.all(
      from b in Block,
      select: b,
      where: b.hash == ^hash
    )
    if length( result ) == 0 do
      result = Rpc.getblock( hash )
      block_map = elem( result, 1 )

      block = Block.decode_block block_map
      case block do
        %{"code" => -5, "message" => "Block not found"} ->
          %{}
        %BlockChainExplorer.Block{ block: %{"code" => -5, "message" => "Block not found"} } ->
          %{}
        %{} ->
          %{}
        _ ->
          Repo.insert block
          block
      end
    else
      Block.decode_block List.first( result )
    end
  end

  def get_block_by_height( height ) do
    result = Repo.all(
      from b in Block,
      select: b,
      where: b.height == ^height
    )
    if length( result ) == 0 do
      Rpc.getblockhash( height )
      |> get_block_by_hash()
    else
      List.first( result )
    end
  end

  def get_next_or_previous_block( block, direction ) do
    if block == %{} do
      block
    else
      hash = case direction do
        "previousblockhash" -> block.previousblockhash
        "nextblockhash"     -> block.nextblockhash
        other -> raise "get_next_or_previous_block second argument is '#{other}' - it should be previousblockhash or nextblockhash"
      end
      case hash do
        nil -> block
        _ -> get_block_by_hash( hash )
      end
    end
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
