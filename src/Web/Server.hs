{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Web.Server where

import           Control.Applicative                  ((<$>))
import           Control.Monad.IO.Class               (liftIO)
import           Data.Either.Unwrap                   (fromRight, isRight)
import           Data.IORef
import           Data.Text.Lazy.Read                  (decimal)
import           Network.HTTP.Types.Status            (created201)
import           Network.Wai                          (Application)
import           Network.Wai.Middleware.RequestLogger
import           Repositories.LocalRepository
import           System.Environment                   (getEnv)
import           Types.Event
import           Usecases
import           Web.Parser.EventParser
import           Web.Scotty

app' :: Repository IO [Event] -> ScottyM ()
app' eventRepository = do
  get "/" $ file "./public/index.html"

  post "/metrics" $ do
    parsedEvent <- parseEvent <$> body
    mapM_ liftIO $ storeEvent eventRepository <$> parsedEvent
    status created201

  get "/monitoring" $ do
    params' <- params
    if null params'
    then liftIO (head <$> fetchEvents eventRepository) >>= json
    else do
      let startTime = (decimal . snd) (head $ filter (\tuple -> fst tuple == "start") params')
      let endTime = (decimal . snd) (head $ filter (\tuple -> fst tuple == "end") params')

      if isRight startTime && isRight endTime
        then liftIO (averageCpuUsage eventRepository (fst $ fromRight startTime) (fst $ fromRight endTime)) >>= json
        else liftIO (head <$> fetchEvents eventRepository) >>= json

app :: IO Application
app = do
  eventRef <- newIORef [Event 0 $ Metric "" 0.0]
  scottyApp $ app' $ localRepository eventRef

runApp :: IO ()
runApp = do
  port <- read <$> getEnv "PORT"
  eventRef <- newIORef [Event 0 $ Metric "" 0.0]
  scotty port $ do
    middleware logStdoutDev
    app' $ localRepository eventRef
