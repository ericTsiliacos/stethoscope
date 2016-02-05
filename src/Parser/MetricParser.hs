module Parser.MetricParser where

import Data.ByteString.Char8

data Metric = Metric Int String Float deriving (Eq, Show)

metricParser :: ByteString -> Metric
metricParser = undefined

