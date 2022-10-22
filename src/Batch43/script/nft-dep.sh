#!/bin/bash

SELLER_PKHS="5bc0f9ecd2c7bce3057a218a5c34c989fa549d3a3b4ebaf600b1890e"
BUYER_PKHS="fda70fa96b27387dd3455f458f7b9b7ba664ec5cb2fe39739603c67b"
MEDIATOR_PKHS="a34ac4d4e1b6e0c711652026cc6c754d0b08fb69ab5ae1adc6974b41"
SCRIPT_ADDR="addr_test1wrsagdlkxedjlzr0nlae7ft97xctncg8d3fly8utut6567qlyxyf7"
DATUM_HASH="ef5a2167cf9da48c2d7025e83e13f2d3e69876ca3a538038c1e9d8b8829b8ec0"
AMOUNT=10000000
WALLETS="/home/habib/Src/temp"
OUTPUT_DIR="/home/habib/Src/plutus/project/src/temp/txns"
BUYER_ADDR=$(cat $WALLETS/buyer/payment.addr)
SELLER_ADDR=$(cat $WALLETS/seller/payment.addr)
MEDIATOR_ADDR=$(cat $WALLETS/mediator/payment.addr)

ScrDir="/home/habib/Src/plutus/project/src/temp/input"

PROD_PLUTUS_SCRIPT=$ScrDir/ProdValidator.plutus
PROD_DATUM=$ScrDir/ProdDatum.json
PROD_REDEEM=$ScrDir/Buy.json


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
