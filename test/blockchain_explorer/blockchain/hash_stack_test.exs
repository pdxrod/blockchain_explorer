defmodule BlockChainExplorer.HashStackTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.HashStack

  describe "hash stack" do

    test "push & pop" do
      result = Blockchain.getbestblockhash()
      if elem( result, 0 ) == :ok do
        hash = elem( result, 1 )
        case Blockchain.getblock( hash ) do
          {:ok, block} ->
            HashStack.push( block )
            new_block = HashStack.pop()
            new_hash = new_block[ "hash" ]
            assert hash == new_hash
          _ ->
            raise "Error - is bitcoind running?"
        end
      else
        raise "Error - is bitcoind running?"
      end
    end

    test "attempt to push anything but a block fails" do
      result = Blockchain.getbestblockhash()
      if elem( result, 0 ) == :ok do
        hash = elem( result, 1 )
        case Blockchain.getblock( hash ) do
          {:ok, block} ->
            blocks = Blockchain.get_n_blocks( block, 2 )
            err = try do
              HashStack.push blocks
              raise "We should not have reached this point - there should be an exception"
            rescue
              e in RuntimeError -> e
            end
            assert err.message == "HashStack only accepts blocks"
            err = try do
              HashStack.push {}
              raise "We should not have reached this point - there should be an exception"
            rescue
              e in RuntimeError -> e
            end
            assert err.message == "HashStack only accepts blocks"
            HashStack.push %{}

          _ ->
            raise "Error - is bitcoind running?"
        end
      else
        raise "Error - is bitcoind running?"
      end
    end

    test "push & pop twice" do
      HashStack.pop_til_empty()
      result = Blockchain.getbestblockhash()
      if elem( result, 0 ) == :ok do
        hash = elem( result, 1 )
        case Blockchain.getblock( hash ) do
          {:ok, block} ->
            first_blocks = Blockchain.get_n_blocks( block, 2 )
            first_block = elem( first_blocks, 0 )
            HashStack.push( first_block )
            block = elem( first_blocks, 1 )
            second_blocks = Blockchain.get_n_blocks( block, 2 )
            assert first_blocks != second_blocks
            second_block = elem( second_blocks, 0 )
            HashStack.push( second_block )
            first_popped_block = HashStack.pop()
            second_popped_block = HashStack.pop()
            assert first_popped_block == second_block
            assert second_popped_block == first_block
            assert nil == HashStack.pop()
          _ ->
            raise "Error - is bitcoind running?"
        end
      else
        raise "Error - is bitcoind running?"
      end
    end

    test "empty" do
      result = Blockchain.getbestblockhash()
      if elem( result, 0 ) == :ok do
        hash = elem( result, 1 )
        case Blockchain.getblock( hash ) do
          {:ok, block} ->
            HashStack.push block
            blocks = Blockchain.get_n_blocks( block, 2 )
            other_block = elem( blocks, 1 )
            HashStack.push other_block
            HashStack.pop_til_empty()
            assert nil == HashStack.pop()
          _ ->
            raise "Error - is bitcoind running?"
        end
      else
        raise "Error - is bitcoind running?"
      end
    end

    test "push & peek" do
      result = Blockchain.getbestblockhash()
      if elem( result, 0 ) == :ok do
        hash = elem( result, 1 )
        case Blockchain.getblock( hash ) do
          {:ok, block} ->
            HashStack.push( block )
            assert block == HashStack.peek()
          _ ->
            raise "Error - is bitcoind running?"
        end
      else
        raise "Error - is bitcoind running?"
      end
    end

  end
end
