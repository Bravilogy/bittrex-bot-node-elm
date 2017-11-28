module View exposing (rootView)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Types exposing (..)
import Components.OpenOrders exposing (openOrdersSection)
import Components.AccountBalances exposing (accountBalancesSection)


headerView : Html Msg
headerView =
    let
        containerStyles =
            [ ( "backgroundColor", "transparent" )
            , ( "borderBottom", "1px solid #eeeeee" )
            ]
    in
        div
            [ class "jumbotron text-center"
            , style containerStyles
            ]
            [ div [ class "container" ]
                [ h3 [] [ text "Bittrex trading bot" ]
                , p [] [ text "Ideal trading for ideal profits" ]
                ]
            ]


loadingView : Html Msg
loadingView =
    div [ class "text-center small" ]
        [ text "Connecting to bittrex..." ]


renderToolbar : Model -> Html Msg
renderToolbar model =
    let
        openOrdersClass =
            if model.pollOpenOrders then
                "btn btn-danger"
            else
                "btn btn-success"

        openOrdersLabel =
            if model.pollOpenOrders then
                "Stop polling open orders"
            else
                "Start polling open orders"
    in
        ul [ class "list-inline" ]
            [ li [ class "list-inline-item" ]
                [ button
                    [ class openOrdersClass
                    , onClick TogglePollOpenOrders
                    ]
                    [ text openOrdersLabel ]
                ]
            , li [ class "list-inline-item" ]
                [ button
                    [ class "btn btn-success"
                    , disabled model.loadingBalances
                    , onClick GetAccountBalances
                    ]
                    [ text "Show total coins in hodl" ]
                ]
            ]


dashboardView : Model -> Html Msg
dashboardView model =
    div []
        [ renderToolbar model
        , openOrdersSection model
        , accountBalancesSection model
        ]


rootView : Model -> Html Msg
rootView model =
    let
        currentView =
            if not model.connected then
                loadingView
            else
                dashboardView model
    in
        div []
            [ headerView
            , div [ class "container" ]
                [ currentView
                ]
            ]
