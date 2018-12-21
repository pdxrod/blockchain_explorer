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

  defp join_with_spaces( list_of_strings ) do
    case list_of_strings do
      [] ->
        ""
      [ head | tail ] ->
        head <> if length(tail) < 1, do: "", else: " " <> join_with_spaces( tail )
    end
  end

  defp make_float( num ) do
    num / 1
  end

  def convert_to_struct( block ) do
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
          version: block[ "version" ], tx: join_with_spaces( block["tx"] ),
          time: block[ "time" ], strippedsize: block[ "strippedsize" ],
          size: block[ "size" ], nonce: block[ "nonce" ],
          merkleroot: block[ "merkleroot" ], mediantime: block[ "mediantime" ],
          difficulty: make_float( block[ "difficulty" ] ), confirmations: block[ "confirmations" ],
          chainwork: block[ "chainwork" ], bits: block[ "bits" ] }
      end
  end

  @floats [ "difficulty" ]
  @integers ["confirmations", "height", "mediantime", "nonce", "size", "strippedsize", "time", "version", "weight"]

  def strip_extra_quotes( str ) do
    if String.starts_with?( str, "\"" ) && String.ends_with?( str, "\"" ) do
      String.slice( str, 1..-2 )
    else
      str
    end
  end

  def convert_to_map( list_of_strs ) do
    case list_of_strs do
      [] ->
        []
      [head | tail ] ->
        key_val = String.split( head, "=" )
        key = List.first key_val
        val = List.last key_val
        val = strip_extra_quotes( val )
        val = if Enum.member?( @floats, key ), do: elem(:string.to_float( val ), 0), else: val
        val = if Enum.member?( @integers, key ), do: elem(:string.to_integer( val ), 0), else: val
        key = String.to_atom key
        [ {key, val} ] ++ convert_to_map( tail )
    end
  end

  def convert_block_str_to_map( block_str ) do
    String.split( block_str, "," )
    |> convert_to_map()
  end

  def convert_struct( block_map ) do
    block = Map.delete( block_map, :__meta__ )
    block = Map.delete( block, :block )
    block = Map.delete( block, :id )
    block = Map.delete( block, :inserted_at )
    Map.delete( block, :updated_at )
  end

end
