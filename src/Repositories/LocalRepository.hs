module Repositories.LocalRepository where

import           Data.IORef

data Repository a = Repository {
  fetch :: IO a,
  save  :: a -> IO ()
}

localRepository :: IORef a -> Repository a
localRepository ref = Repository {
  fetch = readIORef ref,
  save = writeIORef ref
}
