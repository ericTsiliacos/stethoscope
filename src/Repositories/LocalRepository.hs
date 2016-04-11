module Repositories.LocalRepository where

import           Data.IORef

data Repository m a = Repository {
  fetch :: m a,
  save  :: a -> m ()
}

localRepository :: IORef a -> Repository IO a
localRepository ref = Repository {
  fetch = readIORef ref,
  save = writeIORef ref
}
