{-# LANGUAGE DeriveGeneric #-}
module Types.Event where

import           Data.Aeson   (FromJSON, ToJSON, defaultOptions, genericToJSON,
                               toJSON)
import           Data.Text
import           GHC.Generics

data Event = Event { time   :: Int,
                     metric :: Metric
                   } deriving (Eq, Show, Generic)
instance FromJSON Event
instance ToJSON Event where
  toJSON = genericToJSON  defaultOptions

data Metric = Metric { name  :: Text,
                       value :: Float
                     } deriving (Eq, Show, Generic)
instance FromJSON Metric
instance ToJSON Metric where
  toJSON = genericToJSON  defaultOptions
