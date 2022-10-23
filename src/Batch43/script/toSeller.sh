#!/bin/bash

source .env
PROD_REDEEM=$ScrDir/toSeller.json

COLLATERAL="43a0b467be4014793489cfc426bdd5c030816c5bd1077898f06b1abb1fd1edf9#1"
FEEUTXO="d459e3d48aa35633ba1682d9d5645f361f1857c43f4df0540b274add52e7b85c#2"
##MY_UTXO="d459e3d48aa35633ba1682d9d5645f361f1857c43f4df0540b274add52e7b85c#1"
SCR_UTXO1="19587feb71e9099015635f2dcefddfb8ed8485a8bfbb9278cad51a405fcdf505#1"
SCR_UTXO2="c046a22dc94519b9ff22d6c83ad8bcf8415cdafee3bb0874ae229464c225347a#1"
SCR_UTXO3=""

LOVELACE=5400011
echo "Building Tx ..."
cardano-cli  transaction build \
  --babbage-era \
  --tx-in $SCR_UTXO1 \
  --tx-in-script-file $PROD_PLUTUS_SCRIPT \
  --tx-in-datum-file $PROD_DATUM \
  --tx-in-redeemer-file $PROD_REDEEM \
  --tx-in $SCR_UTXO2 \
  --tx-in-script-file $PROD_PLUTUS_SCRIPT \
  --tx-in-datum-file $PROD_DATUM \
  --tx-in-redeemer-file $PROD_REDEEM \
  --tx-in $SCR_UTXO3 \
  --tx-in-script-file $PROD_PLUTUS_SCRIPT \
  --tx-in-datum-file $PROD_DATUM \
  --tx-in-redeemer-file $PROD_REDEEM \
  --tx-in $FEEUTXO \
  --tx-in-collateral $COLLATERAL \
  --required-signer-hash 5b714621783376d3fbbacf609136ceabd0900660125232a0a8636fef \
  --tx-out $SELLER_ADDR+$AMOUNT \
  --tx-out $BUYER_ADDR+"1300000 + 1 38f2e890c8803fc0740848c2b296a11a667e817880e3d16184194ba2.4261746368343370" \
  --tx-out $MEDIATOR_ADDR+$ADISPUTE_FEE \
  --change-address $MEDIATOR_ADDR \
  --testnet-magic 1  \
  --protocol-params-file /home/habib/newDev/projects/batch43/src/protocol.json \
  --out-file $OUTPUT_DIR/tx-mediator-accept.build
echo "Done."

echo "Sign Tx ..."
cardano-cli  transaction sign \
--signing-key-file $DIR/payment.skey \
--tx-body-file $OUTPUT_DIR/tx-mediator-accept.build \
--out-file $OUTPUT_DIR/tx-mediator-accept.sign
echo "Done."

# Submit tx
echo "Submiting Tx ..."
cardano-cli  transaction submit $NETWORK --tx-file $OUTPUT_DIR/tx-mediator-accept.sign

sleep 30
${CARDANO_CLI_PATH} query utxo $NETWORK --address $SCRIPT_ADDR