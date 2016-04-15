{-# LANGUAGE OverloadedStrings   #-}

module Usecases where

import           Repositories.LocalRepository
import           Types.Event

type StartTime = Integer
type EndTime = Integer

storeEvent :: Repository IO [Event] -> Event -> IO ()
storeEvent repository event = do
  events <- fetchEvents repository
  repository `save` (event:events)

fetchEvents :: Repository IO [Event] -> IO [Event]
fetchEvents = fetch

averageCpuUsage :: Repository IO [Event] -> StartTime -> EndTime -> IO [Event]
averageCpuUsage repository start end = do
  events <- fetch repository
  let eventsInRange = filter (\event -> time event >= start && time event <= end) events
  let cpuValues = fmap (value . metric) eventsInRange
  return [Event 0 $ Metric "cpu" $ sum cpuValues / fromIntegral (length cpuValues)]
