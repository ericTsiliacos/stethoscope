{-# LANGUAGE DeriveGeneric #-}
module Parser.MetricParser where

import Data.ByteString.Char8 (unpack)
import Data.List.Split (splitOn)
import GHC.Generics
import Data.Aeson (ToJSON)

data Metric = Metric { timestamp :: Int,
                       name :: String,
                       value :: Float
                     } deriving (Eq, Show, Generic)
instance ToJSON Metric

metricParser :: String -> Metric
metricParser rawEvent = Metric timestamp name value
  where event = Prelude.words rawEvent
        timestamp = (read (event !! 2) :: Int)
        name = (Prelude.head . Prelude.reverse) $ splitOn "." (event !! 0)
        value = (read (event !! 1) :: Float)
