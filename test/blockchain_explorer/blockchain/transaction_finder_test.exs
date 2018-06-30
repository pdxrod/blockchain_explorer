defmodule BlockChainExplorer.TransactionFinderTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.TransactionFinder

  describe "transaction finder test" do

    test "find" do
      trans = TransactionFinder.find_transactions( "2Mz84" )
      IO.inspect Enum.take( trans, 5 )
    end

  end
end
