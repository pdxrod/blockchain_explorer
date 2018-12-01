if [[ "" == "$1" ]] ; then
  echo "This script is for generating blocks in bitcoind in 'regtest' mode, when you need more than one instance."
  echo "It needs a parameter, a number corresponding to which config file and data floder you want to use."
  echo "For example, if you want to use data folder $HOME/.bitcoin/regtest2, do this:"
  echo "./regenerate.sh 2"
  exit 1
fi

RPCPORT=16591
if [[ "2" == "$1" ]] ; then
  RPCPORT=16593
fi

echo Generating blocks:
bitcoin-cli -regtest -conf=$HOME/.bitcoin/bitcoin$1.conf -rpcuser=USERNAME -rpcpassword=PASSWORD -datadir=$HOME/.bitcoin/regtest$1 -rpcport=$RPCPORT generate 201
echo Balance:
bitcoin-cli -regtest -conf=$HOME/.bitcoin/bitcoin$1.conf -rpcuser=USERNAME -rpcpassword=PASSWORD -datadir=$HOME/.bitcoin/regtest$1 -rpcport=$RPCPORT getbalance
