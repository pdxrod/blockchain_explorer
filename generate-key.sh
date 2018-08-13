address=`bitcoin-cli -testnet -conf=$HOME/.bitcoin/bitcoin.conf getnewaddress`
echo Address $address
key=`bitcoin-cli -testnet -conf=$HOME/.bitcoin/bitcoin.conf dumpprivkey $address`
echo Private Key $key

