defmodule BlockChainExplorer.AddressTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Transaction
  alias BlockChainExplorer.Block
  alias BlockChainExplorer.Utils

  describe "addresses" do

    defp address_list( outputs ) do
      case outputs do
        [] -> []
        _ ->
          [hd | tl] = outputs
          if hd && hd.scriptpubkey && hd.scriptpubkey.addresses && length( hd.scriptpubkey.addresses ) > 0 do
            [Enum.at( hd.scriptpubkey.addresses, 0 )] ++ address_list( tl )
          else
            address_list( tl )
          end
      end
    end

    defp block_list( blocks ) do
      case blocks do
        [] -> []
        _ ->
          [head | tail] = blocks
          block = Block.decode_block head
          assert length( block.tx ) > 0
          tx_hash = Enum.at( block.tx, 0 )
          assert tx_hash =~ Utils.env :base_16_hash_regex
          tx_tuple = Transaction.get_transaction_tuple tx_hash
          decoded = Transaction.decode_transaction_tuple tx_tuple
          address_list( decoded.outputs ) ++ block_list( tail )
      end
    end

    test "sending coins" do
      block = Blockchain.get_best_block()
      blocks = Blockchain.get_n_blocks( block, 400 )
      uniq = Enum.uniq( block_list( blocks ))
      assert length( uniq ) > 0
      for address <- uniq do
        amount = :rand.uniform( 6 ) + 1
        IO.puts "\nSending #{amount} to #{address}"
        Blockchain.sendtoaddress(address, amount)
      end
    end

  end
end
