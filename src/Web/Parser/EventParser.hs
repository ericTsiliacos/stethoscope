{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}

module Web.Parser.EventParser (
  parseEvent
) where

import           Control.Applicative  (pure, (<$>), (<*>))
import           Data.Aeson           (FromJSON (..), decode)
import           Data.ByteString.Lazy
import           Data.Maybe
import           Data.Text
import           GHC.Generics
import qualified Types.Event         as T

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
parseEvent rawEventJson = decode rawEventJson >>= convertToEvent

convertToEvent :: RawEvent -> Maybe T.Event
convertToEvent rawEvent = T.Event <$> timestamp <*> (T.Metric <$> metricName <*> metricValue)
  where series' = series rawEvent
        rawName = metric <$> series'
        metricName = extractMetricName rawName
        timestamp = listToMaybe $ Prelude.concat $ fmap fst . points <$> series'
        metricValue = listToMaybe $ Prelude.concat $ fmap snd . points <$> series'

extractMetricName :: [Text] -> Maybe Text
extractMetricName (x:xs) = if "cpu" `isInfixOf ` x then Just "cpu" else Nothing
extractMetricName _ = Nothing
