module Parser.MetricParser where

import Data.ByteString.Char8
import Data.ByteString.Char8 (unpack)
import Data.List.Split (splitOn)

-- Event format
-- deployment_name.job_name.index.agent_id.metric_name metric_value UTC_timestamp
type Name = String
type Value = Float
type Timestamp = Int
data Metric = Metric Timestamp Name Value deriving (Eq, Show)

metricParser :: ByteString -> Metric
metricParser rawEvent = Metric timestamp name value
  where event = fmap unpack (split ' ' rawEvent)
        timestamp = (read (event !! 2) :: Int)
        name = (Prelude.head . Prelude.reverse) $ splitOn "." (event !! 0)
        value = (read (event !! 1) :: Float)
