defmodule BlockChainExplorerWeb.BlockController do
  use BlockChainExplorerWeb, :controller
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Rpc
  alias BlockChainExplorer.Block
  alias BlockChainExplorer.HashStack
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Transaction

  defp show_error( conn, page, error ) do
    render( conn, page, error: error[:error]  )
  end

  defp latest?( block ) do
    block.nextblockhash == nil
  end

  defp last?( block ) do
    block.height == 0
  end

  defp render_index_page( conn, blocks, latest, last ) do
    decoded = Enum.map( blocks, &Block.convert_to_struct( &1 ) )
    render( conn, "index.html", blocks: decoded, latest: latest, last: last )
  end

  defp show_index_page( conn, hash, more \\ false ) do
    block = Blockchain.get_from_db_or_bitcoind_by_hash( hash )
    case block do
      %{error: _} ->
        show_error( conn, "index.html", block )
      _ ->
        HashStack.push block
        blocks = Blockchain.get_n_blocks( block, 50, "previousblockhash" )
        if more do
          block = List.last blocks
          HashStack.push block
          blocks = Blockchain.get_n_blocks( block, 50, "previousblockhash" )
          render_index_page( conn, blocks, false, last?( block ))
        else
          render_index_page( conn, blocks, latest?( block ), last?( block ))
        end
    end
  end

  defp show_n_hashes( conn, direction ) do
    case direction do
      "latestblockhash" ->
        result = Rpc.getbestblockhash()
        ok = elem( result, 0 )
        cond do
          ok == :ok ->
            show_index_page( conn, elem( result, 1 ))
          true ->
            error = Utils.error result
            show_error( conn, "index.html", error )
        end

      "previousblockhash" ->
        block = HashStack.pop()
        if latest?( block ) do
          case Rpc.getbestblockhash() do
            {:ok, hash} ->
              show_index_page( conn, hash, true )
            other ->
              error = Utils.error other
              show_error( conn, "index.html", error )
          end
        else
          hash = block.hash
          show_index_page( conn, hash, true )
        end

      "nextblockhash" ->
        block = HashStack.pop()
        blocks = Blockchain.get_n_blocks( block, 50, "nextblockhash" )
        latest = latest?( List.first blocks )
        last = last?( List.last blocks )
        render_index_page( conn, blocks, latest, last)

      _ -> raise "This should never happen - direction is #{ direction }"
    end
  end

  defp show_block_by_height( conn, height ) do
    block = Blockchain.get_from_db_or_bitcoind_by_height height
    address_strs = Blockchain.get_address_strs()
    first = List.first address_strs
    last  = List.last  address_strs
    case block do
      %{error: _} ->
        show_error conn, "show.html", block
      _ ->
        render(conn, "show.html", block: block, address_str: last, other_address_str: first )
    end
  end

  defp show_block_by_hash( conn, hash ) do
    block = Blockchain.get_from_db_or_bitcoind_by_hash hash
    address_strs = Blockchain.get_address_strs()
    first = List.first address_strs
    last  = List.last  address_strs
    case block do
      %{error: _} ->
        show_error conn, "show.html", block
      _ ->
        render(conn, "show.html", block: block, address_str: last, other_address_str: first )
    end
  end

  defp analyse_params( params ) do
    user_input = params[ "blocks" ][ "num" ]
    user_input = if user_input == nil, do: "", else: String.trim( user_input )
    params_id = params[ "id" ]
    cond do
      user_input =~ Utils.env( :base_10_integer_regex ) -> {:height, String.to_integer( user_input )}
      user_input =~ Utils.env( :base_58_partial_regex ) -> {:adr, user_input}
      params_id != nil -> {:hash, params_id}
      true -> {"latestblockhash", nil}
    end
  end

  defp find_transactions_in_background( conn, address_str ) do
    redirect( conn, to: "/transactions/#{ address_str }" )
  end

  def index(conn, params) do
    direction = cond do # See index.html.haml for where params comes from
      params == %{} -> "latestblockhash"
      params[ "n" ] == "t" -> "previousblockhash"
      true -> "nextblockhash"
    end
    conn = assign( conn, :error, "" )
    show_n_hashes( conn, direction )
  end

# Hope this is clear - the point is to do everything you can to find two different addresses to show on the /blocks page
  defp find_a_different_address( address_str, list ) do
    case list do
      [] -> address_str
      [ hd | tl ] ->
        case hd do
          address_str -> find_a_different_address( address_str, tl )
          _ -> hd
        end
    end
  end

  defp get_2_address_strs( transaction_id ) do
    addresses = Transaction.get_addresses transaction_id
    first = String.slice( List.first( addresses ).address, 0..Utils.env :truncated_address_str_len )
    last = String.slice(  List.last(  addresses ).address, 0..Utils.env :truncated_address_str_len )
    address_strs = [first, last] ++ Blockchain.get_address_strs
    first = List.first address_strs
    last = find_a_different_address( first, address_strs )
    [last, first]
  end

  def show( conn, params ) do
    status = analyse_params params
    conn = assign(conn, :error, "")
    conn = assign(conn, :block, %{})
    conn = assign(conn, :transactions, {})
    case elem( status, 0 ) do
      :height ->
        show_block_by_height( conn, elem( status, 1 ) )
      :hash ->
        show_block_by_hash( conn, elem( status, 1 ) )
      :adr ->
        find_transactions_in_background( conn, elem( status, 1 ) )
      _ ->
        a_transaction = Transaction.seed_db_and_get_a_useful_transaction()
        case a_transaction do
          %{error: _} -> show_error conn, "show.html", a_transaction
          _ ->
            address_strs = get_2_address_strs a_transaction.id
            first = List.first address_strs
            last  = List.last  address_strs
            decoded = Blockchain.get_highest_block_from_db_or_bitcoind()
            render( conn, "show.html", block: decoded, address_str: last, other_address_str: first )
        end
    end
  end
end
