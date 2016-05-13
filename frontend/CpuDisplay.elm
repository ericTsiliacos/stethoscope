module CpuDisplay exposing
  ( init
  , update
  , view
  )

-- where

import Html exposing (Html, div, h1, span, text, button, input, form)
import Html.Attributes exposing (type', placeholder, value)
import Html.Events exposing (onClick, onInput)
import Http exposing (get, url)
import Json.Decode exposing (Decoder)
import Task exposing (Task)

type alias Model =
  { cpu : String
  , startTime : String
  , endTime : String
  }

init : (Model, Cmd Msg)
init =
  ( Model "--" "" ""
  , getEvent Nothing
  )

type Msg
  = FetchEventSucceed String
  | FetchEventFail Http.Error
  | UpdateStartTime String
  | UpdateEndTime String
  | Filter
  | NoOp

update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
  case action of
    NoOp ->
      ( model, Cmd.none )

    FetchEventSucceed newCpu ->
      ( { model
          | cpu = newCpu
        }
      , Cmd.none
      )

    FetchEventFail _ ->
      ( model, Cmd.none )

    Filter ->
      ( model
      , getEvent (Just [("start", model.startTime), ("end", model.endTime)])
      )

    UpdateStartTime newStartTime ->
      ( { model
          | startTime = newStartTime
        }
      , Cmd.none
      )

    UpdateEndTime newEndTime ->
      ( { model
          | endTime = newEndTime
        }
      , Cmd.none
      )

view : Model -> Html Msg
view model =
  div []
    [
      h1 [] [ text "Welcome to Stethoscope" ],
      span [] [ text model.cpu ],
      form []
        [
          input
            [ placeholder "Start"
            , value model.startTime
            , onInput UpdateStartTime
            ]
            [],
          input
            [ placeholder "End"
            , value model.endTime
            , onInput UpdateEndTime
            ]
            [],
          button
            [ type' "button", onClick Filter ]
            [ text "Filter" ]
        ]
    ]

getEvent : Maybe (List (String, String)) -> Cmd Msg
getEvent maybeQuery =
  let monitoringUrl =
    case maybeQuery of
      Nothing ->
        "/monitoring"
      Just queryParams ->
        url "/monitoring" queryParams
  in
    Task.perform FetchEventFail FetchEventSucceed (get eventDecoder monitoringUrl |> Task.map toString)

eventDecoder : Decoder (Float)
eventDecoder = Json.Decode.at ["metric", "value"] Json.Decode.float
