#!/bin/bash

#source .env
NETWORK="--testnet-magic 1"
CARDANO_CLI_PATH=cardano-cli
SELLER_ADDR="addr_test1qpk87vtecwfxacsqls30u8zmrc3ck2wnnrt2vx773cwp8htgj5gmm8yzyd786p3yc6s3994dsut3utvkheam07m7qasqec3zsh"
BUYER_ADDR="addr_test1qpp7lglltt5z4r8vs8d5a5ue5knee8xy0mnw0tsycuk4unmh54e2pcnk9mjpzrzs38u2kfwycdku52l8t0fhum2xyvxs4dg6td"
AMOUNT=10000000

ScrDir="/home/habib/newDev/projects/batch43/src/Batch43/input"
PROD_PLUTUS_SCRIPT=$ScrDir/ProdValidator.plutus
PROD_DATUM=$ScrDir/ProdDatum.json
PROD_REDEEM=$ScrDir/Buy.json
SCRIPT_ADDR="addr_test1wp89qhw7t5hgj8ajmslx5wcqeh6yptdn23a5r75k5juy3ws70vddf"
DATUM_HASH="88b09de4aa066a23fc851b0b832ff0ffce906ab3614b34a7af2d4c8486e8d39c"

#DIR="output/$WALLET"
DIR="/home/habib/newDev/projects/batch43/src/Batch43/wallets/mediator"
MY_ADDR=$(cat $DIR/payment.addr)
CHANGE_ADDR=$MY_ADDR
COLLATERAL="43a0b467be4014793489cfc426bdd5c030816c5bd1077898f06b1abb1fd1edf9#1"
FEEUTXO="d459e3d48aa35633ba1682d9d5645f361f1857c43f4df0540b274add52e7b85c#2"
##MY_UTXO="d459e3d48aa35633ba1682d9d5645f361f1857c43f4df0540b274add52e7b85c#1"
SCR_UTXO1="19587feb71e9099015635f2dcefddfb8ed8485a8bfbb9278cad51a405fcdf505#1"
SCR_UTXO2="c046a22dc94519b9ff22d6c83ad8bcf8415cdafee3bb0874ae229464c225347a#1"

LOVELACE=5400011
echo "Building Tx ..."
## Build tx from address
#echo "MY_UTXO Tx . $MY_UTXO"
#set -xe
${CARDANO_CLI_PATH} transaction build \
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
  --required-signer-hash 5b714621783376d3fbbacf609136ceabd0900660125232a0a8636fef \
  --tx-out $BUYER_ADDR+$AMOUNT \
  --tx-out $SELLER_ADDR+"1300000 + 1 38f2e890c8803fc0740848c2b296a11a667e817880e3d16184194ba2.4261746368343370" \
  --change-address $CHANGE_ADDR \
  --testnet-magic 1  \
  --protocol-params-file /home/habib/newDev/projects/batch43/src/protocol.json \
  --out-file Batch43/txfiles/tx-mediator-accept.build
echo "Done."

echo "Sign Tx ..."
${CARDANO_CLI_PATH} transaction sign \
--signing-key-file $DIR/payment.skey \
--tx-body-file Batch43/txfiles/tx-mediator-accept.build \
--out-file Batch43/txfiles/tx-mediator-accept.sign
echo "Done."

# Submit tx
echo "Submiting Tx ..."
${CARDANO_CLI_PATH} transaction submit $NETWORK --tx-file Batch43/txfiles/tx-mediator-accept.sign

sleep 30
${CARDANO_CLI_PATH} query utxo $NETWORK --address $SCRIPT_ADDR
#./balance-addr.sh $SCRIPT_ADDR 
