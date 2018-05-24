defmodule BlockChainExplorer.Transaction do
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Utils

  defstruct vout: [], confirmations: 0, block: 0, relay_time: 0,
    inputs: [], outputs: [], fee: 0.0, size: 0

  def get_transactions( block ) do
    block[ "tx" ]
  end

  def total_value( vin_or_vout ) do
    Enum.reduce vin_or_vout, 0.0, fn( tuple, acc ) ->
      tuple[ "value" ] + acc
    end
  end

  def decode_transaction( block, tuple ) do
    case elem( tuple, 0 ) do
      :ok ->
        transaction = elem( tuple, 1 )
        vout = transaction[ "vout" ]
IO.puts "\n\ntransaction:"
IO.puts Poison.encode! elem( tuple, 1 ), pretty: true
IO.puts "\n\n"
IO.puts Utils.typeof transaction
IO.puts "\n\n"
IO.puts "total value"
IO.puts total_value( vout )
IO.puts "\n\n"
      _ ->
        transaction = { elem( tuple, 0 ) }
    end

    %BlockChainExplorer.Transaction{ block: block[ "height" ], vout: vout }

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

  def get_transaction( transaction ) do
    hex = get_hex transaction
    Blockchain.decoderawtransaction( hex )
  end

end
