{-# LANGUAGE OverloadedStrings #-}

module Web.Server where

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

app' :: IORef Event -> ScottyM ()
app' metricRef = do
  get "/" $ file "./public/index.html"

  post "/metrics" $ do
    rawEventJson <- body
    liftIO $ writeIORef metricRef (fromRight $ parseEvent rawEventJson)
    status created201

  get "/monitoring" $ do
    currentMetric <- liftIO $ readIORef metricRef
    json (currentMetric :: Event)

app :: IO Application
app = do
  metricRef <- newIORef $ Event 0 $ Metric "" 0.0
  scottyApp $ app' metricRef

runApp :: IO ()
runApp = do
  port <- read <$> getEnv "PORT"
  metricRef <- newIORef $ Event 0 $ Metric "" 0.0
  scotty port $ do
    middleware logStdoutDev
    app' metricRef
