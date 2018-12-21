defmodule BlockChainExplorer.Input do
  use Ecto.Schema
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Transaction
  alias BlockChainExplorer.Block
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Rpc

  schema "inputs" do
    add :transaction_id, :integer
    add :sequence, :integer
    add :scriptsig, :string
    add :coinbase, :string
  end

end
