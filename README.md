# Why Yet Another Blockchain Explorer?

There are many already out there. I wrote this blockchain
explorer to learn Elixir, Phoenix, and Blockchain.

I couldn't have done it without https://github.com/pcorey/hello_blockchain

3 December 2018 - tested with Elixir 1.7.2, Erlang/OTP 21 and bitcoind version 0.15.99.0

You need to be running bitcoind:

`start-bitcoind.sh regtest` (twice)

`start-bitcoind.sh testnet`

or

`start-bitcoind.sh mainnet`

(The last of these runs a full node, and uses a lot of disk space - 200 Gb and counting)

If you are using `regtest`, the most economical choice, wait a few seconds, then run

`regenerate.sh`

to generate some blocks

For what regtest, testnet and mainnet mean, see
[https://dzone.com/articles/bitcoin-and-junit](https://dzone.com/articles/bitcoin-and-junit)

You need to change 'rpcuser' and 'rpcpass' in config/config.exs to whatever you give as username/password arguments to the scripts

# regtest mode

To do anything useful in regtest mode, you need at least two instances of bitcoind running

Create a .bitcoin/ folder in your home directory

Start the first instance like this

`start-bitcoind.sh regtest 1`

and the second like this

`start-bitcoind.sh regtest 2`

# further information

See https://github.com/bitcoin/bitcoin

See `ubuntu-install.txt` for installation on Linux

To start Phoenix:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets` then
  * `npm install`
  * `./node_modules/brunch/bin/brunch build`
  * `cd ..`
  * Start Phoenix with `mix phx.server`

Now visit [`localhost:4000`](http://localhost:4000) in a browser

On a Mac, your data is written in Library/Application Support/Bitcoin,
unless you've specified a datadir (see start-bitcoind.sh)

You can turn it into a soft link pointing to a large (500 Gb+) external
drive - which you probably will have to do if using testnet or mainnet,
as the blockchain just keeps getting bigger. And this blockchain explorer
keeps getting slower, causing tests to time out. A real production version
would use a database, inserting each new block as its minted. Since the number
of blocks is only in the millions, finding addresses etc. would be very fast.
