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
import           Web.Parser.EventParser
import           Repositories.LocalRepository
import           System.Environment                   (getEnv)
import           Types.Event
import           Usecases
import           Web.Scotty

app' :: Repository IO Event -> ScottyM ()
app' eventRepository = do
  get "/" $ file "./public/index.html"

  post "/metrics" $ do
    parsedEvent <- parseEvent <$> body
    mapM_ liftIO $ storeEvent eventRepository <$> parsedEvent
    status created201

  get "/monitoring" $
    liftIO (fetchLastEvent eventRepository) >>= json

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
