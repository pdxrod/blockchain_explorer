ExUnit.start()
pair = System.cmd "ps", ["auxw"]
strs = elem( pair, 0 )
bitcoind_running = strs =~ ~r/bitcoind/
if bitcoind_running do
  IO.puts "\n*** These tests are slow, because they make thousands of RPC requests to bitcoind ***\n"
else
  raise "\n\nThe tests depend on bitcoind running - see start-bitcoind.sh\nto start bitcoind, and wait a few minutes\n"
end
