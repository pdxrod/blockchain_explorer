defmodule BlockChainExplorer.Db do
  use Ecto.Schema
  alias BlockChainExplorer.Repo

  schema "blocks" do
    field :block, :string
    field :hash, :string
    field :height, :integer
    field :previousblockhash, :string
    field :nextblockhash, :string
    field :weight, :integer
    field :versionhex, :string
    field :version, :integer
    field :time, :string
    field :strippedsize, :integer
    field :size, :integer
    field :nonce, :integer
    field :merkleroot, :string
    field :mediantime, :integer
    field :difficulty, :float
    field :confirmations, :integer
    field :chainwork, :string
    field :bits, :string
    timestamps()
  end

  def changeset(block, params \\ %{}) do
    block
    |> Ecto.Changeset.cast(params, ~w(height))
  end

end