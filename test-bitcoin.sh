if [[ "" == "$3" ]] ; then
    echo "Takes three arguments: 1. rpc user name, 2. rpc password - see config/config.exs"
    echo "The third argument is 'regtest', 'testnet' or 'mainnet' - see README.md "
    exit 1
fi

echo ""
echo "Getting blockchain info"
echo curl  --user $1:$2 --data-binary '{"jsonrpc":"1.0","method":"getblockchaininfo","params":[]}' http://localhost:16592
echo ""
curl  --user $1:$2 --data-binary '{"jsonrpc":"1.0","method":"getblockchaininfo","params":[]}' http://localhost:16592
echo ""
echo curl --data-binary '{"jsonrpc":"1.0","method":"getblockchaininfo","params":[]}' http://$1:$2@localhost:16592
echo ""
curl --data-binary '{"jsonrpc":"1.0","method":"getblockchaininfo","params":[]}' http://$1:$2@localhost:16592
echo ""
echo "Getting new address and private key"
echo "  bitcoin-cli getnewaddress"
address=`bitcoin-cli -$3 -conf=$HOME/.bitcoin/bitcoin1.conf -rpcuser=$1 -rpcpassword=$2 -datadir=$HOME/.bitcoin/regtest1 -rpcport=16592 getnewaddress`
echo Address $address
echo "  bitcoin-cli dumpprivkey $address"
key=`bitcoin-cli -$3 -conf=$HOME/.bitcoin/bitcoin1.conf -rpcuser=$1 -rpcpassword=$2 -datadir=$HOME/.bitcoin/regtest1 -rpcport=16592 dumpprivkey $address`
echo Private Key $key
