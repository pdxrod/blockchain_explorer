defmodule BlockChainExplorer.Output do
  use Ecto.Schema
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Transaction
  alias BlockChainExplorer.Block
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Rpc

  schema "outputs" do
    field :transaction_id, :integer
    field :input_id, :integer
    field :value, :float
    field :n, :integer
    field :asm, :string
    field :hex, :string
    field :addresses, :string
  end

end
