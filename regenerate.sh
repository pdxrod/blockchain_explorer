if [[ "" == "$1" ]] ; then
  echo "This script is for sending coins in bitcoind in 'regtest' mode, when you need more than one instance."
  echo "It needs a parameter, a number corresponding to which config file you want to use."
  echo "For example, if you want to use $HOME/.bitcoin/bitcoin2.conf, do this:"
  echo "./regenerate.sh 2"
  exit 1
fi

bitcoin-cli -regtest -conf=$HOME/.bitcoin/bitcoin$1.conf -datadir=$HOME/.bitcoin/regtest$1 generate 101
echo Balance:
bitcoin-cli -regtest -conf=$HOME/.bitcoin/bitcoin$1.conf -datadir=$HOME/.bitcoin/regtest$1 getbalance
