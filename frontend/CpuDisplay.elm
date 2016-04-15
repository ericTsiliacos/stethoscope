module CpuDisplay
  ( init
  , update
  , view
  , Model) where

import Effects exposing (Effects)
import Html exposing (Html, div, h1, span, text, button, input, form)
import Html.Attributes exposing (type', placeholder, value)
import Html.Events exposing (onClick, targetValue, on)
import Http exposing (get, url)
import Json.Decode exposing (Decoder)
import Task exposing (Task)

type alias Model =
  { cpu : String
  , startTime : String
  , endTime : String
  }

init : (Model, Effects Action)
init =
  ( Model "--" "" ""
  , getEvent Nothing
  )

type Action
  = NewEvent (Maybe String)
  | UpdateStartTime String
  | UpdateEndTime String
  | Filter
  | NoOp

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NewEvent maybeCpu ->
      ( { model | cpu = (Maybe.withDefault model.cpu maybeCpu) }
      , Effects.none
      )
    Filter ->
      ( model
      , getEvent (Just [("start", model.startTime), ("end", model.endTime)])
      )
    UpdateStartTime newStartTime ->
      ( { model | startTime = newStartTime }
      , Effects.none
      )
    UpdateEndTime newEndTime ->
      ( { model | endTime = newEndTime }
      , Effects.none
      )
    NoOp ->
      ( model
      , Effects.none
      )

view : Signal.Address Action -> Model -> Html
view address model =
  div []
    [
      h1 [] [ text "Welcome to Stethoscope" ],
      span [] [ text model.cpu ],
      form []
        [
          input
            [ placeholder "Start"
            , value model.startTime
            , on "input" targetValue (\str -> Signal.message address (UpdateStartTime str))
            ]
            [],
          input
            [ placeholder "End"
            , value model.endTime
            , on "input" targetValue (\str -> Signal.message address (UpdateEndTime str))
            ]
            [],
          button
            [ type' "button", onClick address Filter ]
            [ text "Filter" ]
        ]
    ]

getEvent : Maybe (List (String, String)) -> Effects Action
getEvent maybeQuery =
  let monitoringUrl =
    case maybeQuery of
      Nothing ->
        "/monitoring"
      Just queryParams ->
        url "/monitoring" queryParams
  in
    get eventDecoder monitoringUrl
    |> Task.map toString
    |> Task.toMaybe
    |> Task.map NewEvent
    |> Effects.task

eventDecoder : Decoder (Float)
eventDecoder = Json.Decode.at ["metric", "value"] Json.Decode.float
