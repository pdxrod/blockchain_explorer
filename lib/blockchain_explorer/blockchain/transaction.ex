defmodule BlockChainExplorer.Transaction do

  defstruct value: 0.0, confirmations: 0, block: 0, relay_time: 0,
    inputs: [], outputs: [], fee: 0.0, size: 0

  def get_transactions( block ) do
    block[ "tx" ]
  end

  def decode_transaction( block, transaction ) do
    %BlockChainExplorer.Transaction{ block: block[ "height" ] }
  end

end
