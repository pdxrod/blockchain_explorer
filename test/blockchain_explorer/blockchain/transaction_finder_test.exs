defmodule BlockChainExplorer.TransactionFinderTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.TransactionFinder

  describe "transaction finder test" do

    test "find" do
      trans = TransactionFinder.find_transactions( "2Mz84" )

      IO.inspect Stream.take( trans, 1 )
    end

  end
end
