defmodule BlockChainExplorer.TransactionFinder do
  alias BlockChainExplorer.Blockchain

  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__ )
  end

  defp is_in_transaction_addresses?( addresses_str_list, address_str ) do
    if addresses_str_list == [] do
      false
    else
      [ hd | tl ] = addresses_str_list
      cond do
        String.starts_with?( hd, address_str ) -> true
        true -> is_in_transaction_addresses?( tl, address_str )
      end
    end
  end

  defp is_in_transaction?( transaction_json, address_str ) do
    is_in_transaction_addresses? transaction_json[ "addresses" ], address_str
  end

  defp is_in_transactions?( transactions_json, address_str ) do
    if transactions_json == [] do
      false
    else
      [ hd | tl ] = transactions_json
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
    blocks = Blockchain.get_n_blocks nil, 100
    Stream.map( blocks, &is_in_block?( &1, address_str )/2 )
  end

end
