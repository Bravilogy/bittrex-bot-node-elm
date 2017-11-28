module Components.AccountBalances exposing (..)

import Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Components.Shared exposing (..)


calculateTakeHomeToday : AccountBalance -> Float
calculateTakeHomeToday balance =
    balance.quantity * balance.currentPrice


calculateProfitToday : AccountBalance -> Float
calculateProfitToday balance =
    calculateTakeHomeToday balance
        |> (\v -> v - balance.totalPrice)


calculateTotalProfitToday : List AccountBalance -> Float
calculateTotalProfitToday balances =
    balances
        |> List.map calculateProfitToday
        |> List.sum


balanceItemView : AccountBalance -> Html Msg
balanceItemView balance =
    let
        takeHomeValue =
            calculateTakeHomeToday balance
    in
        tr []
            [ td [] [ text balance.currency ]
            , td [] [ text (toString balance.pricePerUnit) ]
            , td [] [ text (toString balance.quantity) ]
            , td [] [ text (toString balance.totalPrice) ]
            , td []
                [ takeHomeValue |> toString |> text
                ]
            , td [] [ takeHomeValue - balance.totalPrice |> toString |> text ]
            ]


balancesListView : List AccountBalance -> Html Msg
balancesListView balances =
    balances
        |> List.sortBy .currency
        |> List.map balanceItemView
        |> tbody []


renderBalancesTable : Model -> Html Msg
renderBalancesTable model =
    table [ class "table table-striped" ]
        [ thead []
            [ tr []
                [ th [] [ text "Currency" ]
                , th [] [ text "Buy price per unit" ]
                , th [] [ text "Quantity" ]
                , th [] [ text "Total paid" ]
                , th [] [ text "Take home today" ]
                , th [] [ text "Profit today" ]
                ]
            ]
        , balancesListView model.balances
        , tfoot []
            [ tr []
                [ td [ colspan 5 ]
                    [ strong [] [ text "Projected total" ] ]
                , td []
                    [ text (toString (calculateTotalProfitToday model.balances)) ]
                ]
            ]
        ]


accountBalancesSection : Model -> Html Msg
accountBalancesSection model =
    if List.isEmpty model.balances then
        section []
            [ emptyView
                [ "To view your #hodls, click the button above."
                , "If you have anything in your account, they will magically appear here."
                ]
            ]
    else
        section []
            [ renderListTotal model.balances "Total coins in hodl"
            , renderBalancesTable model
            ]
