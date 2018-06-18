defmodule BlockChainExplorer.Transaction do
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Utils

  defmodule ScriptPubKey do
    defstruct type: nil, reqsigs: 0, hex: nil, asm: nil, addresses: nil
  end

  defmodule Output do
    defstruct value: -1.0, scriptpubkey: %ScriptPubKey{}, n: -1
  end

  defmodule Input do
    defstruct vout: nil, txid: nil, sequence: 0, scriptsig: nil, coinbase: nil
  end

  @a_transaction %{
    "vsize": 184,
    "vout": [
      %{
        "value": 0.78152,
        "scriptPubKey": %{
          "type": "scripthash",
          "reqSigs": 1,
          "hex": "a9141a30c2cb52f5bd4fcbd8697b37b636f9b73ebedf87",
          "asm": "OP_HASH160 1a30c2cb52f5bd4fcbd8697b37b636f9b73ebedf OP_EQUAL",
          "addresses": [ "2MudhyEqJ7RzedMPXrReNXDcJ9Hch1AUqdv" ]
        },
        "n": 0
      },
      %{
        "value": 0.0,
        "scriptPubKey": %{
          "type": "nulldata",
          "hex": "6a24aa21a9ed4967c81d1c2ae8c9a438982483213e5ada29ee685780a397a8cd22ce9e262255",
          "asm": "OP_RETURN aa21a9ed4967c81d1c2ae8c9a438982483213e5ada29ee685780a397a8cd22ce9e262255"
        },
        "n": 1
      }
    ],
    "vin": [
      %{
        "sequence": 4294967295,
        "coinbase": "03190b14042126065b726567696f6e312f50726f6a65637420425443506f6f6c2f020df278d618000000000000"
      }
    ],
    "version": 2,
    "txid": "53a9f958519b4cbecb34c1315980e833a67b6aa5c9e242aab74f49d0a5e9bfb6",
    "size": 211,
    "locktime": 0,
    "hash": "98e8e6534e0fb4a515f314ea7bd7f8d4b63803894feca243c8c9608e0aa8e679"
  }

  defstruct vsize: 0, outputs: [], inputs: [], version: 0, txid: "", size: 0, locktime: 0, hash: ""

  def get_transaction_strs( block_map ) do
    block_map[ "tx" ]
  end

  def outputs_total_value( decoded_transaction ) do
    Enum.reduce decoded_transaction.outputs, 0.0, fn( output, acc ) ->
      output.value + acc
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

  defp output_has_addresses?( output ) do
    output.scriptpubkey &&
     output.scriptpubkey.addresses &&
      length( output.scriptpubkey.addresses ) > 0
  end

  def has_output_addresses?( list_of_output_modules ) do
    Utils.recurse( false, true, list_of_output_modules, &output_has_addresses?/1 )
  end

  defp outputs_has_everything?( outputs_list_of_maps ) do
    Utils.recurse( false, true, outputs_list_of_maps, fn(output) ->
                   output["value"] > 0.0 && output["scriptPubKey"] && output["scriptPubKey"]["hex"] &&
                   output["scriptPubKey"]["asm"] && output["scriptPubKey"]["addresses"] &&
                   length(output["scriptPubKey"]["addresses"]) > 0 end )
  end

  defp inputs_has_everything?( inputs_list_of_maps ) do
    Utils.recurse( false, true, inputs_list_of_maps, fn(input) -> input["sequence"] > 0 &&
                   input["scriptSig"] && input["scriptSig"]["asm"] && input["scriptSig"]["hex"] end)
  end

  defp has_everything?( transaction_str ) do
    transaction_tuple = get_transaction_tuple( transaction_str )
    if elem( transaction_tuple, 0 ) == :ok do
      trans = elem( transaction_tuple, 1 )
      ok = trans["vsize"] > 0 && trans["vout"] != [] && trans["vin"] != []
       && trans["txid"] != "" && trans["hash"] != ""
      if ok do
        outputs_has_everything?( trans["vout"] ) &&
         inputs_has_everything?( trans["vin"] )
      else
        false
      end
    else
      false
    end
  end

  defp transaction_with_everything_in_it_from_transactions( list_of_transaction_strs ) do
    case list_of_transaction_strs do
      [] -> nil
      _ ->
        [hd | tl] = list_of_transaction_strs
        cond do
          has_everything?( hd ) -> hd
          true -> transaction_with_everything_in_it_from_transactions( tl )
        end
    end
  end

  defp transaction_with_everything_in_it_from_block( block_map ) do
    list_of_transaction_strs = get_transaction_strs( block_map )
    transaction_with_everything_in_it_from_transactions( list_of_transaction_strs )
  end

  defp transaction_with_everything_in_it_from_list( blocks_list ) do
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

# Find a transaction which has inputs, outputs, addresses, etc.
  def transaction_with_everything_in_it_from_tuple( blocks_tuple ) do
    blocks_list = Tuple.to_list( blocks_tuple )
    transaction_with_everything_in_it_from_list( blocks_list )
  end

  defp decode_outputs( list_of_maps ) do
    if list_of_maps do
      Enum.map( list_of_maps, fn( map ) ->
        %Output{ value: map["value"], n: map["n"],
         scriptpubkey: %ScriptPubKey{ type: map["scriptPubKey"]["type"],
                                      hex: map["scriptPubKey"]["hex"],
                                      asm: map["scriptPubKey"]["asm"],
                                      reqsigs: map["scriptPubKey"]["reqSigs"],
                                      addresses: map["scriptPubKey"]["addresses"]} } end )
    else
      []
    end
  end

  def decode_transaction( tuple ) do
    transaction = case elem( tuple, 0 ) do
      :ok -> elem( tuple, 1 )
      _ -> %{ error: tuple }
    end

    %BlockChainExplorer.Transaction{
      outputs: decode_outputs( transaction[ "vout" ] ),
      inputs: decode_inputs( transaction[ "vin" ] ),
      version: transaction[ "version" ],
      txid: transaction[ "txid" ], size: transaction[ "size" ],
      hash: transaction[ "hash" ], vsize: transaction[ "vsize" ] }
  end

  defp get_hex( transaction_str ) do
    result = Blockchain.getrawtransaction transaction_str
    case result do
      {:ok, hex } -> hex
      {:invalid, {:ok, _ }} -> nil
      {_, {:ok, hex }} -> hex
      _ -> nil
    end
  end

  def get_transaction_tuple( transaction_str ) do
    hex = get_hex transaction_str
    Blockchain.decoderawtransaction hex
  end

end
