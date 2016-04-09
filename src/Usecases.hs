module Usecases where

import           Data.ByteString.Lazy
import           Data.ByteString.Lazy.Char8
import           Data.Either.Unwrap
import           Parser.EventParser
import           Repositories.LocalRepository
import           Types.Metric

parseAndStoreRawEvent :: Repository Event -> ByteString -> IO ()
parseAndStoreRawEvent repository rawEvent = do
  repository `save` fromRight (parseEvent rawEvent)

fetchLastEvent :: Repository Event -> IO Event
fetchLastEvent = fetch
