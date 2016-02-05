{-# LANGUAGE OverloadedStrings, QuasiQuotes #-}
module Main (main) where

import           Test.Hspec
import           Test.Hspec.Wai
import           Test.Hspec.Wai.JSON
import           Data.Aeson (Value(..), object, (.=))

import           Server (app)

main :: IO ()
main = hspec spec

spec :: Spec
spec = with app $ do
  describe "POST /metrics" $ do
    it "responds with 201" $ do
      post "/metrics" "deployment_name.job_name.index.agent_id.metric_name metric_value UTC_timestamp" `shouldRespondWith` 201

    it "responds with metric json" $ do
      post "/metrics" "deployment1.job1.0.agent123.cpu 82.96 1454644228"
      get "/jobs/monitoring" `shouldRespondWith` [json|{timestamp: 1454644228, metricName: "cpuUsage", metricValue: 82.96}|]
