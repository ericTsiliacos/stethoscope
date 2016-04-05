{-# LANGUAGE OverloadedStrings #-}

module Web.Server where

import           Control.Applicative                  ((<$>))
import           Control.Monad.IO.Class               (liftIO)
import           Data.IORef
import qualified Data.Text.Lazy                       as L
import           Data.Text.Lazy.Encoding              (decodeUtf8)
import           Network.HTTP.Types.Status            (created201)
import           Network.Wai                          (Application)
import           Network.Wai.Middleware.RequestLogger
import           Parser.EventParser
import           System.Environment                   (getEnv)
import qualified Web.Scotty                           as S

app' :: IORef Event -> S.ScottyM ()
app' metricRef = do
  S.get "/" $ S.file "./public/index.html"

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
  port <- read <$> getEnv "PORT"
  metricRef <- newIORef $ Event "" $ Metric "" 0.0
  S.scotty port $ do
    S.middleware logStdoutDev
    app' metricRef
