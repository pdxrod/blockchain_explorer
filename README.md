# Why Yet Another Blockchain Explorer?

There are many already out there. I wrote this blockchain
explorer to learn a. Elixir, b. Phoenix, and c. Blockchain

I couldn't have done it without https://github.com/pcorey/hello_blockchain
to get me started

13 August 2018 - tested with Elixir 1.7.2, Erlang/OTP 21

You need to be running bitcoind:
`start-bitcoind.sh regtest`
`start-bitcoind.sh testnet`
or
`start-bitcoind.sh mainnet`
(The last of these runs a full node, and uses a lot of disk space - 200 Gb and counting)
If you are using regtest, the most economical choice, wait a few seconds, then run
`regenerate.sh`
to generate some addresses and transactions

(For what regtest, testnet and mainnet mean, see
  https://dzone.com/articles/bitcoin-and-junit)

Before doing the above, you need to create bitcoin.conf in your ~/.bitcoin folder, with

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

On a Mac, your data is written in Library/Application Support/Bitcoin

You can turn it into a soft link pointing to a large (500 Gb+) external
drive - which you probably will have to do if using testnet or mainnet,
as the blockchain just keeps getting bigger
