defmodule BlockChainExplorer.TransactionFinder do
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Transaction
  alias BlockChainExplorer.Utils

  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__ )
  end

  defp is_in_transaction_addresses?( addresses_str_list, address_str ) do
    if Utils.mt? addresses_str_list do
      false
    else
      [ hd | tl ] = addresses_str_list
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

  defp is_in_transaction?( transaction_address_str, address_str ) do
    transaction_tuple = Transaction.get_transaction_tuple transaction_address_str
    transaction = elem transaction_tuple, 1
    is_in_transaction_outputs? transaction[ "vout" ], address_str
  end

  defp is_in_transactions?( transactions_addresses, address_str ) do
    if Utils.mt? transactions_addresses do
      false
    else
      [ hd | tl ] = transactions_addresses
      cond do
        is_in_transaction?( hd, address_str ) -> true
        true -> is_in_transactions?( tl, address_str )
      end
    end
  end

  defp is_in_block?( block_json, address_str ) do
    is_in_transactions? block_json[ "tx" ], address_str
  end

  def find_transactions( address_str ) do
    tuple = Blockchain.get_n_blocks nil, 100
    list = Tuple.to_list tuple
    # Stream.map
    Enum.map( list, &is_in_block?( &1, address_str ) )
    #    block = List.first list
    #    is_in_block? block, address_str
  end

end
