if [[ "" == "$1" ]] ; then
  echo "This script is primarily for running bitcoind in 'regtest' mode, when you need more than"
  echo "one instance. It needs a parameter, a number corresponding to which config file you need."
  echo "For example, if you want to use $HOME/.bitcoin/bitcoin2.conf, do this:"
  echo "./regenerate.sh 2"
  exit 1
fi

bitcoin-cli -regtest -conf=$HOME/.bitcoin/bitcoin$1.conf generate 42
if [[ "1" != "$1" ]] ; then
  bitcoin-cli -regtest -conf=$HOME/.bitcoin/bitcoin$1.conf -datadir=$HOME/.bitcoin/regtest generate 11
fi
