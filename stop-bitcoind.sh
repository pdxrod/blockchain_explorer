ARG1=$1
if [[ "" == "$ARG1" ]] ; then
  ARG1="1"
fi

bitcoin-cli -rpcuser=USERNAME -rpcpassword=PASSWORD -rpcport=1659$ARG1 stop
