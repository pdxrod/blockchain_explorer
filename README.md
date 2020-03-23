# Why Yet Another Blockchain Explorer?

There are many already out there. I wrote this blockchain
explorer to learn Elixir, Phoenix, and Blockchain.

I couldn't have done it without [github.com/pcorey/hello_blockchain](https://github.com/pcorey/hello_blockchain)

It can be seen running at [http://subcryption.com/](http://subcryption.com/)

23 March 2020 - tested with Elixir 1.10, Erlang/OTP 22 and bitcoind version v0.19.99.0-97b068750

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

`start-bitcoind.sh regtest USERNAME PASSWORD 1`

and the second like this

`start-bitcoind.sh regtest USERNAME PASSWORD 2`

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

On a Mac, your data is written in ~/Library/Application Support/Bitcoin,
unless you've specified a datadir (see start-bitcoind.sh). On Linux, ~/.bitcoin.

You can turn it into a soft link pointing to a large (500 Gb+) external
drive - which you probably will have to do if using testnet or mainnet,
as the blockchain just keeps getting bigger.

# production

To run this app in production mode, look at `start-phoenix-in-background.sh`

You need to enter a 'secret key base' and a mysql username and password in config/prod.exs. DO NOT
check this file into Git after you've changed it, as it contains critical production data -
do `git reset --hard` to undo your changes to prod.exs.

`mix phx.gen.secret` will generate a new 'secret key base'.
