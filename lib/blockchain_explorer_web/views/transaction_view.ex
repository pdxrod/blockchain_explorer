defmodule BlockChainExplorerWeb.TransactionView do
  use BlockChainExplorerWeb, :view
  alias BlockChainExplorer.Transaction

  def mark_up_transaction( transaction_str ) do
    result = Transaction.get_transaction_tuple( transaction_str )
    case elem( result, 0 ) do
      :ok ->
        decoded_transaction = Transaction.decode_transaction( result )
        Poison.encode!( decoded_transaction, pretty: true )
      :error -> Poison.encode!( String.downcase( elem( result, 1 )[ "message" ] ), pretty: true )
      _ -> Poison.encode!( "unknown error", pretty: true )
    end
  end

end
