if [[ "" == "$1" || "1" == "$1" ]] ; then
  bitcoin-cli -conf=$HOME/.bitcoin/bitcoin1.conf -rpcuser=USERNAME -rpcpassword=PASSWORD -rpcport=16592 stop
else
  bitcoin-cli -conf=$HOME/.bitcoin/bitcoin$1.conf -rpcuser=USERNAME -rpcpassword=PASSWORD -rpcport=16593 stop
fi
