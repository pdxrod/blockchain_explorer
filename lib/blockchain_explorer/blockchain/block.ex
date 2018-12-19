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
    field :tx, :string
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
    timestamps()
  end

  def changeset(block, params \\ %{}) do
    block
    |> Ecto.Changeset.cast(params, ~w(height))
  end

  def decode_block( block ) do
    %BlockChainExplorer.Block{
      block: block,
      hash: block[ "hash" ], height: block[ "height" ],
      previousblockhash: block[ "previousblockhash" ], nextblockhash: block[ "nextblockhash" ],
      weight: block[ "weight" ], versionhex: block[ "versionHex" ],
      version: block[ "version" ], tx: "#{IO.inspect block[ "tx" ]}",
      time: block[ "time" ], strippedsize: block[ "strippedsize" ],
      size: block[ "size" ], nonce: block[ "nonce" ],
      merkleroot: block[ "merkleroot" ], mediantime: block[ "mediantime" ],
      difficulty: block[ "difficulty" ], confirmations: block[ "confirmations" ],
      chainwork: block[ "chainwork" ], bits: block[ "bits" ] }
  end
end
