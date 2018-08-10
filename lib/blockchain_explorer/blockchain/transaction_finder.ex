defmodule BlockChainExplorer.TransactionFinder do
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Transaction
  alias BlockChainExplorer.Utils

  def start_link do
    Agent.start_link(fn -> %{ } end, name: __MODULE__ )
  end

  defp transaction?( thing ) do
    try do
      thing["vsize"] && thing["outputs"] && thing["inputs"]
      true
    rescue f in FunctionClauseError -> f
      false
    end
  end

  def put( address_str, transaction ) do
    if ! transaction?( transaction ), do: raise "TransactionFinder only accepts transactions"
    tuple = peek( address_str )
    tuple = if tuple == nil, do: {}, else: tuple
    tuple = Tuple.append( tuple, transaction )
    Agent.update(__MODULE__, &Map.put( &1, address_str, tuple ))
  end

  defp is_in_transaction_addresses?( transaction, addresses_str_list, address_str ) do
    if Utils.mt? addresses_str_list do
      false
    else
      [ hd | tl ] = addresses_str_list
# IO.puts "\ntransaction_finder looking at address str #{address_str}, address #{hd}"
      cond do
        String.starts_with?( hd, address_str ) ->
          put address_str, transaction
IO.puts "\ntransaction_finder address str #{address_str}, address #{hd}, tx found #{String.slice( transaction["txid"], 0..10) <> "..."}"
          true
        true -> is_in_transaction_addresses?( transaction, tl, address_str )
      end
    end
  end

  defp is_in_transaction_outputs?( transaction, outputs, address_str ) do
    if Utils.mt? outputs do
      false
    else
      [ hd | tl ] = outputs
      cond do
        hd[ "scriptPubKey" ] && hd[ "scriptPubKey" ][ "addresses" ] && is_in_transaction_addresses?( transaction, hd[ "scriptPubKey" ][ "addresses" ], address_str ) -> true
        true -> is_in_transaction_outputs?( transaction, tl, address_str )
      end
    end
  end

  defp transaction_containing_address( transaction_address_str, address_str ) do
    transaction_tuple = Transaction.get_transaction_tuple transaction_address_str
    transaction = elem transaction_tuple, 1
    if transaction?( transaction ) && is_in_transaction_outputs? transaction, transaction["vout"], address_str do
      transaction
    else
      nil
    end
  end

  defp transactions_contain_address( transactions_addresses, address_str ) do
    if Utils.mt? transactions_addresses do
      nil
    else
      [ hd | tl ] = transactions_addresses
      transaction = transaction_containing_address( hd, address_str )
      cond do
        transaction != nil -> transaction
        true -> transactions_contain_address( tl, address_str )
      end
    end
  end

  defp block_contains_address( block_json, address_str ) do
    transactions_contain_address block_json[ "tx" ], address_str
  end

  defp debug do
    Agent.get(__MODULE__, fn( map ) -> show_map( map ) end)
  end

  defp show_map( map ) do
    if Utils.mt? Map.keys( map ) do
      IO.puts "                        []"
    else
      for key <- Map.keys( map ) do
        IO.write "                        #{ key } => "
        transactions_tuple = Map.get( map, key )
        transactions_list = Tuple.to_list transactions_tuple
        for transaction <- transactions_list do
          IO.write " #{ String.slice( transaction[ "txid" ], 0..5 ) <> "...-> " } "
          if Utils.notmt?( transaction["vout"] ) do
            for output <- transaction["vout"] do
              if Utils.notmt?( output["scriptPubKey"] ) && Utils.notmt?( output["scriptPubKey"]["addresses"] ) do
                for address <- output["scriptPubKey"]["addresses"] do
                  IO.write String.slice( address, 0..7 ) <> "... "
                end
              end
            end
          else
            IO.write "no addresses"
          end
        end
        IO.puts ""
      end
    end
  end

  @num_blocks 100
  @find_wait (@num_blocks * 50)
  @peek_wait (@num_blocks * 20)

  defp find_blocks( address_str ) do
    Blockchain.get_n_blocks( nil, @num_blocks )
    |> Tuple.to_list()
    |> Enum.map( &block_contains_address( &1, address_str ) )
  end

  def find_transactions( address_str ) do
    task = Task.async( fn() -> find_blocks( address_str ) end)
    try do
      Task.await task, @find_wait
    catch :exit, _ -> IO.puts "\nExit find_transactions"
    end
  end

  def peek( address_str ) do
    task = Task.async( fn() -> Agent.get(__MODULE__, &Map.get( &1, address_str )) end)
    result = Task.await task, @peek_wait
    result = if Utils.mt?( result ), do: { }, else: result
    debug()
    result
  end

end
