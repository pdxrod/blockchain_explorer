defmodule BlockChainExplorer.AddressTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Transaction
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Rpc

  describe "addresses" do

    defp address_list( outputs ) do
      case outputs do
        [] -> []
        _ ->
          [hd | tl] = outputs
          addresses = Transaction.get_addresses nil, hd.id
          if length( addresses ) > 0 do
            [ Enum.at( addresses, 0 ) ] ++ address_list( tl )
          else
            address_list( tl )
          end
      end
    end

    defp block_list( blocks ) do
      case blocks do
        %{error: _} ->
          Utils.error blocks
        [] ->
          []
        _ ->
          [head | tail] = blocks
          tx_hash = head.tx
          assert tx_hash =~ Utils.env :base_16_hash_regex
          transaction = Transaction.get_transaction_with_hash tx_hash, head.id
          address_list( Transaction.get_outputs( transaction.id )) ++ block_list( tail )
      end
    end

    test "sending coins" do
      if Utils.mode == "regtest" do
        num = 400
        block = Blockchain.get_highest_block_from_db_or_bitcoind()
  #      blocks = Enum.map( blocks, &Blockchain.get_from_db_or_bitcoind_by_hash(&1.hash) )
        blocks = Blockchain.get_n_blocks( block, num )
        list = block_list( blocks )
        uniq = Enum.uniq( list )
        assert length( uniq ) > 0
        for address <- uniq do
          amount = :rand.uniform( 3 ) + 1
          Rpc.sendtoaddress(address, amount)
        end
      end
    end
  end
end
