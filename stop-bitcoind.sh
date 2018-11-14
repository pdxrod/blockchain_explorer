if [[ "" == "$1" ]] ; then
  bitcoin-cli -conf=$HOME/.bitcoin/bitcoin1.conf stop
else
  bitcoin-cli -conf=$HOME/.bitcoin/bitcoin$1.conf stop
fi
