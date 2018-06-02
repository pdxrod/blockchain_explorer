defmodule BlockChainExplorerWeb.TransactionView do
  use BlockChainExplorerWeb, :view
  alias BlockChainExplorer.Transaction

  def mark_up_transaction( transaction_str ) do
    result = Transaction.get_transaction_tuple( transaction_str )
    case elem( result, 0 ) do
      :ok    -> t = Transaction.decode_transaction( result )
      IO.inspect t
      t
      :error -> Poison.encode!( String.downcase( elem( result, 1 )[ "message" ] ), pretty: true )
      _      -> Poison.encode!( "unknown error", pretty: true )
    end
  end

end
