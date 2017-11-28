module Components.Shared exposing (..)

import Html.Attributes exposing (..)
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


emptyView : List String -> Html Msg
emptyView texts =
    texts
        |> List.map
            (\v -> div [] [ text v, br [] [] ])
        |> div
            [ class "text-center small"
            , style [ ( "margin", "100px" ) ]
            ]
