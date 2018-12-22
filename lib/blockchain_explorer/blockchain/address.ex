defmodule BlockChainExplorer.Address do
  use Ecto.Schema
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Transaction
  alias BlockChainExplorer.Block
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Rpc

  def changeset(address, params \\ %{}) do
    address
    |> Ecto.Changeset.cast(params, ~w(address))
  end

  schema "addresses" do
    field :output_id, :integer
    field :address, :string
  end

end
