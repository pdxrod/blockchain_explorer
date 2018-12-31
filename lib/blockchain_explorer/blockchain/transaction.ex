defmodule BlockChainExplorer.Transaction do
  alias BlockChainExplorer.Transaction
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Address
  alias BlockChainExplorer.Output
  alias BlockChainExplorer.Input
  alias BlockChainExplorer.Block
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Db
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
    field :version, :integer
    field :txid, :string
    field :size, :integer
    field :locktime, :integer
    field :hash, :string
  end

  def get_transactions do
    Db.all(
      from t in Transaction,
      select: t,
      where: t.block_id > -1
    )
  end

  def get_transactions_with_block_id( block_id ) do
    Db.all(
      from t in Transaction,
      select: t,
      where: t.block_id == ^block_id
    )
  end

  def get_transaction_with_hash( transaction_str, block_id \\ nil ) do
    result = case block_id do
      nil ->
        Db.all(
          from t in Transaction,
          select: t,
          where: t.hash == ^transaction_str
        )
      _ ->
        Db.all(
          from t in Transaction,
          select: t,
          where: t.hash == ^transaction_str and t.block_id == ^block_id
        )
    end
    if length( result ) == 0 do
      hex = get_hex transaction_str
      tuple = case hex do
        %{error: _} -> hex
        _ -> Rpc.decoderawtransaction hex
      end
      case tuple do
        %{error: _} -> tuple
        _ ->
          if elem( tuple, 0 ) == :ok do
            transaction = elem( tuple, 1 )
            transaction = save_transaction( transaction, block_id )
            Transaction.convert_to_struct transaction
          else
            Utils.error tuple
          end
      end
    else
      List.first( result )
    end
  end

  def get_transaction_with_txid( txid, block_id \\ nil ) do
    result = if block_id == nil do
      Db.all(
        from t in BlockChainExplorer.Transaction,
        select: t,
        where: t.txid == ^txid
      )
    else
      Db.all(
        from t in BlockChainExplorer.Transaction,
        select: t,
        where: t.txid == ^txid and t.block_id == ^block_id
      )
    end
    if length( result ) == 0 do
      hex = get_hex txid
      tuple = Rpc.decoderawtransaction hex
      if elem( tuple, 0 ) == :ok do
        transaction = elem( tuple, 1 )
        save_transaction transaction, block_id
      else
        Utils.error tuple
      end
    else
      List.first result
    end
  end

  def get_tx_ids( block_struct ) do
    block_string = block_struct.block
    map = Block.convert_block_str_to_map block_string
    String.split( map[ :tx ], " " )
  end

  def outputs_total_value( decoded_transaction ) do
    outputs = get_outputs decoded_transaction.id
    Enum.reduce outputs, 0.0, fn( output, acc ) ->
      output.value + acc
    end
  end

  defp output_has_addresses?( output ) do
    output_id = output.id
    addresses = if output_id == nil do
                  []
                else
                  Db.all(
                    from a in Address,
                    select: a,
                    where: a.output_id == ^output_id
                  )
                end
    length( addresses ) > 0
  end

  defp outputs_has_everything?( outputs_list_of_maps ) do
    Utils.recurse( false, true, outputs_list_of_maps, fn(output) ->
                   output_has_addresses?( output ) && output.value > 0.0
                   && output.hex && output.asm
                   && String.contains?( output.asm, "OP_" ) end)
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

  def get_addresses( address_str, output_id ) do
    if address_str == nil do
      Db.all(
        from a in BlockChainExplorer.Address,
        select: a,
        where: a.output_id == ^output_id
      )
    else
      Db.all(
        from a in BlockChainExplorer.Address,
        select: a,
        where: a.address == ^address_str and a.output_id == ^output_id
      )
    end
  end

  defp get_addresses_from_outputs( outputs ) do
    case outputs do
      [] ->
        []
      [ hd | tl ] ->
        get_addresses( nil, hd.id ) ++ get_addresses_from_outputs( tl )
    end
  end

  def get_addresses( transaction_id ) do
    outputs = get_outputs( transaction_id )
    case outputs do
      [] ->
        []
      [ hd | tl ] ->
        get_addresses( nil, hd.id ) ++ get_addresses_from_outputs( tl )
    end
  end

  def get_address_strs( transaction_id ) do
    addresses = get_addresses( transaction_id )
    Enum.map( addresses, fn( a ) -> a.address end)
  end

  def get_outputs( transaction_id ) do
    Db.all(
      from o in Output,
      select: o,
      where: o.transaction_id == ^transaction_id
    )
  end

  def get_inputs( transaction_id ) do
    Db.all(
      from i in Input,
      select: i,
      where: i.transaction_id == ^transaction_id
    )
  end

  defp has_everything?( transaction_str, block_id ) do
    transaction = get_transaction_with_hash( transaction_str, block_id )
    inputs = get_inputs( transaction.id  )
    outputs = get_outputs( transaction.id )
    inputs_has_everything?( inputs ) &&
     outputs_has_everything?( outputs )
  end

  defp transaction_with_everything_in_it_from_transactions( list_of_tx_ids, block_id ) do
    case list_of_tx_ids do
      [] ->
        %{}
      _ ->
        [hd | tl] = list_of_tx_ids
        cond do
          has_everything?( hd, block_id ) -> get_transaction_with_txid( hd, block_id )
          true -> transaction_with_everything_in_it_from_transactions( tl, block_id )
        end
    end
  end

  defp transaction_with_everything_in_it_from_block( block_map ) do
    case block_map do
      %{error: _} -> block_map
      _ ->
        db_block =  Blockchain.get_from_db_or_bitcoind_by_hash( block_map.hash ) # inserts it in db if it's not there
        list_of_tx_ids = get_tx_ids( block_map )
        transaction_with_everything_in_it_from_transactions( list_of_tx_ids, db_block.id )
    end
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

  def seed_db_and_get_a_useful_transaction do
    Blockchain.get_n_blocks( nil, 100 )
    |> transaction_with_everything_in_it_from_list()
  end

  defp make_struct( transaction, block_id ) do
    %BlockChainExplorer.Transaction{
      block_id: block_id,
      version: transaction[ "version" ],
      txid: transaction[ "txid" ],
      size: transaction[ "size" ],
      hash: transaction[ "hash" ],
      vsize: transaction[ "vsize" ],
      locktime: transaction[ "locktime" ],
      outputs: "",
      inputs: "" }
    end

  def convert_to_struct( transaction, block_id \\ nil ) do
    case transaction do
      %{"code" => -5, "message" => "Block not found"} ->
        Utils.error transaction
      %BlockChainExplorer.Transaction{txid: _} ->
        transaction
      _ ->
       make_struct transaction, block_id
    end
  end

  defp get_hex( transaction_str ) do
    result = Rpc.getrawtransaction transaction_str
    case result do
      {:ok, hex } -> hex
      _ -> Utils.error result
    end
  end

  defp save_output( output, transaction ) do
    db_output = %Output{transaction_id: transaction.id,
                        input_id: nil,
                        value: output["value"],
                        n: output["n"],
                        asm: output["scriptPubKey"]["asm"],
                        hex: output["scriptPubKey"]["hex"],
                        addresses: "" }

    tuple = Db.insert db_output
    Db.get_db_result_from_tuple tuple
  end

  defp save_address( address_str, output_id ) do
    address = %Address{ address: address_str, output_id: output_id }
    tuple = Db.insert address
    Db.get_db_result_from_tuple tuple
  end

  defp save_input( input, transaction ) do
    db_input = %Input{ transaction_id: transaction.id,
                sequence: input["sequence"],
                scriptsig: input["scriptSig"],
                coinbase: input["coinbase"],
                asm: input["asm"], hex: input["hex"] }
    tuple = Db.insert db_input
    Db.get_db_result_from_tuple tuple
  end

  defp save_outputs( outputs, transaction ) do
    for output <- outputs do
      db_output = save_output output, transaction
      addresses = output["scriptPubKey"]["addresses"]
      if addresses != nil do
        for address <- addresses do
          save_address address, db_output.id
        end
      end
    end
  end

  defp save_inputs( inputs, transaction ) do
    for input <- inputs do
      save_input input, transaction
    end
  end

  def save_transaction( transaction_map, block_id ) do
    txid = transaction_map["txid"]
    result = if block_id == nil do
      Db.all(
        from t in BlockChainExplorer.Transaction,
        select: t,
        where: t.txid == ^txid )
    else
      Db.all(
        from t in BlockChainExplorer.Transaction,
        select: t,
        where: t.txid == ^txid and t.block_id == ^block_id )
    end
    if length( result ) == 0 do
      converted = Transaction.convert_to_struct transaction_map, block_id
      tuple = Db.insert converted
      if elem( tuple, 0 ) == :ok do
        db_transaction = elem( tuple, 1 )
        outputs = transaction_map["vout"]
# [%{"n" => 0, "scriptPubKey" => %{"addresses" => ["mweuYxnDidLJyeLADMTskSPBx5sFP7a3VA"], "asm" => "03275aeb962492a5512728e04dce96ca49a9126b069e7b26c45506c8908b047ad0 OP_CHECKSIG"...},
#  %{"n" => 1, "scriptPubKey" => %{"asm" => "OP_RETURN aa21a9ede2f61c3f71d1defd3fa999dfa36953755c690689799962b48bebd836974e8cf9", "type" => "nulldata"}, "value" => 0.0}]

        inputs = transaction_map["vin"]
        save_outputs outputs, db_transaction
        save_inputs inputs, db_transaction
        db_transaction
      else
        Utils.error tuple
      end
    else
      List.first result
    end
  end

end
