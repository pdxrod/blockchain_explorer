defmodule BlockChainExplorer.Block do
  use Ecto.Schema
  alias BlockChainExplorer.Utils

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

  defp quotes_if_needed( value ) do
    cond do
      Utils.typeof( value ) == "binary" -> "\"#{value}\""
      true -> value
    end
  end

  defp map_to_string( map ) do
    case map do
      %BlockChainExplorer.Block{} ->
        ""
      _ ->
        String.slice(Enum.reduce(map, "", fn({k, v}, acc) -> "#{acc}#{k}=#{quotes_if_needed(v)}," end), 0..-2)
    end
  end

  defp join_with_commas( list_of_strings ) do
    case list_of_strings do
      [] ->
        ""
      [ head | tail ] ->
        head <> if length(tail) < 1, do: "", else: "," <> join_with_commas( tail )
    end
  end

  def decode_block( block ) do
    case block do
      %{"code" => -5, "message" => "Block not found"} ->
        %{}
      %BlockChainExplorer.Block{} ->
        block
      _ ->
        %BlockChainExplorer.Block{
          block: map_to_string( block ),
          hash: block[ "hash" ], height: block[ "height" ],
          previousblockhash: block[ "previousblockhash" ], nextblockhash: block[ "nextblockhash" ],
          weight: block[ "weight" ], versionhex: block[ "versionHex" ],
          version: block[ "version" ], tx: join_with_commas( block["tx"] ),
          time: block[ "time" ], strippedsize: block[ "strippedsize" ],
          size: block[ "size" ], nonce: block[ "nonce" ],
          merkleroot: block[ "merkleroot" ], mediantime: block[ "mediantime" ],
          difficulty: block[ "difficulty" ], confirmations: block[ "confirmations" ],
          chainwork: block[ "chainwork" ], bits: block[ "bits" ] }
    end
  end
end
