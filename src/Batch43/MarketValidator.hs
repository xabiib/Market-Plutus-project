{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# OPTIONS_GHC -fno-warn-unused-imports #-}

module Batch43.MarketValidator where

import              Ledger              hiding (singleton)
import              Ledger.Typed.Scripts
import              Ledger.Value        as Value
import              Ledger.Ada
import qualified    PlutusTx
import              PlutusTx.Prelude    hiding (Semigroup (..), unless)
import              Prelude             (Show (..))
import qualified    Prelude               as Haskell
import Plutus.V1.Ledger.Api (Data (B, Constr, I, List, Map), ToData, toData)

data MarketDatum = MarketDatum
  {
    sAddress        :: !PubKeyHash              -- seller address
  , bAddress        :: !PubKeyHash              -- buyer address
  , mAddress        :: !PubKeyHash              -- mediator address
  , amount          :: !Integer                -- price of product
  , productNFT      :: !AssetClass             -- product NFT Asset Class
  , disputeFee      :: !Integer
  } 

PlutusTx.unstableMakeIsData ''MarketDatum

data MarketRedeemer =  Buy | Refund | ToSeller | ToBuyer | Cancel
  deriving Show

PlutusTx.makeIsDataIndexed ''MarketRedeemer [('Buy, 0), ('Refund, 1) ,('ToSeller, 2), ('ToBuyer, 3), ('Cancel, 4) ]
PlutusTx.makeLift ''MarketRedeemer


{-# INLINABLE seekDatum #-}
seekDatum :: Maybe Datum -> Maybe MarketDatum
seekDatum md = do
    Datum d <- md
    PlutusTx.fromBuiltinData d

--{-# INLINABLE productAsset #-}
--productAsset :: MarketDatum -> AssetClass
--productAsset pDatum = AssetClass (prodPolicyId pDatum, prodTokenName pDatum)

{-# INLINEABLE mkValidator #-}
mkValidator :: MarketDatum -> MarketRedeemer -> ScriptContext -> Bool
mkValidator datum redeemer ctx =
  case redeemer of                    
             
    Buy        ->  traceIfFalse "Only Buyer Address can sign this Transaction"            signedByBuyer  &&
                   traceIfFalse "Amount must paid to Seller"                              amountPaid      &&
                   traceIfFalse "NFT must sent to Buyerr"                                 nftSendToBuyer
    
    Refund     ->  traceIfFalse "Only Seller Address Sign can sign this Transaction"      signedBySeller  &&
                   traceIfFalse "Amount must paid to Buyer"                               amountRefund      &&
                   traceIfFalse "NFT return to Seller"                                    nftSendToSeller

    ToSeller   ->  traceIfFalse "Only Mediator Address can sign this Transaction"         signedByMediator  &&
                   traceIfFalse "Amount must paid to Seller"                              amountPaid      &&
                   traceIfFalse "NFT paid to Buyerr"                                      nftSendToBuyer  &&
                   traceIfFalse "dispute fee should be sent to Mediator   "               feeToMediator

    ToBuyer    ->  traceIfFalse "Only Mediator Sign can sign this Transaction"            signedByMediator  &&
                   traceIfFalse "Amount must refund to Buyer"                             amountRefund      &&
                   traceIfFalse "NFT return to Seller"                                    nftSendToSeller   &&
                   traceIfFalse "dispute fee should be sent to Mediator   "               feeToMediator       
    
    Cancel      ->  traceIfFalse "Only Buyer can Cancel the Sale"                             False

  where
    info :: TxInfo
    info = scriptContextTxInfo ctx

    signedBySeller :: Bool
    signedBySeller = txSignedBy info $ sAddress  datum

    signedByBuyer :: Bool
    signedByBuyer = txSignedBy info $ bAddress  datum

    signedByMediator :: Bool
    signedByMediator = txSignedBy info $ mAddress datum

    valueToSeller :: Value
    valueToSeller = valuePaidTo info $ sAddress datum

    valueToBuyer :: Value
    valueToBuyer = valuePaidTo info $ bAddress datum

    valueToMediator :: Value
    valueToMediator = valuePaidTo info $ mAddress datum
    
    amountPaid :: Bool
    amountPaid = (getLovelace $ fromValue valueToSeller) >= (amount datum)
    
    amountRefund :: Bool
    amountRefund = (getLovelace $ fromValue valueToBuyer) >= (amount datum)

    feeToMediator :: Bool
    feeToMediator = (getLovelace $ fromValue valueToMediator) >= (disputeFee datum)

    nftSendToBuyer :: Bool
    nftSendToBuyer = assetClassValueOf valueToBuyer (productNFT datum) == 1

    nftSendToSeller :: Bool
    nftSendToSeller = assetClassValueOf valueToSeller (productNFT datum) == 1

  

data MarketTypes

instance ValidatorTypes MarketTypes where
    type DatumType MarketTypes = MarketDatum
    type RedeemerType MarketTypes = MarketRedeemer

typedValidator :: TypedValidator MarketTypes
typedValidator  =
  mkTypedValidator @MarketTypes
    $$(PlutusTx.compile [||mkValidator||])
    $$(PlutusTx.compile [||wrap||])
  where
    wrap = wrapValidator @MarketDatum @MarketRedeemer

validator :: Validator
validator = validatorScript typedValidator

