defmodule BlockChainExplorer.Rpc do
  alias BlockChainExplorer.Utils

# Thanks https://github.com/pcorey/hello_blockchain
  def bitcoin_rpc(method, params \\ []) do
    with url <- Utils.env( :bitcoin_url ),
         command         <- %{jsonrpc: "1.0", method: method, params: params},
         {:ok, body}     <- Poison.encode(command),
         {:ok, response} <- HTTPoison.post(url, body),
         {:ok, metadata} <- Poison.decode(response.body),
         %{"error" => nil, "result" => result} <- metadata do
      {:ok, result}
    else
      %{"error" => reason} -> {:error, reason}
      error -> error
    end
  end

  def getbestblockhash, do: bitcoin_rpc("getbestblockhash")
  def getblockhash(height), do: bitcoin_rpc("getblockhash", [height])
  def getblock(hash), do: bitcoin_rpc("getblock", [hash])
  def getblockheader(hash), do: bitcoin_rpc("getblockheader", [hash])
  def getrawtransaction(trans), do: bitcoin_rpc( "getrawtransaction", [trans] )
  def decoderawtransaction(hex), do: bitcoin_rpc( "decoderawtransaction", [hex] )
  def sendtoaddress(address, amount), do: bitcoin_rpc( "sendtoaddress", [address, amount] )
  def getmininginfo, do: bitcoin_rpc("getmininginfo")
end
