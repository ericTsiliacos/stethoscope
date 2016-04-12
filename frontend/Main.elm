module Main (..) where

import Html exposing (..)
import Effects exposing (..)
import StartApp
import Html.Attributes exposing (type', placeholder)
import Html.Events exposing (onClick)
import Json.Decode exposing (..)
import Task exposing (..)
import Http exposing (..)

type Action
  = NewEvent (Maybe String)
  | NoOp

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NewEvent maybeCpu ->
      ( Model (Maybe.withDefault model.cpu maybeCpu)
      , Effects.none
      )
    NoOp ->
      ( model
      , Effects.none
      )

view : Signal.Address Action -> Model -> Html
view address model =
  div [] [
    h1 [] [ text "Welcome to Stethoscope" ],
    span [] [ text model.cpu ]
  ]

getEvent : Effects Action
getEvent =
  Http.get eventDecoder "/monitoring"
  |> Task.map toString
  |> Task.toMaybe
  |> Task.map NewEvent
  |> Effects.task

eventDecoder : Decoder (Float)
eventDecoder = Json.Decode.at ["metric", "value"] Json.Decode.float

type alias Model = { cpu : String }

init : (Model, Effects Action)
init =
  ( Model "--"
  , getEvent
  )

app : StartApp.App Model
app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = []
    }

main : Signal Html
main = app.html

port tasks : Signal (Task Never ())
port tasks = app.tasks
