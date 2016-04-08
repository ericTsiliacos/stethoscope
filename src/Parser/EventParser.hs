{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}
module Parser.EventParser where

import           Data.Aeson           (FromJSON (..), eitherDecode)
import           Data.ByteString.Lazy
import           Data.Text
import           GHC.Generics
import qualified Types.Metric         as T

data Series = Series {
  metric   :: Text,
  points   :: [(Int, Float)]
} deriving (Show, Generic)
instance FromJSON Series

data RawEvent = RawEvent {
  series :: [Series]
} deriving (Show, Generic)
instance FromJSON RawEvent

parseEvent :: ByteString -> Either String T.Event
parseEvent rawEventJson =  convertToEvent <$> eitherDecode rawEventJson

convertToEvent :: RawEvent -> T.Event
convertToEvent rawEvent = T.Event timestamp $ T.Metric metricName metricValue
  where fstSeries = Prelude.head . series $ rawEvent
        rawName = metric fstSeries
        metricName = if "cpu" `isInfixOf ` rawName then "cpu" else ""
        timestamp = Prelude.fst . Prelude.head . points $ fstSeries
        metricValue = Prelude.snd . Prelude.head . points $ fstSeries
