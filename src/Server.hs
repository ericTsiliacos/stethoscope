{-# LANGUAGE OverloadedStrings, QuasiQuotes #-}
module Server (runApp, app) where

import           Data.Aeson (Value(..), object, (.=))
import           Network.Wai (Application)
import qualified Web.Scotty as S
import Network.HTTP.Types.Status (created201)

app' :: S.ScottyM ()
app' = do
  S.post "/metrics" $ do
    S.status created201

  S.get "/jobs/monitoring" $ do
    S.json $ object ["timestamp" .= Number 1454644228, "metricName" .= String "cpuUsage", "metricValue" .= Number 82.96]

app :: IO Application
app = S.scottyApp app'

runApp :: IO ()
runApp = S.scotty 8080 app'
