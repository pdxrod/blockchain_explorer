ExUnit.start()
pair = System.cmd "ps", ["auxw"]
strs = elem( pair, 0 )
bitcoind_running = strs =~ ~r/bitcoind/
if ! bitcoind_running do
  raise "\n\nThe tests depend on bitcoind running - see start-bitcoind.sh\nto start bitcoind in test mode, and wait a couple of minutes\n"
else
  IO.puts "\n*** These tests are slow, because they make thousands of RPC requests to bitcoind ***\n"
end
