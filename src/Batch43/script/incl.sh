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