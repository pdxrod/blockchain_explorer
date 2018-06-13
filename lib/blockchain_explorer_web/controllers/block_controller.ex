defmodule BlockChainExplorerWeb.BlockController do
  use BlockChainExplorerWeb, :controller
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Block
  alias BlockChainExplorer.HashStack

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
      _ -> render(conn, page, error: "unknown error")
    end
  end

  defp latest?( block ) do
    newer_blocks = Blockchain.get_n_blocks( block, 2, :forward )
    tuple_size( newer_blocks ) < 2 # If you can't get 2 blocks, you're at the top of the blockchain
  end

  defp show_list_page( conn, hash, more \\ false ) do
    case Blockchain.getblock( hash ) do
      {:ok, block} ->
        HashStack.push block
        blocks = Blockchain.get_n_blocks( block, 50, :backward )
        if more do
          block = elem( blocks, 49 )
          HashStack.push block
          blocks = Blockchain.get_n_blocks( block, 50, :backward )
          render( conn, "list.html", blocks: blocks, latest: false )
        else
          render( conn, "list.html", blocks: blocks, latest: latest?( block ) )
        end

      other ->
        show_error(conn, "list.html", other)
    end
  end

  defp show_n_hashes( conn, direction ) do
    cond do
      direction == :latest ->
        result = Blockchain.getbestblockhash()
        ok = elem( result, 0 )
        cond do
          ok == :ok ->
            show_list_page( conn, elem( result, 1 ))
          true ->
            show_error( conn, "list.html", result )
        end

      direction == :backward ->
        block = HashStack.pop()
        if latest?( block ) do
          case Blockchain.getbestblockhash() do
            {:ok, hash} ->
              show_list_page( conn, hash, true )
            other ->
              show_error( conn, "list.html", other )
          end
        else
          hash = block[ "hash" ]
          show_list_page( conn, hash, true )
        end

      direction == :forward ->
        block = HashStack.pop()
        blocks = Blockchain.get_n_blocks( block, 50, :forward )
        latest = elem( blocks, 0 )
        render( conn, "list.html", blocks: blocks, latest: latest?( latest ))

      true -> raise "This should never happen - direction is #{ direction }"
    end
  end

  def list(conn, params) do
    last = HashStack.peek()
    direction = cond do # See list.html.eex for where params comes from
      params[ "n" ] == "t" -> :backward
      last == nil -> :latest
      params[ "p" ] == nil -> :backward
      true -> :forward
    end
    conn = assign( conn, :error, "" )
    show_n_hashes( conn, direction )
  end

  defp get_height_from_params( params ) do
    try do
      num_param = params[ "blocks" ][ "num" ]
      String.to_integer( num_param )
    rescue
      e in ArgumentError -> e # If there is no parameter, or if user entered an invalid number
      nil
    end
  end

  defp show_block_by_height( conn, height ) do
    tuple = Blockchain.get_block_by_height height
    block = elem( tuple, 1 )
    decoded = Block.decode_block( block )
    render( conn, "index.html", blocks: [decoded] )
  end

  defp show_n_blocks( conn, block ) do
    blocks = Tuple.to_list Blockchain.get_n_blocks( block, 10, :backward )
    decoded = Enum.map( blocks, fn( block ) -> Block.decode_block( block ) end)
    render( conn, "index.html", blocks: decoded )
  end

  def index(conn, params) do
    height = get_height_from_params( params )
    conn = assign(conn, :error, "")
    conn = assign(conn, :blocks, {%{}})

    case Blockchain.get_latest_block() do
      {:ok, block} ->
        case height do
          nil -> show_n_blocks conn, block
          other -> show_block_by_height conn, other
        end
      other ->
        show_error(conn, "index.html", other)
    end
  end

  def show(conn, %{"id" => hash}) do
    conn = assign(conn, :error, "")
    conn = assign(conn, :block, %{})
    case Blockchain.getblock(hash) do
      {:ok, block} ->
        decoded = Block.decode_block block
        render(conn, "show.html", block: decoded)

      other ->
        show_error(conn, "show.html", other)
    end
  end
end
