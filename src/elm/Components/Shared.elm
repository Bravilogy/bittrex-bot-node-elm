module Components.Shared exposing (..)

import Html exposing (..)
import Types exposing (..)


renderListTotal : List a -> String -> Html Msg
renderListTotal list label =
    list
        |> List.length
        |> toString
        |> (++) (label ++ ": ")
        |> (\v ->
                h3 [] [ text v ]
           )
