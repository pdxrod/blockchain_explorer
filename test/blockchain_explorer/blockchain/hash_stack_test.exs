defmodule BlockChainExplorer.HashStackTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.HashStack
  alias BlockChainExplorer.Rpc

  describe "hash stack" do

    test "push & pop" do
      result = Rpc.getbestblockhash()
      if elem( result, 0 ) == :ok do
        hash = elem( result, 1 )
        block = Blockchain.get_from_db_or_bitcoind_by_hash( hash )
        HashStack.push( block )
        new_block = HashStack.pop()
        new_hash = new_block.hash
        assert hash == new_hash
      else
        raise "Error - is bitcoind running?"
      end
    end

    test "attempt to push anything but a block fails" do
      result = Rpc.getbestblockhash()
      if elem( result, 0 ) == :ok do
        hash = elem( result, 1 )
        block = Blockchain.get_from_db_or_bitcoind_by_hash( hash )
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
      else
        raise "Error - is bitcoind running?"
      end
    end

    test "push & pop twice" do
      HashStack.pop_til_empty()
      result = Rpc.getbestblockhash()
      if elem( result, 0 ) == :ok do
        hash = elem( result, 1 )
        block = Blockchain.get_from_db_or_bitcoind_by_hash( hash )
        first_blocks = Blockchain.get_n_blocks( block, 2 )
        [first_block | _] = first_blocks
        HashStack.push( first_block )
        block = first_block
        second_blocks = Blockchain.get_n_blocks( block, 2 )
        second_block = Enum.at( second_blocks, 0 )
        HashStack.push( second_block )
        first_popped_block = HashStack.pop()
        second_popped_block = HashStack.pop()
        assert first_popped_block == second_block
        assert second_popped_block == first_block
        assert nil == HashStack.pop()
      else
        raise "Error - is bitcoind running?"
      end
    end

    test "empty" do
      result = Rpc.getbestblockhash()
      if elem( result, 0 ) == :ok do
        hash = elem( result, 1 )
        block = Blockchain.get_from_db_or_bitcoind_by_hash( hash )
        HashStack.push block
        blocks = Blockchain.get_n_blocks( block, 2 )
        assert length( blocks ) == 2
        other_block = List.last( blocks )
        HashStack.push other_block
        HashStack.pop_til_empty()
        assert nil == HashStack.pop()
      else
        raise "Error - is bitcoind running?"
      end
    end

    test "push & peek" do
      result = Rpc.getbestblockhash()
      if elem( result, 0 ) == :ok do
        hash = elem( result, 1 )
        block = Blockchain.get_from_db_or_bitcoind_by_hash( hash )
        HashStack.push( block )
        assert block == HashStack.peek()
      else
        raise "Error - is bitcoind running?"
      end
    end

  end
end
