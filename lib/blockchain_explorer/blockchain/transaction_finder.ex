defmodule BlockChainExplorer.TransactionFinder do
  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__ )
  end

  def find_transactions( address_str ) do


  end

  def is_in_block?( block_json, address_str ) do
  end

  def is_in_transaction?( transaction_json, address_str ) do
  end

end
