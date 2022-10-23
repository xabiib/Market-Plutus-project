#!/bin/bash

source .env
PROD_REDEEM=$ScrDir/Buy.json

COLLATERAL="6c477120351aa926519e5976653452cf3f74a0b6e5efa20a9e2b37f24cb5657e#0"
FEEUTXO="8f657298c16abfbe4581c41d1c06df5ed71e671b57e034f0ee1d7a935a3c23c6#1"
SCR_UTXO1="5648fce472e3a2b00d03940545065dc8544f5d25f32cab42d71f79cc8ad0d668#1"
SCR_UTXO2="be6f1f0d287d6e20387177ec1faefb4f6bc1d1429ffe74e56d138aa26a3a80e2#1"

LOVELACE=5400011
echo "Building Tx ..."
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
