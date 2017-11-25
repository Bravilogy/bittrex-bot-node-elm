module Components.OpenOrders exposing (..)

import Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Components.Shared exposing (..)


calculateDone : OrderItem -> Html Msg
calculateDone order =
    let
        percent =
            if order.orderType == "LIMIT_SELL" then
                order.price / order.limit * 100
            else
                order.limit / order.price * 100
    in
        percent
            |> round
            |> toString
            |> (\v -> text (v ++ "%"))


orderItemView : OrderItem -> Html Msg
orderItemView order =
    let
        labelClass =
            if order.growth then
                "label label-success"
            else
                "label label-danger"

        estimatedTotal =
            if order.orderType == "LIMIT_SELL" then
                toString (order.quantity * order.limit)
            else
                "N/A"

        labelIcon =
            if order.growth then
                "fa fa-arrow-up"
            else
                "fa fa-arrow-down"
    in
        tr []
            [ td [] [ text order.exchange ]
            , td [] [ text (toString order.quantity) ]
            , td [] [ text order.opened ]
            , td []
                [ text
                    (if order.orderType == "LIMIT_BUY" then
                        "Buy"
                     else
                        "Sell"
                    )
                ]
            , td [] [ text (toString order.limit) ]
            , td [] [ text estimatedTotal ]
            , td [] [ calculateDone order ]
            , td []
                [ span [ class labelClass ]
                    [ text (toString order.price)
                    , text " "
                    , i [ class labelIcon ] []
                    ]
                ]
            ]


openOrdersListView : Model -> Html Msg
openOrdersListView model =
    model.orders
        |> List.sortBy .exchange
        |> List.sortBy .orderType
        |> List.map orderItemView
        |> tbody []


calculatePotentialEarnings : List OrderItem -> Float
calculatePotentialEarnings orders =
    orders
        |> List.foldl
            (\x result ->
                if x.orderType == "LIMIT_SELL" then
                    result + x.limit * x.quantity
                else
                    result
            )
            0


renderOpenOrdersTable : Model -> Html Msg
renderOpenOrdersTable model =
    table [ class "table table-striped" ]
        [ thead []
            [ tr []
                [ th [] [ text "Market" ]
                , th [] [ text "Quantity" ]
                , th [] [ text "Opened" ]
                , th [] [ text "Order type" ]
                , th [] [ text "Limit sell / buy" ]
                , th [] [ text "Estimated total" ]
                , th [] [ text "% complete" ]
                , th [] [ text "Last price" ]
                ]
            ]
        , openOrdersListView model
        , tfoot []
            [ tr []
                [ td [ colspan 5 ]
                    [ strong [] [ text "Potential earnings" ] ]
                , td [ colspan 3 ]
                    [ text (toString (calculatePotentialEarnings model.orders)) ]
                ]
            ]
        ]


openOrdersSection : Model -> Html Msg
openOrdersSection model =
    section []
        [ renderListTotal model.orders "Total open orders"
        , renderOpenOrdersTable model
        ]
