port module Main exposing (..)

import Types exposing (..)
import Html exposing (program)
import View exposing (rootView)
import State exposing (init, update, subscriptions)


main : Program Never Model Msg
main =
    program
        { init = init
        , update = update
        , view = rootView
        , subscriptions = subscriptions
        }
