{-# LANGUAGE DeriveGeneric #-}
module Types.Event where

import           Data.Aeson   (FromJSON, ToJSON, defaultOptions, genericToJSON,
                               toJSON)
import qualified Data.Text    as T
import           GHC.Generics

data Event = Event { time   :: Integer,
                     metric :: Metric
                   } deriving (Eq, Show, Generic)
instance FromJSON Event
instance ToJSON Event where
  toJSON = genericToJSON  defaultOptions

data Metric = Metric { name  :: T.Text,
                       value :: Float
                     } deriving (Eq, Show, Generic)
instance FromJSON Metric
instance ToJSON Metric where
  toJSON = genericToJSON  defaultOptions
