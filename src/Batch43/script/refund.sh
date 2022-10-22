#!/bin/bash

#source .env
NETWORK="--testnet-magic 1"
CARDANO_CLI_PATH=cardano-cli
#SELLER_ADDR="addr_test1qpk87vtecwfxacsqls30u8zmrc3ck2wnnrt2vx773cwp8htgj5gmm8yzyd786p3yc6s3994dsut3utvkheam07m7qasqec3zsh"
BUYER_ADDR="addr_test1qpp7lglltt5z4r8vs8d5a5ue5knee8xy0mnw0tsycuk4unmh54e2pcnk9mjpzrzs38u2kfwycdku52l8t0fhum2xyvxs4dg6td"
AMOUNT=10000000

ScrDir="/home/habib/newDev/projects/batch43/src/Batch43/input"
PROD_PLUTUS_SCRIPT=$ScrDir/ProdValidator.plutus
PROD_DATUM=$ScrDir/ProdDatum.json
PROD_REDEEM=$ScrDir/refund.json
SCRIPT_ADDR="addr_test1wp89qhw7t5hgj8ajmslx5wcqeh6yptdn23a5r75k5juy3ws70vddf"
DATUM_HASH="88b09de4aa066a23fc851b0b832ff0ffce906ab3614b34a7af2d4c8486e8d39c"

#DIR="output/$WALLET"
DIR="/home/habib/newDev/projects/batch43/src/Batch43/wallets/seller"
MY_ADDR=$(cat $DIR/payment.addr)
CHANGE_ADDR=$MY_ADDR
COLLATERAL="2f0818749d109505317af09016c2773c52643c63c800ea656000b8fe399f1e66#0"
FEEUTXO="d5eb2f147a7fddb40be2c32c2c88b70572f0da37348f02b28627b3b4cacfee95#0"
##MY_UTXO="d459e3d48aa35633ba1682d9d5645f361f1857c43f4df0540b274add52e7b85c#1"
SCR_UTXO1="f6af1bc3ea136c7dca7c3abc5181d583b69e83cd92c684c636c574e50860f151#1"
SCR_UTXO2="f1ba28ad8690fc097cdd035e3a58704bcf2c80c49206ae5e1037ccb6dda4074b#1"

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
  --required-signer-hash 6c7f3179c3926ee200fc22fe1c5b1e238b29d398d6a61bde8e1c13dd \
  --tx-out $BUYER_ADDR+$AMOUNT \
  --tx-out $MY_ADDR+"1300000 + 1 38f2e890c8803fc0740848c2b296a11a667e817880e3d16184194ba2.4261746368343370" \
  --change-address $CHANGE_ADDR \
  --testnet-magic 1  \
  --protocol-params-file /home/habib/newDev/projects/batch43/src/protocol.json \
  --out-file Batch43/txfiles/tx-refund-accept.build
echo "Done."

echo "Sign Tx ..."
${CARDANO_CLI_PATH} transaction sign \
--signing-key-file $DIR/payment.skey \
--tx-body-file Batch43/txfiles/tx-refund-accept.build \
--out-file Batch43/txfiles/tx-refund-accept.sign
echo "Done."

# Submit tx
echo "Submiting Tx ..."
${CARDANO_CLI_PATH} transaction submit $NETWORK --tx-file Batch43/txfiles/tx-refund-accept.sign

sleep 30
${CARDANO_CLI_PATH} query utxo $NETWORK --address $SCRIPT_ADDR
#./balance-addr.sh $SCRIPT_ADDR 
