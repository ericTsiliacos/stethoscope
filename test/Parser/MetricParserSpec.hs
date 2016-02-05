{-# LANGUAGE OverloadedStrings, QuasiQuotes #-}

module Parser.MetricParserSpec where

import  Test.Hspec
import Parser.MetricParser
import Data.ByteString.Char8

spec :: Spec
spec = do
  describe "responseParser" $ do
    it "returns a Metric parsed from the response" $ do
      (metricParser $ pack "deployment_name.job_name.index.agent_id.cpu_usage 82.96 1454644228") `shouldBe` (Metric 1454644228 "cpuUsage" 82.96)
