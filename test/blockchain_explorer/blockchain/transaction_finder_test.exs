defmodule BlockChainExplorer.TransactionFinderTest do
  use BlockChainExplorerWeb.ConnCase
  alias BlockChainExplorer.Blockchain
  alias BlockChainExplorer.TransactionFinder

  describe "transaction finder test" do

    test "find" do
      IO.puts "\ntransaction finder test"
      IO.inspect TransactionFinder.find_transactions( "mh2e7YH" )
    end

  end
end
