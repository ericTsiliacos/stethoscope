module Main (..) where

import Html exposing (..)
import Json.Decode exposing (..)
import Task exposing (..)
import Http exposing (..)

view : String -> Html
view cpu =
  div [] [
    h1 [] [ text "Welcome to Stethoscope" ],
    span [] [ text cpu ]
  ]

eventMailbox : Signal.Mailbox String
eventMailbox =
  Signal.mailbox "--"

getEvent : Task Http.Error String
getEvent =
  Task.map toString (Http.get eventDecoder "/monitoring")

eventDecoder : Decoder (Float)
eventDecoder = Json.Decode.at ["metric", "value"] Json.Decode.float

port runner : Task Http.Error ()
port runner =
  getEvent `Task.andThen` Signal.send eventMailbox.address

main : Signal Html
main = Signal.map view eventMailbox.signal
