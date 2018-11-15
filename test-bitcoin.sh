if [[ "" == "$3" ]] ; then
    echo "Takes three arguments. rpc user name and rpc password should be set in $HOME/.bitcoin/bitcoin1.conf"
    echo "The third argument is 'regtest', 'testnet' or 'mainnet' - see README.md "
    exit 1
fi

echo ""
echo "Getting blockchain info"
echo curl  --user $1:$2 --data-binary '{"jsonrpc":"1.0","method":"getblockchaininfo","params":[]}' http://localhost:18333
echo ""
curl  --user $1:$2 --data-binary '{"jsonrpc":"1.0","method":"getblockchaininfo","params":[]}' http://localhost:18333
echo ""
echo curl --data-binary '{"jsonrpc":"1.0","method":"getblockchaininfo","params":[]}' http://$1:$2@localhost:18333
echo ""
curl --data-binary '{"jsonrpc":"1.0","method":"getblockchaininfo","params":[]}' http://$1:$2@localhost:18333
echo ""
echo "Getting new address and private key"
echo bitcoin-cli -$3 -conf=$HOME/.bitcoin/bitcoin1.conf getnewaddress
address=`bitcoin-cli -$3 -conf=$HOME/.bitcoin/bitcoin1.conf getnewaddress`
echo Address $address
echo bitcoin-cli -$3 -conf=$HOME/.bitcoin/bitcoin1.conf dumpprivkey $address
key=`bitcoin-cli -$3 -conf=$HOME/.bitcoin/bitcoin1.conf dumpprivkey $address`
echo Private Key $key
