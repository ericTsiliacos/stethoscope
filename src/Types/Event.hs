module Types.Event where

import qualified Data.Text    as T

data Event = Event { time   :: Integer,
                     metric :: Metric
                   } deriving (Eq, Show)

data Metric = Metric { name  :: T.Text,
                       value :: Float
                     } deriving (Eq, Show)
