{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
module Web.Parser.EventParserSpec where

import           Web.Parser.EventParser
import           Test.Hspec
import           Text.RawString.QQ
import           Types.Metric

spec :: Spec
spec =
  describe "EventParser" $
    it "returns an Event parsed from a raw bosh event" $ do
      let rawJson = [r|
        {
          "series": [{
            "metric": "bosh.healthmonitor.system.cpu.user",
            "points": [ [1456458457, 0.2] ],
            "type": "gauge",
            "host": null,
            "device": null,
            "tags": ["job:worker_cpi", "index:10", "deployment:project", "agent:8440617 f - d298 - 4 fa1 - 8 f94 - 1177 bcf513d7"]
          }]
        }
      |]

      parseEvent rawJson `shouldBe` Just (Event 1456458457 (Metric "cpu" 0.2))
