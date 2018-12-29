defmodule BlockChainExplorerWeb.BlockController do
  use BlockChainExplorerWeb, :controller
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Rpc
  alias BlockChainExplorer.Block
  alias BlockChainExplorer.HashStack
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Transaction

  defp show_error( conn, page, error ) do
    message = case error[:error] do
      "0" ->
        "invalid request"
      "econnrefused" ->
        "connection refused"
      "Loading block index..." ->
        "bitcoind starting"
      "JSON integer out of range" ->
        "no such block"
      "Block height out of range" ->
        "no such block"
      _ ->
        error[:error]
    end
    render( conn, page, error: message )
  end

  defp latest?( block ) do
    block.nextblockhash == nil
  end

  defp render_index_page( conn, blocks, latest ) do
    decoded = Enum.map( blocks, &Block.convert_to_struct( &1 ) )
    render( conn, "index.html", blocks: decoded, latest: latest )
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
          render_index_page( conn, blocks, false )
        else
          render_index_page( conn, blocks, latest?( block ))
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
        latest = List.first blocks
        render_index_page( conn, blocks, latest?( latest ))

      _ -> raise "This should never happen - direction is #{ direction }"
    end
  end

  defp show_block_by_height( conn, height ) do
    block = Blockchain.get_from_db_or_bitcoind_by_height height
    render(conn, "show.html", block: block, address_str: "n4ME4" )
  end

  defp show_block_by_hash( conn, hash ) do
    block = Blockchain.get_from_db_or_bitcoind_by_hash hash
    render(conn, "show.html", block: block, address_str: "n4ME4" )
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
            addresses = Transaction.get_addresses a_transaction.id
            address = List.first addresses
            address_str = address.address
            address_str = String.slice address_str, 0..4
            decoded = Blockchain.get_highest_block_from_db_or_bitcoind()
            render( conn, "show.html", block: decoded, address_str: address_str )
        end
    end
  end
end
