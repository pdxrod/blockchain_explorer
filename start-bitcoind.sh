if [[ "$1" != "testnet" && "$1" != "regtest" && "$1" != "mainnet" ]] ; then
  echo "Run start-bitcoind.sh with argument 'testnet', 'regtest' or 'mainnet'"
  echo "For what this means, read https://dzone.com/articles/bitcoin-and-junit"
  exit 1
fi

if [[ "" == "$4" ]] ; then
  echo "Takes four arguments: 1. testnet, regtest or mainnet, 2. port number (starting with 1),"
  echo "3. rpc user name, 4. rpc password - see config/config.exs"
  echo "The first argument is 'regtest', 'testnet' or 'mainnet' - see README.md "
  exit 1
fi

ARG2=$2
PORT=1759$ARG2
RPCPORT=1659$ARG2
ARG3=$(( $ARG2+1 ))
if [[ "regtest" == "$1" ]] ; then
  CONNECT=localhost:1759$ARG3
  DATADIR=$HOME/.bitcoin/regtest$ARG2
  if [[ ! -d $DATADIR ]] ; then
    mkdir -p $DATADIR
  fi
  bitcoind -server -listen -port=$PORT -rpcuser=$3 -rpcpassword=$4 -rpcport=$RPCPORT -datadir=$DATADIR -connect=$CONNECT -regtest -daemon
else
  bitcoind -server -listen -port=$PORT -rpcuser=$3 -rpcpassword=$4 -rpcport=$RPCPORT -$1 -daemon
fi
