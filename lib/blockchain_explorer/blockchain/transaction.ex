defmodule BlockChainExplorer.Transaction do
  alias BlockChainExplorer.Blockchain

  @transaction %{
    "vsize": 184,
    "vout": [
      %{
        "value": 0.78152,
        "scriptPubKey": %{
          "type": "scripthash",
          "reqSigs": 1,
          "hex": "a9141a30c2cb52f5bd4fcbd8697b37b636f9b73ebedf87",
          "asm": "OP_HASH160 1a30c2cb52f5bd4fcbd8697b37b636f9b73ebedf OP_EQUAL",
          "addresses": [
            "2MudhyEqJ7RzedMPXrReNXDcJ9Hch1AUqdv"
          ]
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

  defstruct vsize: 0, outputs: [], inputs: [], version: 0, txid: "", size: 0, hash: ""

  def get_transactions( block ) do
    block[ "tx" ]
  end

  def total_value( outputs ) do
    Enum.reduce outputs, 0.0, fn( tuple, acc ) ->
      tuple[ "value" ] + acc
    end
  end

  def decode_transaction( tuple ) do
    case elem( tuple, 0 ) do
      :ok ->
        transaction = elem( tuple, 1 )
      _ ->
        transaction = %{ error: tuple }
    end

    %BlockChainExplorer.Transaction{ outputs: transaction[ "vout" ],
      inputs: transaction[ "vin" ], version: transaction[ "version" ],
      txid: transaction[ "txid" ], size: transaction[ "size" ],
      hash: transaction[ "hash" ], vsize: transaction[ "vsize" ] }
  end

  defp get_hex( transaction ) do
    result = Blockchain.getrawtransaction transaction
    case result do
      {:ok, hex } -> hex
      {:invalid, {:ok, hex }} -> hex # Why it does this I don't know, but it did
      {_, {:ok, hex }} -> hex
      _ -> nil
    end
  end

  def get_transaction( transaction ) do
    hex = get_hex transaction
    Blockchain.decoderawtransaction( hex )
  end

end
