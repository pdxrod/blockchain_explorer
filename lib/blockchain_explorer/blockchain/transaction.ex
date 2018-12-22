defmodule BlockChainExplorer.Transaction do
  alias BlockChainExplorer.Transaction
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Address
  alias BlockChainExplorer.Output
  alias BlockChainExplorer.Input
  alias BlockChainExplorer.Block
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Repo
  alias BlockChainExplorer.Rpc
  use Ecto.Schema
  import Ecto.Query

  def changeset(trans, params \\ %{}) do
    trans
    |> Ecto.Changeset.cast(params, ~w(txid))
  end

  defmodule ScriptPubKey do # locking script for outputs
    defstruct type: nil, reqsigs: 0, hex: nil, asm: nil, addresses: nil
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

  def get_transaction_from_db( transaction_address_str, block_id ) do
    Repo.all(
      from t in Transaction,
      select: t,
      where: t.txid == ^transaction_address_str and t.block_id == ^block_id
    )
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
    output_id = output.id
    addresses = if output_id == nil do
                  []
                else
                  Repo.all(
                    from a in Address,
                    select: a,
                    where: a.output_id == ^output_id
                  )
                end
    if length( addresses ) == 0 do
      if output.addresses != nil and String.length( output.addresses ) > 0 do
        save_addresses output
        true
      else
        false
      end
    else
      true
    end
  end

  defp outputs_has_everything?( outputs_list_of_maps ) do
    Utils.recurse( false, true, outputs_list_of_maps, fn(output) ->
                   output.value > 0.0 && output.hex &&
                   output.asm && String.contains?( output.asm, "OP_" )
                   && output_has_addresses?( output ) end)
  end

  defp useful_input?( input ) do
    if Utils.mode == "regtest" do
      input.sequence > -1
    else
      input.sequence > -1 && input.asm && input.hex
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
    inputs = get_inputs( transaction.id  )
    outputs = get_outputs( transaction.id )
    inputs_has_everything?( inputs ) &&
     outputs_has_everything?( outputs )
  end

  def get_from_db_or_insert( transaction_str, block_id ) do
    result = Repo.all(
      from t in BlockChainExplorer.Transaction,
      select: t,
      where: t.txid == ^transaction_str and t.block_id == ^block_id
    )
    if length( result ) == 0 do
      insertable_transaction = %BlockChainExplorer.Transaction{
        block_id: block_id, txid: transaction_str }
      Repo.insert insertable_transaction
      result = get_transaction_from_db( transaction_str, block_id )
      List.first result
    else
      List.first result
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
    db_block =  Blockchain.get_from_db_or_bitcoind_by_hash( block_map.hash ) # inserts it if it's not there
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
    Blockchain.get_n_blocks( nil, 100 )
    |> transaction_with_everything_in_it_from_list()
  end

  def decode( transaction, block_id ) do
    %BlockChainExplorer.Transaction{
      block_id: block_id,
      version: transaction[ "version" ],
      txid: transaction[ "txid" ],
      size: transaction[ "size" ],
      hash: transaction[ "hash" ],
      vsize: transaction[ "vsize" ],
      locktime: transaction[ "locktime" ],
      outputs: Utils.join_with_spaces( transaction["vout"] ),
      inputs: Utils.join_with_spaces( transaction["vin"] ) }
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

  defp save_output( output, transaction ) do
    if output.id == nil do
      db_output = %Output{transaction_id: transaction.id,
                          input_id: nil,
                          value: output["value"],
                          n: output["n"],
                          asm: output["asm"],
                          hex: output["hex"],
                          addresses: "" }
      Repo.insert db_output
    end
    List.first get_outputs( transaction.id )
  end

  defp get_addresses( address_str, output_id ) do
    Repo.all(
      from a in BlockChainExplorer.Address,
      select: a,
      where: a.address == ^address_str and a.output_id == ^output_id
    )
  end

  defp save_address( address_str, output_id ) do
    address = %Address{ address: address_str, output_id: output_id }
    Repo.insert address
    List.first get_addresses( address_str, output_id )
  end

  defp save_addresses( output ) do
    for address_str <- output.addresses do
      save_address( address_str, output.id )
    end
  end

  defp save_input( input, transaction ) do
    if input.id == nil do
      db_input = %Input{ transaction_id: transaction.id,
                  sequence: input["sequence"],
                  scriptsig: input["scriptSig"],
                  coinbase: input["coinbase"],
                  asm: input["asm"], hex: input["hex"] }
      Repo.insert db_input
    end
    List.first get_inputs( transaction.id )
  end

  defp save_outputs( outputs, transaction ) do
    for output <- outputs do
      db_output = save_output output, transaction
      addresses = output["scriptPubKey"]["addresses"]
      for address <- addresses do
        save_address address, db_output.id
      end
    end
  end

  defp save_inputs( inputs, transaction ) do
    for input <- inputs do
      save_input input, transaction
    end
  end

  def save_transaction( transaction, block_id ) do
    outputs = transaction["vout"]
    inputs = transaction["vin"]
    save_outputs outputs, transaction
    save_inputs inputs, transaction
    decoded = Transaction.decode transaction, block_id
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
