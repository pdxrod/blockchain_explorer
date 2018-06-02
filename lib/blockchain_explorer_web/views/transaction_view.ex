defmodule BlockChainExplorerWeb.TransactionView do
  use BlockChainExplorerWeb, :view
  alias BlockChainExplorer.Transaction

  def mark_up_transaction( transaction ) do
    result = Transaction.get_transaction_tuple( transaction )
    case elem( result, 0 ) do
      :ok -> Poison.encode!( elem( result, 1 ), pretty: true )
      :error -> Poison.encode!( String.downcase( elem( result, 1 )[ "message" ] ), pretty: true )
      _ -> Poison.encode!( "unknown error", pretty: true )
    end
  end

end
