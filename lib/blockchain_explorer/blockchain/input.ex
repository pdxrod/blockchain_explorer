defmodule BlockChainExplorer.Input do
  use Ecto.Schema
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Transaction
  alias BlockChainExplorer.Block
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Rpc

  schema "inputs" do
    field :transaction_id, :integer
    field :sequence, :integer
    field :scriptsig, :string
    field :coinbase, :string
    field :asm, :string
    field :hex, :string
  end

end
