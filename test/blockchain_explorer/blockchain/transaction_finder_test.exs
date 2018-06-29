defmodule BlockChainExplorer.TransactionFinderTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Utils
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.TransactionFinder

  describe "transaction finder test" do

    test "find" do
      IO.puts "\ntransaction finder test"
      trans = TransactionFinder.find_transactions( "mh2e7YH" )
      Utils.typeof trans
    end

  end
end
