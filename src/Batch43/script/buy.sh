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

#DIR="output/$WALLET"
DIR="/home/habib/Src/temp/buyer"
MY_ADDR=$(cat $DIR/payment.addr)
CHANGE_ADDR=$MY_ADDR
COLLATERAL="6c477120351aa926519e5976653452cf3f74a0b6e5efa20a9e2b37f24cb5657e#0"
FEEUTXO="8f657298c16abfbe4581c41d1c06df5ed71e671b57e034f0ee1d7a935a3c23c6#1"
##MY_UTXO="d459e3d48aa35633ba1682d9d5645f361f1857c43f4df0540b274add52e7b85c#1"
SCR_UTXO1="5648fce472e3a2b00d03940545065dc8544f5d25f32cab42d71f79cc8ad0d668#1"
SCR_UTXO2="be6f1f0d287d6e20387177ec1faefb4f6bc1d1429ffe74e56d138aa26a3a80e2#1"

LOVELACE=5400011
echo "Building Tx ..."
## Build tx from address
#echo "MY_UTXO Tx . $MY_UTXO"
#set -xe
cardano-cli transaction build \
  --babbage-era \
  --tx-in $SCR_UTXO1 \
  --tx-in-script-file $PROD_PLUTUS_SCRIPT \
  --tx-in-datum-file $PROD_DATUM \
  --tx-in-redeemer-file $PROD_REDEEM \
  --tx-in $SCR_UTXO2 \
  --tx-in-script-file $PROD_PLUTUS_SCRIPT \
  --tx-in-datum-file $PROD_DATUM \
  --tx-in-redeemer-file $PROD_REDEEM \
  --tx-in $FEEUTXO \
  --tx-in-collateral $COLLATERAL \
  --required-signer-hash fda70fa96b27387dd3455f458f7b9b7ba664ec5cb2fe39739603c67b \
  --tx-out $SELLER_ADDR+$AMOUNT \
  --tx-out $BUYER_ADDR+"1400000 + 1 ec03ca961e28b4345a382f03ffb925a9561abda609526dbcbb24d771.4261746368343370" \
  --change-address $BUYER_ADDR\
    $NETWORK  \
  --protocol-params-file /home/habib/Src/plutus/project/src/protocol.json \
  --out-file $OUTPUT_DIR/tx-buy-accept.build
echo "Done."

# Sign tx
echo "Sign Tx ..."
cardano-cli transaction sign \
--signing-key-file $WALLETS/buyer/payment.skey \
--tx-body-file $OUTPUT_DIR/tx-buy-accept.build \
--out-file $OUTPUT_DIR/tx-buy-accept.sign
echo "Done."

# Submit tx
echo "Submiting Tx ..."
cardano-cli transaction submit $NETWORK --tx-file $OUTPUT_DIR/tx-buy-accept.sign

sleep 30
cardano-cli query utxo $NETWORK --address $SCRIPT_ADDR
#./balance-addr.sh $SCRIPT_ADDR 
