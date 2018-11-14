if [[ "$1" != "testnet" && "$1" != "regtest" && "$1" != "mainnet" ]] ; then
  echo "Run start-bitcoin.sh with argument 'testnet', 'regtest' or 'mainnet'"
  echo "For what this means, read https://dzone.com/articles/bitcoin-and-junit"
  exit 1
fi

if [[ "" == "$2" || "1" == "$2" ]] ; then
  bitcoind -daemon -$1 -conf=$HOME/.bitcoin/bitcoin1.conf
else
  bitcoind -daemon -$1 -conf=$HOME/.bitcoin/bitcoin$2.conf -datadir=$HOME/.bitcoin/regtest
fi
