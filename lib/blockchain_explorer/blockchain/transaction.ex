defmodule BlockChainExplorer.Transaction do
  use Ecto.Schema
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Block
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Rpc

  defmodule ScriptPubKey do # locking script for outputs
    defstruct type: nil, reqsigs: 0, hex: nil, asm: nil, addresses: nil
  end

  defmodule Output do
    defstruct value: -1.0, n: -1
  end

  defmodule Input do # scriptsig is unlocking key for inputs
    defstruct vout: nil, txid: nil, sequence: 0, scriptsig: nil, coinbase: nil
  end

  schema "transactions" do
    field :block_id, :integer
    field :vsize, :integer
    field :outputs, :string
    field :inputs, :string
    field :version, :string
    field :txid, :string
    field :size, :string
    field :locktime, :integer
    field :hash, :string
  end

  def get_transaction_strs( block_map ) do
    block = block_map.block
    map = Block.convert_block_str_to_map block
    String.split( map[ :tx ], " " )
  end

  def outputs_total_value( decoded_transaction ) do
    Enum.reduce decoded_transaction.outputs, 0.0, fn( output, acc ) ->
      output.value + acc
    end
  end

  defp output_has_addresses?( output ) do
    output["scriptPubKey"] &&
     output["scriptPubKey"]["addresses"] &&
      length( output["scriptPubKey"]["addresses"] ) > 0
  end

  def has_output_addresses?( list_of_output_modules ) do
    Utils.recurse( false, true, list_of_output_modules, &output_has_addresses?/1 )
  end

  defp outputs_has_everything?( outputs_list_of_maps ) do
    Utils.recurse( false, true, outputs_list_of_maps, fn(output) ->
                   output["value"] > 0.0 && output["scriptPubKey"] && output["scriptPubKey"]["hex"] &&
                   output["scriptPubKey"]["asm"] && String.contains?( output["scriptPubKey"]["asm"], "OP_" )
                   && output["scriptPubKey"]["addresses"] && length(output["scriptPubKey"]["addresses"]) > 0 end )
  end

  defp useful_input?( input ) do
    if Utils.mode == "regtest" do
      input["sequence"] > -1
    else
      input["sequence"] > -1 && (input["scriptSig"] && input["scriptSig"]["asm"] && input["scriptSig"]["hex"])
    end
  end

  defp inputs_has_everything?( inputs_list_of_maps ) do
    Utils.recurse( false, true, inputs_list_of_maps, &useful_input?/1 )
  end

  defp get_outputs( transaction_id ) do
    Repo.all(
      from o in Output,
      select: o,
      where: o.transaction_id == ^transaction_id
    )
  end

  defp get_inputs( transaction_id ) do
    Repo.all(
      from i in Input,
      select: i,
      where: i.transaction_id == ^transaction_id
    )
  end

  defp has_everything?( transaction_str, block_id ) do
    transaction = get_from_db_or_insert( transaction_str, block_id )
    outputs = get_outputs( transaction.id )
    inputs = get_inputs( transaction.id )
    outputs_has_everything?( outputs ) &&
     inputs_has_everything?( inputs )
  end

  def get_from_db_or_insert( transaction_str, block_id ) do
    result = Repo.all(
      from t in Transaction,
      select: t,
      where: t.txid == ^transaction_str,
      and: t.block_id == ^block_id
    )
    if length( result ) == 0 do
      insertable_transaction = %Transaction{ block_id: block_id, txid: transaction_str }
      Repo.insert insertable_transaction
      insertable_transaction
      end
    else
      List.first( result )
    end

  end

  defp transaction_with_everything_in_it_from_transactions( list_of_transaction_strs, block_id ) do
    case list_of_transaction_strs do
      [] -> nil
      _ ->
        [hd | tl] = list_of_transaction_strs
        cond do
          has_everything?( hd, block_id ) -> get_from_db_or_insert( hd, block_id )
          true -> transaction_with_everything_in_it_from_transactions( tl, block_id )
        end
    end
  end

  defp transaction_with_everything_in_it_from_block( block_map ) do
    db_block =  Blockchain.get_from_db_or_bitcoind_by_hash( block_map["hash"] # inserts it if it's not there
    list_of_transaction_strs = get_transaction_strs( block_map )
    transaction_with_everything_in_it_from_transactions( list_of_transaction_strs, db_block.id )
  end

  def transaction_with_everything_in_it_from_list( blocks_list ) do
    case blocks_list do
      [] -> nil
      _ ->
        [hd | tl] = blocks_list
        transaction = transaction_with_everything_in_it_from_block( hd )
         case transaction do
           nil -> transaction_with_everything_in_it_from_list( tl )
           _ -> transaction
         end
    end
  end

# This is mostly for testing, but it's also used to show an example search string on a page, so it belongs here
  def get_a_useful_transaction do
    tuple = Blockchain.get_n_blocks( nil, 100 )
    |> transaction_with_everything_in_it_from_list()
    |> get_transaction_tuple()
    case elem( tuple, 0 ) do
      :ok -> elem( tuple, 1 )
      _ -> %{ error: tuple }
    end
  end

  def get_an_address( outputs ) do
    [ hd | tl ] = outputs
    addresses = hd["scriptPubKey"]["addresses"]
    case addresses do
      nil -> get_an_address( tl )
      [] -> get_an_address( tl )
      _ -> List.first addresses
    end
  end

  defp decode_inputs( list_of_maps ) do
    if list_of_maps do
      Enum.map( list_of_maps, fn( map ) -> %Input{ vout: map["vout"], txid: map["txid"],
                          sequence: map["sequence"], scriptsig: map["scriptSig"] } end )
    else
      []
    end
  end

  defp decode_outputs( list_of_maps ) do
    if list_of_maps do
      Enum.map( list_of_maps, fn( map ) ->
        %Output{ value: map["value"], n: map["n"] } end )
    else
      []
    end
  end

  def decode_transaction_tuple( tuple ) do
    transaction = case elem( tuple, 0 ) do
      :ok -> elem( tuple, 1 )
      _ -> %{ error: tuple }
    end
    decode transaction
  end

  def decode( transaction, block_id ) do
    %BlockChainExplorer.Transaction{
      block_id: block_id,
      version: transaction[ "version" ]
      txid: transaction[ "txid" ],
      size: transaction[ "size" ],
      hash: transaction[ "hash" ],
      vsize: transaction[ "vsize" ],
      locktime: transaction[ "locktime" ] }
      outputs: Utils.join_with_spaces( transaction["vout"] )
      inputs: Utils.join_with_spaces( transaction["vin"] )
  end

  defp get_hex( transaction_str ) do
    result = Rpc.getrawtransaction transaction_str
    case result do
      {:ok, hex } -> hex
      {:invalid, {:ok, _ }} -> nil
      {_, {:ok, hex }} -> hex
      _ -> nil
    end
  end

  def save_transaction( transaction, block_id ) do
    decoded = decode transaction
    Repo.insert decoded
    decoded
  end

  def get_transaction( transaction_str, block_id ) do
    result = Repo.all(
      from t in Transaction,
      select: t,
      where: t.hash == ^transaction_str
    )
    if length( result ) == 0 do
      hex = get_hex transaction_str
      tuple = Rpc.decoderawtransaction hex
      if elem( tuple, 0 ) == :ok do
        transaction = elem( tuple, 1 )
        save_transaction transaction, block_id
        transaction
      else
        %{}
      end
    else
      List.first( result )
    end
  end

end
