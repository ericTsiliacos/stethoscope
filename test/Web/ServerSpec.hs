{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
module Web.ServerSpec where

import           Data.Aeson          (Object, decode, encode)
import           Data.ByteString.Lazy
import           Data.Maybe
import           Test.Hspec
import           Test.Hspec.Wai
import           Test.Hspec.Wai.JSON
import           Text.RawString.QQ
import           Web.Server

eventData :: ByteString
eventData = encode . fromJust $ (decode rawJson :: Maybe Object)
      where rawJson = [r|
        {
          "series": [{
        		"metric": "bosh.healthmonitor.system.cpu.user",
        		"points": [
        			[1456458457, 0.2]
        		],
        		"type": "gauge",
        		"host": null,
        		"device": null,
        		"tags": ["job:worker_cpi", "index:10", "deployment:project", "agent:8440617 f - d298 - 4 fa1 - 8 f94 - 1177 bcf513d7"]
        	}]
        }
      |]

spec :: Spec
spec = with app $
  describe "POST /metrics" $ do
    it "responds with 201" $
      post "/metrics" eventData `shouldRespondWith` 201

    it "responds with metric json" $ do
      _ <- post "/metrics" eventData
      get "/monitoring" `shouldRespondWith` [json|{time: 1456458457, metric:{name: "cpu", value: 0.2}}|]
