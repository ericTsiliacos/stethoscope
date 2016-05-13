module Main exposing (..)

-- where

import Html.App exposing (program)
import CpuDisplay exposing (init, update, view)

main : Program Never
main =
  program
    { init = init
    , view = view
    , update = update
    , subscriptions = always Sub.none
    }
