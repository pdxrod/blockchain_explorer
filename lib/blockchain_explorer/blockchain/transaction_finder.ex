defmodule BlockChainExplorer.TransactionFinder do
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Transaction
  alias BlockChainExplorer.Utils

  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__ )
  end

  defp is_in_transaction_addresses?( addresses_str_list, address_str ) do

#IO.puts "\nis_in_transaction_addresses?"

    if Utils.mt? addresses_str_list do
      false
    else
      [ hd | tl ] = addresses_str_list

#IO.puts "address #{hd}, str #{address_str}"

      cond do
        String.starts_with?( hd, address_str ) -> true
        true -> is_in_transaction_addresses?( tl, address_str )
      end
    end
  end

  defp is_in_transaction_outputs?( transaction_outputs, address_str ) do
    if Utils.mt? transaction_outputs do
      false
    else
      [ hd | tl ] = transaction_outputs
      cond do
        hd[ "scriptPubKey" ] && hd[ "scriptPubKey" ][ "addresses" ] && is_in_transaction_addresses?( hd[ "scriptPubKey" ][ "addresses" ], address_str ) -> true
        true -> is_in_transaction_outputs?( tl, address_str )
      end
    end
  end

  defp transaction_containing_address( transaction_address_str, address_str ) do
    transaction_tuple = Transaction.get_transaction_tuple transaction_address_str
    transaction = elem transaction_tuple, 1
    if is_in_transaction_outputs? transaction[ "vout" ], address_str do
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
        transaction -> transaction
        true -> transactions_contain_address( tl, address_str )
      end
    end
  end

  defp block_contains_address( block_json, address_str ) do
    transactions_contain_address block_json[ "tx" ], address_str
  end

  def find_transactions( address_str ) do
    Blockchain.stream_n_blocks( nil, 1_000_000 ) |> Stream.map( &block_contains_address( &1, address_str ) )
  end

end
