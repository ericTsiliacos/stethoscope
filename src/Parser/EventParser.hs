{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}

module Parser.EventParser (
  parseEvent
) where

import           Control.Applicative  ((<$>), (<*>), pure)
import           Data.Aeson           (FromJSON (..), decode)
import           Data.ByteString.Lazy
import           Data.Maybe
import           Data.Text
import           GHC.Generics
import qualified Types.Metric         as T

data Series = Series {
  metric :: Text,
  points :: [(Int, Float)]
} deriving (Show, Generic)
instance FromJSON Series

data RawEvent = RawEvent {
  series :: [Series]
} deriving (Show, Generic)
instance FromJSON RawEvent

parseEvent :: ByteString ->  Maybe T.Event
parseEvent rawEventJson = convertToEvent =<< decode rawEventJson

convertToEvent :: RawEvent -> Maybe T.Event
convertToEvent rawEvent = T.Event <$> timestamp <*> (T.Metric metricName <$> metricValue)
  where series' = series rawEvent
        rawName = metric <$> series'
        metricName = if "cpu" `isInfixOf ` Prelude.head rawName then "cpu" else ""
        timestamp = listToMaybe $ Prelude.concat $ fmap fst . points <$> series'
        metricValue = listToMaybe $ Prelude.concat $ fmap snd . points <$> series'
