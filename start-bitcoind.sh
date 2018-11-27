if [[ "$1" != "testnet" && "$1" != "regtest" && "$1" != "mainnet" ]] ; then
  echo "Run start-bitcoin.sh with argument 'testnet', 'regtest' or 'mainnet'"
  echo "For what this means, read https://dzone.com/articles/bitcoin-and-junit"
  exit 1
fi

if [[ "regtest" == "$1" ]] ; then
  if [[ "" != "$2" && "1" != "$2" && "2" != "$2" ]] ; then
    echo "If you want to start bitcoind in regtest mode with '$2' as its argument"
    echo "you can't use this script to do it. Read it and work out what port to use."
    exit 1
  fi
  RPCPORT=16592
  if [[ "2" == "$2" ]] ; then
    RPCPORT=16593
  fi
  if [[ "" == "$2" || "1" == "$2" ]] ; then
    if [[ ! -d $HOME/.bitcoin/regtest1 ]] ; then
      mkdir $HOME/.bitcoin/regtest1
    fi
    bitcoind -server -listen -conf=$HOME/.bitcoin/bitcoin1.conf -port=17592 -rpcuser=USERNAME -rpcpassword=PASSWORD -rpcport=$RPCPORT -datadir=$HOME/.bitcoin/regtest1 -connect=localhost:17593 -regtest -daemon
  else
    if [[ ! -d $HOME/.bitcoin/regtest$2 ]] ; then
      mkdir $HOME/.bitcoin/regtest$2
    fi
    bitcoind -server -listen -conf=$HOME/.bitcoin/bitcoin$2.conf -port=17593 -rpcuser=USERNAME -rpcpassword=PASSWORD -rpcport=$RPCPORT -datadir=$HOME/.bitcoin/regtest$2 -connect=localhost:17592 -regtest -daemon
  fi
else
  bitcoind -server -listen -conf=$HOME/.bitcoin/bitcoin1.conf -port=17592 -rpcuser=USERNAME -rpcpassword=PASSWORD -rpcport=16592 -$1 -daemon
fi
