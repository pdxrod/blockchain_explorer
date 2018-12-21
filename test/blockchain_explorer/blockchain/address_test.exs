defmodule BlockChainExplorer.AddressTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.Transaction
  alias BlockChainExplorer.Block
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Rpc

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
          tx_hash = head.tx
          assert tx_hash =~ Utils.env :base_16_hash_regex
          tx_tuple = Transaction.get_transaction_tuple tx_hash
          decoded = Transaction.decode_transaction_tuple tx_tuple
          address_list( decoded.outputs ) ++ block_list( tail )
      end
    end

    defp show_transactions( blocks ) do
      decoded = Enum.map( blocks, &Block.convert_to_struct/1 )
      for block <- decoded do
        transaction_tuples = Enum.map( block.tx, &Transaction.get_transaction_tuple/1 )
        for transaction_tuple <- transaction_tuples do
          decoded_trans = Transaction.decode_transaction_tuple( transaction_tuple )
          IO.puts "Transaction #{decoded_trans.hash}"
          if decoded_trans.outputs do
            for output <- decoded_trans.outputs do
              if output.scriptpubkey &&
                output.scriptpubkey.addresses do
                  for address <- output.scriptpubkey.addresses do
                    IO.puts "  Output address #{address}"
                  end
               end
             end
          else
            IO.puts "  No output addresses"
          end
          if decoded_trans.inputs do
            for input <- decoded_trans.inputs do
              IO.puts "  Input sequence #{input.sequence}"
              if input.scriptsig && input.scriptsig["asm"] do
                IO.puts "  Input asm #{input.scriptsig["asm"]}"
              else
                IO.puts "  Input - no asm"
              end
              if input.coinbase do
                IO.puts "  Input coinbase #{input.coinbase}"
              else
                IO.puts "  Input - no coinbase"
              end
              if input.vout do
                IO.puts "  Input vout #{IO.inspect input.vout}"
              else
                IO.puts "  Input - no vout"
              end
              if input.txid do
                IO.puts "  Input txid #{input.txid}"
              else
                IO.puts "  Input - no txid"
              end
            end
          end
        end
      end
    end

    test "sending coins" do
      if Utils.mode == "regtest" do
        num = 400
        block = Blockchain.get_best_block()
        blocks = Blockchain.get_n_blocks( block, num )
       # show_transactions( blocks )
        uniq = Enum.uniq( block_list( blocks ))
        assert length( uniq ) > 0
        for address <- uniq do
          amount = :rand.uniform( 3 ) + 1
          Rpc.sendtoaddress(address, amount)
        end
      end
    end
  end
end
