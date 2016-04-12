module Usecases where

import           Data.ByteString.Lazy
import           Data.ByteString.Lazy.Char8
import           Repositories.LocalRepository
import           Types.Event

storeEvent :: Repository IO Event -> Event -> IO ()
storeEvent repository event = repository `save` event

fetchLastEvent :: Repository IO Event -> IO Event
fetchLastEvent = fetch
