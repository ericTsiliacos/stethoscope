{-# LANGUAGE OverloadedStrings #-}
module Parser.EventParserSpec where

import           Parser.EventParser
import           Test.Hspec

spec :: Spec
spec =
  describe "EventParser" $
    it "returns an Event parsed from the response" $
      eventParser
        "deployment_name.job_name.index.agent_id.cpu_usage 82.96 1454644228"
        `shouldBe` Event "1454644228" (Metric "cpu_usage" 82.96)
