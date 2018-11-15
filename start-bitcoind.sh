if [[ "$1" != "testnet" && "$1" != "regtest" && "$1" != "mainnet" ]] ; then
  echo "Run start-bitcoin.sh with argument 'testnet', 'regtest' or 'mainnet'"
  echo "For what this means, read https://dzone.com/articles/bitcoin-and-junit"
  exit 1
fi

if [[ "regtest" == "$1" ]] ; then
  if [[ "" == "$2" || "1" == "$2" ]] ; then
    if [[ ! -d $HOME/.bitcoin/regtest1 ]] ; then
      mkdir $HOME/.bitcoin/regtest1
    fi
    bitcoind -daemon -$1 -conf=$HOME/.bitcoin/bitcoin1.conf -datadir=$HOME/.bitcoin/regtest1
  else
    if [[ ! -d $HOME/.bitcoin/regtest$2 ]] ; then
      mkdir $HOME/.bitcoin/regtest$2
    fi
    bitcoind -daemon -$1 -conf=$HOME/.bitcoin/bitcoin$2.conf -datadir=$HOME/.bitcoin/regtest$2
  fi
else
  bitcoind -daemon -$1 -conf=$HOME/.bitcoin/bitcoin1.conf
fi
