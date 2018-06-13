defmodule BlockChainExplorer.Block do
  alias BlockChainExplorer.Blockchain

  defstruct weight: "", versionhex: "", version: 0, tx: [],
	    time: 0, strippedsize: 0, size: 0, previousblockhash: "",
	    nonce: 0, nextblockhash: "", merkleroot: "", mediantime: 0,
	    height: 0, hash: "", difficulty: 0.0, confirmations: 0,
	    chainwork: "", bits: ""

  def decode_block( block ) do
    %BlockChainExplorer.Block{
      weight: block[ "weight" ], versionhex: block[ "versionHex" ],
      version: block[ "version" ], tx: block[ "tx" ],
      time: block[ "time" ], strippedsize: block[ "strippedsize" ],
      size: block[ "size" ], previousblockhash: block[ "previousblockhash" ],
      nonce: block[ "nonce" ], nextblockhash: block[ "nextblockhash" ],
      merkleroot: block[ "merkleroot" ], mediantime: block[ "mediantime" ],
      height: block[ "height" ], hash: block[ "hash" ], difficulty: block[ "difficulty" ],
      confirmations: block[ "confirmations" ], chainwork: block[ "chainwork" ], bits: block[ "bits" ] }
  end
end
