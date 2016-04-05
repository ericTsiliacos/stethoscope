{-# LANGUAGE DeriveGeneric #-}
module Parser.EventParser where

import           Data.Aeson            (FromJSON, ToJSON, defaultOptions,
                                        genericToJSON, toJSON)
import           Data.ByteString.Char8 (unpack)
import           Data.List.Split       (splitOn)
import           GHC.Generics

data Event = Event { time   :: String,
                     metric :: Metric
                   } deriving (Eq, Show, Generic)
instance FromJSON Event
instance ToJSON Event where
  toJSON = genericToJSON  defaultOptions

data Metric = Metric { name  :: String,
                       value :: Float
                     } deriving (Eq, Show, Generic)
instance FromJSON Metric
instance ToJSON Metric where
  toJSON = genericToJSON  defaultOptions

eventParser :: String -> Event
eventParser rawEvent = Event (show timestamp) $ Metric name value
  where event = Prelude.words rawEvent
        timestamp = read (event !! 2) :: Int
        name = last $ splitOn "." $ head event
        value = read (event !! 1) :: Float
