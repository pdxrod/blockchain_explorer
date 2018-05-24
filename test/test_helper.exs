ExUnit.start()
pair = System.cmd "ps", ["auxw"]
strs = elem( pair, 0 )
bitcoind_running = strs =~ ~r/bitcoind/
if ! bitcoind_running, do: raise "\nThe tests depend on bitcoind running - see start-bitcoind.sh\nto start bitcoind in test mode\n"
