{-# LANGUAGE DeriveGeneric      #-}
{-# LANGUAGE OverloadedStrings  #-}
{-# LANGUAGE StandaloneDeriving #-}

module Web.Server where

import           Control.Applicative                  ((<$>))
import           Control.Monad.IO.Class               (liftIO)
import           Data.Aeson                           (FromJSON, ToJSON,
                                                       defaultOptions,
                                                       genericToJSON, toJSON)
import           Data.Either.Unwrap                   (fromRight, isRight)
import           Data.IORef
import           Data.Maybe
import qualified Data.Text                            as T
import           Data.Text.Lazy.Read                  (decimal)
import           GHC.Generics
import           Network.HTTP.Types.Status            (created201)
import           Network.Wai                          (Application)
import           Network.Wai.Middleware.RequestLogger
import           Repositories.LocalRepository
import           Safe                                 (headMay)
import           System.Environment                   (getEnv)
import           Types.Event
import           Usecases
import           Web.Parser.EventParser
import           Web.Scotty

deriving instance Generic Event
instance FromJSON Event
instance ToJSON Event where
  toJSON = genericToJSON  defaultOptions

deriving instance Generic Metric
instance FromJSON Metric
instance ToJSON Metric where
  toJSON = genericToJSON  defaultOptions

getParam :: (Eq a) => [(a, b)] -> a -> Maybe b
getParam [] paramName = Nothing
getParam parameters paramName = if null foundParameters then Nothing else Just $ snd $ head foundParameters
  where foundParameters = filter (\tuple -> fst tuple == paramName) parameters

app' :: Repository IO [Event] -> ScottyM ()
app' eventRepository = do
  get "/" $ file "./public/index.html"

  post "/metrics" $ do
    parsedEvent <- parseEvent <$> body
    mapM_ liftIO $ storeEvent eventRepository <$> parsedEvent
    status created201

  get "/monitoring" $ do
    params' <- params

    let start = getParam params' "start"
    let end = getParam params' "end"

    if all isJust [start, end]
    then do
      let startTime = decimal $ fromJust start
      let endTime = decimal $ fromJust end
      liftIO (head <$> averageCpuUsage eventRepository (fst $ fromRight startTime) (fst $ fromRight endTime)) >>= json
    else
      liftIO (head <$> fetchEvents eventRepository) >>= json

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
