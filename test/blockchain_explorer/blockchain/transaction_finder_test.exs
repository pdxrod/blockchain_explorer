defmodule BlockChainExplorer.TransactionFinderTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.TransactionFinder

  describe "transaction finder test" do

    test "find" do
      TransactionFinder.find_transactions( "mke3" )
    end

  end
end
