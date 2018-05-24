# BlockchainExplorer

Based on https://github.com/pcorey/hello_blockchain

You need to be running bitcoind (probably in test mode - see start-bitcoind.sh)

You need to create bitcoin.conf in your ~/.bitcoin folder, with

rpcuser=USERNAME

rpcpassword=PASSWORD

and the user name and password should be in config.exs

See https://github.com/bitcoin/bitcoin

See startup.txt for installation on Linux

To start Phoenix:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets` then
  * `npm install`
  * `cd ..`
  * Start Phoenix with `mix phx.server`

Now visit [`localhost:4000`](http://localhost:4000) in a browser
