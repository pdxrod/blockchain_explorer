if [[ "" == "$3" ]] ; then
    echo "Takes three arguments: 1. rpc user name, 2. rpc password, 3. port (1, 2, 3 etc.)"
    echo "- see config/config.exs"
    exit 1
fi

echo ""
echo "Getting blockchain info"
echo curl  --user $1:$2 --data-binary '{"jsonrpc":"1.0","method":"getblockchaininfo","params":[]}' http://localhost:16591
echo ""
curl  --user $1:$2 --data-binary '{"jsonrpc":"1.0","method":"getblockchaininfo","params":[]}' http://localhost:16591
echo ""
echo curl --data-binary '{"jsonrpc":"1.0","method":"getblockchaininfo","params":[]}' http://$1:$2@localhost:16591
echo ""
curl --data-binary '{"jsonrpc":"1.0","method":"getblockchaininfo","params":[]}' http://$1:$2@localhost:16591
echo ""
echo "Getting new address and private key"
echo "  bitcoin-cli getnewaddress"
address=`bitcoin-cli -rpcuser=$1 -rpcpassword=$2 -datadir=$HOME/.bitcoin/regtest1 -rpcport=1659$3 getnewaddress`
echo Address $address
echo "  bitcoin-cli dumpprivkey $address"
key=`bitcoin-cli -rpcuser=$1 -rpcpassword=$2 -datadir=$HOME/.bitcoin/regtest1 -rpcport=1659$3 dumpprivkey $address`
echo Private Key $key
