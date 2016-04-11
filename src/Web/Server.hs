{-# LANGUAGE OverloadedStrings #-}

module Web.Server where

import           Control.Applicative                  ((<$>))
import           Control.Monad
import           Control.Monad.IO.Class               (liftIO)
import           Data.Foldable
import           Data.IORef
import           Data.Maybe                           (fromJust)
import           Network.HTTP.Types.Status            (created201)
import           Network.Wai                          (Application)
import           Network.Wai.Middleware.RequestLogger
import           Parser.EventParser
import           Repositories.LocalRepository
import           System.Environment                   (getEnv)
import           Types.Metric
import           Usecases
import           Web.Scotty

app' :: Repository IO Event -> ScottyM ()
app' eventRepository = do
  get "/" $ file "./public/index.html"

  post "/metrics" $ do
    parsedEvent <- parseEvent <$> body
    let storeEventAction = storeEvent eventRepository <$> parsedEvent
    mapM_ liftIO storeEventAction
    status created201

  get "/monitoring" $
    json =<< liftIO (fetchLastEvent eventRepository)

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
