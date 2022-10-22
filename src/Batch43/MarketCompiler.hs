{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE ImportQualifiedPost #-}

module Batch43.MarketCompiler where

import Cardano.Api
import Cardano.Api.Shelley (PlutusScript (..))
import Codec.Serialise (serialise)
import Data.Aeson
import qualified Data.ByteString.Lazy as LBS
import qualified Data.ByteString.Short as SBS
import qualified Ledger
import           Ledger.Value
import Plutus.V1.Ledger.Api (Data (B, Constr, I, List, Map), ToData, toData)

import Batch43.MarketValidator

dataToScriptData :: Data -> ScriptData
dataToScriptData (Constr n xs) = ScriptDataConstructor n $ dataToScriptData <$> xs
dataToScriptData (I n) = ScriptDataNumber n
dataToScriptData (B b) = ScriptDataBytes b
dataToScriptData (Map xs) = ScriptDataMap [(dataToScriptData k, dataToScriptData v) | (k, v) <- xs]
dataToScriptData (List xs) = ScriptDataList $ fmap dataToScriptData xs

writeJson :: ToData a => FilePath -> a -> IO ()
writeJson file = LBS.writeFile file . encode . scriptDataToJson ScriptDataJsonDetailedSchema . dataToScriptData . toData


writeValidator :: FilePath -> Ledger.Validator -> IO (Either (FileError ()) ())
writeValidator file = writeFileTextEnvelope @(PlutusScript PlutusScriptV1) file Nothing . PlutusScriptSerialised . SBS.toShort . LBS.toStrict . serialise . Ledger.unValidatorScript

writeValidatorScript :: IO (Either (FileError ()) ())
writeValidatorScript = writeValidator "src/temp/input/ProdValidator.plutus" $ Batch43.MarketValidator.validator
--ec03ca961e28b4345a382f03ffb925a9561abda609526dbcbb24d771.4261746368343370
nftCurrencySymbol :: CurrencySymbol
nftCurrencySymbol = "ec03ca961e28b4345a382f03ffb925a9561abda609526dbcbb24d771"

nftTokenName :: TokenName
nftTokenName = "Batch43p"

writeValidatorDatum :: IO ()
writeValidatorDatum = writeJson "src/temp/input/ProdDatum.json" $ MarketDatum
  {
    sAddress      = "5bc0f9ecd2c7bce3057a218a5c34c989fa549d3a3b4ebaf600b1890e"
  , bAddress      = "fda70fa96b27387dd3455f458f7b9b7ba664ec5cb2fe39739603c67b"
  , mAddress      = "a34ac4d4e1b6e0c711652026cc6c754d0b08fb69ab5ae1adc6974b41"
  , amount        = 10000000
  , productNFT    = AssetClass (nftCurrencySymbol, nftTokenName)
  , disputeFee    = 3000000
  }