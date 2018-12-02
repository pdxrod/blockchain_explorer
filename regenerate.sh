if [[ "" == "$3" ]] ; then
  echo "This script is for generating blocks in bitcoind in 'regtest' mode, when you need more than one instance."
  echo "It takes three arguments: 1. user name, 2. rpc password, 3. port number (1, 2, 3 etc.)"
  echo "For example, if you want to use data folder $HOME/.bitcoin/regtest2, do this:"
  echo "./regenerate.sh USERNAME PASSWORD 2"
  exit 1
fi

RPCPORT=1659$3
echo Generating blocks:
bitcoin-cli -regtest -rpcuser=$1 -rpcpassword=$2 -datadir=$HOME/.bitcoin/regtest$3 -rpcport=$RPCPORT generate 201
echo Balance:
bitcoin-cli -regtest -rpcuser=$1 -rpcpassword=$2 -datadir=$HOME/.bitcoin/regtest$3 -rpcport=$RPCPORT getbalance
