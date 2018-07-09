defmodule BlockChainExplorerWeb.BlockController do
  use BlockChainExplorerWeb, :controller
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Block
  alias BlockChainExplorer.HashStack
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Transaction
  alias BlockChainExplorer.TransactionFinder

  defp show_error( conn, page, error ) do
    case error do
      {:error, :invalid, 0} ->
        render(conn, page, error: "invalid request")
      {:error, %HTTPoison.Error{id: nil, reason: :timeout}} ->
        render(conn, page, error: "timeout")
      {:error, %HTTPoison.Error{id: nil, reason: :econnrefused}} ->
        render(conn, page, error: "connection refused")
      {:error, %{"code" => -28, "message" => "Loading block index..."}} ->
        render(conn, page, error: "bitcoind starting")
      {:error, %{"code" => -5, "message" => "Block not found"}} ->
        render(conn, page, error: "block not found")
      {:error, %{"code" => -1, "message" => "JSON integer out of range"}} ->
        render(conn, page, error: "no such block")
      {:error, %{"code" => -8, "message" => "Block height out of range"}} ->
        render(conn, page, error: "no such block")
      %{} ->
        render(conn, page, error: "no such block")
      _ ->
        render(conn, page, error: "unknown error")
    end
  end

  defp latest?( block ) do
    block[ "nextblockhash" ] == nil
  end

  defp render_index_page( conn, blocks, latest ) do
    render( conn, "index.html", blocks: blocks, latest: latest )
  end

  defp show_index_page( conn, hash, more \\ false ) do
    case Blockchain.getblock( hash ) do
      {:ok, block} ->
        HashStack.push block
        blocks = Blockchain.get_n_blocks( block, 50, "previousblockhash" )
        if more do
          block = elem( blocks, 49 )
          HashStack.push block
          blocks = Blockchain.get_n_blocks( block, 50, "previousblockhash" )
          render_index_page( conn, blocks, false )
        else
          render_index_page( conn, blocks, latest?( block ))
        end

      other ->
        show_error(conn, "index.html", other)
    end
  end

  defp show_n_hashes( conn, direction ) do
    case direction do
      "latestblockhash" ->
        result = Blockchain.getbestblockhash()
        ok = elem( result, 0 )
        cond do
          ok == :ok ->
            show_index_page( conn, elem( result, 1 ))
          true ->
            show_error( conn, "index.html", result )
        end

      "previousblockhash" ->
        block = HashStack.pop()
        if latest?( block ) do
          case Blockchain.getbestblockhash() do
            {:ok, hash} ->
              show_index_page( conn, hash, true )
            other ->
              show_error( conn, "index.html", other )
          end
        else
          hash = block[ "hash" ]
          show_index_page( conn, hash, true )
        end

      "nextblockhash" ->
        block = HashStack.pop()
        blocks = Blockchain.get_n_blocks( block, 50, "nextblockhash" )
        latest = elem( blocks, 0 )
        render_index_page( conn, blocks, latest?( latest ))

      _ -> raise "This should never happen - direction is #{ direction }"
    end
  end

  defp show_block_by_height( conn, height ) do
    tuple = Blockchain.get_block_by_height height

    case tuple do
      {:ok, block} ->
        decoded = Block.decode_block block
        render(conn, "show.html", block: decoded)

      other ->
        show_error(conn, "show.html", other)
    end
  end

  defp show_block_by_hash( conn, hash ) do
    tuple = Blockchain.getblock hash

    case tuple do
      {:ok, block} ->
        decoded = Block.decode_block block
        render(conn, "show.html", block: decoded)

      other ->
        show_error(conn, "show.html", other)
    end
  end

  defp analyse_params( params ) do
    user_input = params[ "blocks" ][ "num" ]
    user_input = if user_input == nil, do: "", else: user_input
    params_id = params[ "id" ]
    cond do
      user_input =~ Utils.env( :base_10_integer_regex ) -> {:height, String.to_integer( user_input )}
      user_input =~ Utils.env( :base_58_partial_regex ) -> {:adr, user_input}
      params_id != nil -> {:hash, params_id}
      true -> {"latestblockhash", nil}
    end
  end

  defp find_transactions_in_background( conn, address_str ) do
    task = TransactionFinder.find_transactions address_str
    try do
      Task.await task, 5000
    catch :exit, _ -> IO.puts "\nExit find"
    end
    redirect( conn, to: "/transactions/#{ address_str }" )
  end

  def index(conn, params) do
    direction = cond do # See index.html.eex for where params comes from
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
        decoded = Blockchain.get_best_block() |> Block.decode_block
        render( conn, "show.html", block: decoded )
    end
  end
end
