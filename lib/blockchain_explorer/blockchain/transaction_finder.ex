defmodule BlockChainExplorer.TransactionFinder do
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Transaction
  alias BlockChainExplorer.Utils

  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__ )
  end

  defp is_in_transaction_addresses?( transaction, addresses_str_list, address_str ) do
    if Utils.mt? addresses_str_list do
      false
    else
      [ hd | tl ] = addresses_str_list
      cond do
        String.starts_with?( hd, address_str ) ->
          IO.puts "\nis_in_transaction_addresses? transaction #{transaction["txid"]}, address #{hd}, str #{address_str} - FOUND"
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
    if is_in_transaction_outputs? transaction, transaction[ "vout"], address_str do
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
    trans = transactions_contain_address block_json[ "tx" ], address_str
    trans
  end

  defp find_blocks( address_str ) do
    Blockchain.get_n_blocks( nil, 100 )
    |> Tuple.to_list()
    |> Enum.map( &block_contains_address( &1, address_str ) )
    |> IO.inspect 
  end

  def find_transactions( address_str ) do
    task = Task.async( fn() -> find_blocks( address_str ) end)
  end

end
