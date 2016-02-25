{-# LANGUAGE OverloadedStrings, QuasiQuotes #-}
module Parser.EventParserSpec where

import  Test.Hspec
import Parser.EventParser

spec :: Spec
spec = do
  describe "EventParser" $ do
    it "returns an Event parsed from the response" $ do
      (eventParser "deployment_name.job_name.index.agent_id.cpu_usage 82.96 1454644228") `shouldBe` (Event "1454644228" $ Metric "cpu_usage" 82.96)
