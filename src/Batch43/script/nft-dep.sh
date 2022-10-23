#!/bin/bash

source .env


COLLATERAL="a5e56b48be74da77496691faed3f30b96672b2a95ebc767b5e33ac0d5fe073b8#1"
NFT_UTXO="d0ff112f85b16de7100be03a5383238c444de539fdec90097a9112a29a04c6f9#1"
LOVELACE=1300000
echo "Building Tx ..."
## Build tx from address
echo "MY_UTXO Tx . $MY_UTXO"
set -xe
cardano-cli transaction build \
  --babbage-era \
  --tx-in $NFT_UTXO \
  --tx-in "0dfb883704ba69762e437dd18788879906d6f58d361688e018cab52cd89b66ae#0" \
  --tx-out-datum-hash $DATUM_HASH \
  --tx-in-collateral $COLLATERAL \
  --tx-out $SCRIPT_ADDR+"1400000 + 1 ec03ca961e28b4345a382f03ffb925a9561abda609526dbcbb24d771.4261746368343370" \
  --change-address $SELLER_ADDR \
  $NETWORK \
  --protocol-params-file /home/habib/Src/plutus/project/src/protocol.json \
  --out-file $OUTPUT_DIR/tx-deposit-accept.build
echo "Done."

echo "Sign Tx ..."
cardano-cli transaction sign \
--signing-key-file $WALLETS/seller/payment.skey \
--tx-body-file $OUTPUT_DIR/tx-deposit-accept.build \
--out-file $OUTPUT_DIR/tx-deposit-accept.sign
echo "Done."

# Submit tx
echo "Submiting Tx ..."
cardano-cli transaction submit $NETWORK --tx-file $OUTPUT_DIR/tx-deposit-accept.sign

sleep 30
cardano-cli query utxo $NETWORK --address $SCRIPT_ADDR
#./balance-addr.sh $SCRIPT_ADDR 
