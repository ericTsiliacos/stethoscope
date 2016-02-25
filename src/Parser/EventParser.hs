{-# LANGUAGE DeriveGeneric #-}
module Parser.EventParser where

import Data.ByteString.Char8 (unpack)
import Data.List.Split (splitOn)
import GHC.Generics
import Data.Aeson (ToJSON)

data Event = Event { time :: String,
                     metric :: Metric
                   } deriving (Eq, Show, Generic)
instance ToJSON Event

data Metric = Metric { name :: String,
                       value :: Float
                     } deriving (Eq, Show, Generic)
instance ToJSON Metric

eventParser :: String -> Event
eventParser rawEvent = Event (show timestamp) $ (Metric name value)
  where event = Prelude.words rawEvent
        timestamp = (read (event !! 2) :: Int)
        name = (Prelude.head . Prelude.reverse) $ splitOn "." (event !! 0)
        value = (read (event !! 1) :: Float)
