
bitcoin-cli -regtest -conf=$HOME/.bitcoin/bitcoin.conf generate 111 > blocks.txt
for block in `cut -c4-67 blocks.txt` ; do
  echo "Block $block"
  bitcoin-cli -regtest -conf=$HOME/.bitcoin/bitcoin.conf getblock $block
# Get transactions out of the block, and get addresses out of the transactions
  # small_number=$(( ( RANDOM % 10 ) + 1 ))
  # echo "Sending $small_number to $address"
  # bitcoin-cli -regtest -conf=$HOME/.bitcoin/bitcoin.conf sendtoaddress $address $small_number
done
