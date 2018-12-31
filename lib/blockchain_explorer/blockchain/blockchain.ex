defmodule BlockChainExplorer.Blockchain do
  alias BlockChainExplorer.Block
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Db
  alias BlockChainExplorer.Rpc
  import Ecto.Query

  def get_highest_block_from_db_or_bitcoind do
    tuple = Rpc.getbestblockhash()
    if elem( tuple, 0 ) == :ok do
      get_from_db_or_bitcoind_by_hash( elem( tuple, 1 ))
    else
      Utils.error tuple
    end
  end

  def get_from_db_or_bitcoind_by_hash( hash ) do
    result = Db.all(
      from b in Block,
      select: b,
      where: b.hash == ^hash
    )
    if length( result ) == 0 do
      result = Rpc.getblock( hash )
      if elem( result, 0 ) == :ok do
        block_map = elem( result, 1 )
        insertable_block = Block.convert_to_struct block_map
        tuple = Db.insert insertable_block
        Db.get_db_result_from_tuple tuple
      else
        Utils.error result
      end
    else
      List.first( result )
    end
  end

  def get_from_db_or_bitcoind_by_height( height ) do
    result = Db.all(
      from b in Block,
      select: b,
      where: b.height == ^height
    )
    if length( result ) == 0 do
      hash = Rpc.getblockhash( height )
      result = Rpc.getblock( hash )
      block_map = elem( result, 1 )
      insertable_block = Block.convert_to_struct block_map
      case insertable_block do
        %{error: _} -> insertable_block
        %{invalid: _} -> insertable_block
        _ ->
          result = Db.insert insertable_block
          Db.get_db_result_from_tuple result
      end    
    else
      List.first( result )
    end
  end

  def get_next_or_previous_block( block, direction ) do
    case block do
      %{error: _} -> block
      _ ->
        hash = case direction do
          "previousblockhash" -> block.previousblockhash
          "nextblockhash"     -> block.nextblockhash
          other -> raise "get_next_or_previous_block second argument is '#{other}' - it should be previousblockhash or nextblockhash"
        end
        case hash do
          nil -> block
          _ -> get_from_db_or_bitcoind_by_hash( hash )
        end
    end
  end

  def get_n_blocks( block, n, direction \\ "previousblockhash", blocks \\ [] ) do
    block = if block == nil, do: get_highest_block_from_db_or_bitcoind(), else: block
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
    block = if block == nil, do: get_highest_block_from_db_or_bitcoind(), else: block
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
