{-# LANGUAGE OverloadedStrings #-}

module Web.Server where

import           Control.Applicative                  ((<$>))
import           Control.Monad.IO.Class               (liftIO)
import           Data.Either.Unwrap
import           Data.IORef
import           Network.HTTP.Types.Status            (created201)
import           Network.Wai                          (Application)
import           Network.Wai.Middleware.RequestLogger
import           Parser.EventParser
import           System.Environment                   (getEnv)
import           Types.Metric
import           Web.Scotty

data Repository a = Repository {
  fetch :: IO a,
  save  :: a -> IO ()
}

localRepository :: IORef a -> Repository a
localRepository ref = Repository {
  fetch = readIORef ref,
  save = writeIORef ref
}

app' :: Repository Event -> ScottyM ()
app' repository = do
  get "/" $ file "./public/index.html"

  post "/metrics" $ do
    rawEventJson <- body
    liftIO $ repository `save` fromRight (parseEvent rawEventJson)
    status created201

  get "/monitoring" $ do
    currentMetric <- liftIO $ fetch repository
    json (currentMetric :: Event)

app :: IO Application
app = do
  eventRef <- newIORef $ Event 0 $ Metric "" 0.0
  scottyApp $ app' $ localRepository eventRef

runApp :: IO ()
runApp = do
  port <- read <$> getEnv "PORT"
  eventRef <- newIORef $ Event 0 $ Metric "" 0.0
  scotty port $ do
    middleware logStdoutDev
    app' $ localRepository eventRef
