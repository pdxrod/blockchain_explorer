if [[ "$1" != "testnet" && "$1" != "regtest" && "$1" != "mainnet" ]] ; then
  echo "Run start-bitcoind.sh with argument 'testnet', 'regtest' or 'mainnet'"
  echo "For what this means, read https://dzone.com/articles/bitcoin-and-junit"
  exit 1
fi

if [[ "regtest" == "$1" ]] ; then
  ARG2=$2
  if [[ "" == "$ARG2" ]] ; then
    ARG2="1"
  fi
  RPCPORT=1659$ARG2
  ARG3=$(( $ARG2+1 ))
  CONNECT=localhost:1759$ARG2
  PORT=1759$ARG3
  DATADIR=$HOME/.bitcoin/regtest$ARG2
  if [[ ! -d $DATADIR ]] ; then
    mkdir -p $DATADIR
  fi
  bitcoind -server -listen -port=$PORT -rpcuser=USERNAME -rpcpassword=PASSWORD -rpcport=$RPCPORT -datadir=$DATADIR -connect=$CONNECT -regtest -daemon
else
  bitcoind -server -listen -port=17592 -rpcuser=USERNAME -rpcpassword=PASSWORD -rpcport=16591 -$1 -daemon
fi
