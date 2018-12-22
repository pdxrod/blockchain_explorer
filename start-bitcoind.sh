if [[ ("$1" != "testnet" && "$1" != "regtest" && "$1" != "mainnet") || ("$3" == "") || ("$1" == "regtest" && "" == "$4") ]] ; then
  echo "Takes four arguments: 1. testnet, regtest or mainnet, 2. rpc user name,"
  echo "3. rpc password - see config/config.exs, 4. port number (1, 2, 3 etc.)"
  echo "'testnet', 'regtest' and 'mainnet':"
  echo "for what these mean, read https://dzone.com/articles/bitcoin-and-junit"
  exit 1
fi

ARG4=$4
PORT=1759$ARG4
RPCPORT=1659$ARG4
ARG5=$(( $ARG4+1 ))
if [[ "regtest" == "$1" ]] ; then
  CONNECT=localhost:1759$ARG5
  DATADIR=$HOME/.bitcoin/regtest$ARG4
  if [[ ! -d $DATADIR ]] ; then
    mkdir -p $DATADIR
  fi
  bitcoind -server -listen -port=$PORT -rpcuser=$2 -rpcpassword=$3 -rpcport=$RPCPORT -datadir=$DATADIR -connect=$CONNECT -regtest -daemon
else
  bitcoind -server -listen -port=17591 -rpcuser=$2 -rpcpassword=$3 -rpcport=16591 -$1 -daemon 
fi
