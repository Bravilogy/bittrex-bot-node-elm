module View exposing (rootView)

import Types exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)


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


ordersListView : Model -> Html Msg
ordersListView model =
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


renderTotalOpenOrders : List OrderItem -> Html Msg
renderTotalOpenOrders orders =
    orders
        |> List.length
        |> toString
        |> (++) "Total open orders: "
        |> text
        |> (\v ->
                h3 [] [ v ]
           )


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
        , ordersListView model
        , tfoot []
            [ tr []
                [ td [ colspan 5 ]
                    [ strong [] [ text "Potential earnings" ] ]
                , td [ colspan 2 ]
                    [ text (toString (calculatePotentialEarnings model.orders)) ]
                ]
            ]
        ]


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
            ]


dashboardView : Model -> Html Msg
dashboardView model =
    div []
        [ renderTotalOpenOrders model.orders
        , renderToolbar model
        , renderOpenOrdersTable model
        ]


emptyView : Html Msg
emptyView =
    div [ class "text-center small" ]
        [ text "Open orders list is empty."
        , br [] []
        , text "Once you add some on Bittrex, it will automatically appear here."
        ]


rootView : Model -> Html Msg
rootView model =
    let
        currentView =
            if not model.connected then
                loadingView
            else if List.isEmpty model.orders then
                emptyView
            else
                dashboardView model
    in
        div []
            [ headerView
            , div [ class "container" ]
                [ currentView
                ]
            ]
