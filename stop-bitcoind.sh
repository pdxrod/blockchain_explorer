if [[ "" == "$3" ]] ; then
  echo "Takes three arguments - rpc user name, rpc password, and port no. (e.g. 1, 2, 3...)"
  exit 1
fi

bitcoin-cli -rpcuser=$1 -rpcpassword=$2 -rpcport=1659$3 stop
