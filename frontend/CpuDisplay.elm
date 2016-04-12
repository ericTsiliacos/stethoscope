module CpuDisplay
  ( init
  , update
  , view
  , Model) where

import Effects exposing (Effects)
import Html exposing (Html, div, h1, span, text)
import Html.Attributes exposing (type', placeholder)
import Html.Events exposing (onClick)
import Http exposing (get)
import Json.Decode exposing (Decoder)
import Task exposing (Task)

type alias Model = { cpu : String }

init : (Model, Effects Action)
init =
  ( Model "--"
  , getEvent
  )

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
  get eventDecoder "/monitoring"
  |> Task.map toString
  |> Task.toMaybe
  |> Task.map NewEvent
  |> Effects.task

eventDecoder : Decoder (Float)
eventDecoder = Json.Decode.at ["metric", "value"] Json.Decode.float
