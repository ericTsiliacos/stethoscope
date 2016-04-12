module Main (..) where

import CpuDisplay exposing (init, update, view, Model)
import Effects exposing (Never)
import Html exposing (Html)
import StartApp
import Task exposing (Task)

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
