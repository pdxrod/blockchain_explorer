defmodule BlockChainExplorer.TransactionFinder do
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Transaction
  alias BlockChainExplorer.Utils

  def start_link do
    Agent.start_link(fn -> %{ } end, name: __MODULE__ )
  end

  def put( address_str, transaction ) do
    converted = Transaction.convert_to_struct transaction
    tuple = peek( address_str )
    tuple = if tuple == nil, do: {}, else: tuple
    if ! Utils.is_in_tuple?( tuple, converted ) do
      tuple = Tuple.append( tuple, converted )
      Agent.update(__MODULE__, &Map.put( &1, address_str, tuple ))
    end
  end

  @num_blocks 100
  @find_wait (@num_blocks * 20)
  @peek_wait (@num_blocks * 8)

  defp find_blocks( address_str ) do
    blocks = Blockchain.get_n_blocks( nil, @num_blocks )
    if length( blocks ) > 0 do
      block = List.first blocks
      case block do
        %{error: _} -> nil
        _ ->
          for block <- blocks do
            transactions = Transaction.get_transactions_with_block_id block.id
            for transaction <- transactions do
              addresses = Transaction.get_addresses transaction.id
              for address <- addresses do
                if String.starts_with?( address.address, address_str ) do
                  put address_str, transaction
                end
              end
            end
          end
      end
    end
  end

  def find_transactions( address_str ) do
    task = Task.async( fn() -> find_blocks( address_str ) end)
    try do
      Task.await task, @find_wait
    catch :exit, _ -> IO.puts ""
    end
  end

  def peek( address_str ) do
    task = Task.async( fn() -> Agent.get(__MODULE__, &Map.get( &1, address_str )) end)
    result = Task.await task, @peek_wait
    result = if Utils.mt?( result ), do: { }, else: result
    result
  end

end
