# Why Yet Another Blockchain Explorer?

There are many already out there. I wrote this blockchain
explorer to learn a. Elixir, b. Phoenix, and c. Blockchain.

I couldn't have done it without https://github.com/pcorey/hello_blockchain
to get me started.

13 August 2018 - tested with Elixir 1.7.2, Erlang/OTP 21.

You need to be running bitcoind (probably in test mode - see start-bitcoind.sh)

You need to create bitcoin.conf in your ~/.bitcoin folder, with

rpcuser=USERNAME

rpcpassword=PASSWORD

and the user name and password should be in config.exs

See https://github.com/bitcoin/bitcoin

See `startup.txt` for installation on Linux

To start Phoenix:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets` then
  * `npm install`
  * `./node_modules/brunch/bin/brunch build`
  * `cd ..`
  * Start Phoenix with `mix phx.server`

Now visit [`localhost:4000`](http://localhost:4000) in a browser
