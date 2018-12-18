defmodule BlockChainExplorer.Block do
  use Ecto.Schema

  schema "blocks" do
    field :block, :string
    field :hash, :string
    field :height, :integer
    field :previousblockhash, :string
    field :nextblockhash, :string
    field :weight, :integer
    field :versionhex, :string
    field :version, :integer
    field :time, :integer
    field :strippedsize, :integer
    field :size, :integer
    field :nonce, :integer
    field :merkleroot, :string
    field :mediantime, :integer
    field :difficulty, :float
    field :confirmations, :integer
    field :chainwork, :string
    field :bits, :string
    field :tx, :string
    timestamps()
  end

  def changeset(block, params \\ %{}) do
    block
    |> Ecto.Changeset.cast(params, ~w(height))
  end

  def decode_block( block ) do
    %BlockChainExplorer.Block{
      weight: block[ "weight" ], versionhex: block[ "versionHex" ],
      version: block[ "version" ], tx: block[ "tx" ],
      time: block[ "time" ], strippedsize: block[ "strippedsize" ],
      size: block[ "size" ], previousblockhash: block[ "previousblockhash" ],
      nonce: block[ "nonce" ], nextblockhash: block[ "nextblockhash" ],
      merkleroot: block[ "merkleroot" ], mediantime: block[ "mediantime" ],
      height: block[ "height" ], hash: block[ "hash" ], difficulty: block[ "difficulty" ],
      confirmations: block[ "confirmations" ], chainwork: block[ "chainwork" ], bits: block[ "bits" ] }
  end
end
