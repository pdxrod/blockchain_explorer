defmodule BlockChainExplorerWeb.TransactionView do
  use BlockChainExplorerWeb, :view
  alias BlockChainExplorer.Blockchain

  def mark_up_transaction( transaction ) do
    result = Blockchain.get_transaction( transaction )
    case elem( result, 0 ) do
      :ok -> Poison.encode!( elem( result, 1 ), pretty: true )
      :error -> Poison.encode!( String.downcase( elem( result, 1 )[ "message" ] ), pretty: true )
      _ -> Poison.encode!( "unknown error", pretty: true )
    end
  end

  defp get_hex( transaction ) do
    result = Blockchain.getrawtransaction transaction
    case result do
      {:ok, hex } -> hex
      {:invalid, {:ok, hex }} -> hex # Why it does this I don't know, but it did
      {_, {:ok, hex }} -> hex
      _ -> nil
    end
  end

  defp get_transaction( transaction ) do
    hex = get_hex transaction
    Blockchain.decoderawtransaction( hex )
  end

end
