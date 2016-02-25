{-# LANGUAGE OverloadedStrings, QuasiQuotes #-}
module Web.Server where

import qualified Web.Scotty as S
import qualified Data.Text.Lazy as L
import Network.Wai.Middleware.RequestLogger
import Network.Wai (Application)
import Network.HTTP.Types.Status (created201)
import Control.Monad.IO.Class (liftIO)
import Data.Text.Lazy.Encoding (decodeUtf8)
import Parser.EventParser
import Data.IORef

app' :: IORef Event -> S.ScottyM ()
app' metricRef = do
  S.get "/" $ do
    S.html "Welcome to Stethoscope"

  S.post "/metrics" $ do
    body <- S.body
    let rawEvent = L.unpack $ decodeUtf8 body
    liftIO $ writeIORef metricRef (eventParser rawEvent)
    S.status created201

  S.get "/monitoring" $ do
    currentMetric <- liftIO $ readIORef metricRef
    S.json (currentMetric :: Event)

app :: IO Application
app = do
  metricRef <- newIORef $ Event "" $ Metric "" 0.0
  S.scottyApp $ app' metricRef

runApp :: IO ()
runApp = do
  metricRef <- newIORef $ Event "" $ Metric "" 0.0
  S.scotty 8080 $ do
    S.middleware logStdoutDev
    app' metricRef
