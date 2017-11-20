module View exposing (rootView)

import Types exposing (..)
import Html exposing (..)
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


dashboardView : Model -> Html Msg
dashboardView model =
    div []
        [ h3 []
            [ model.orders
                |> List.length
                |> toString
                |> (++) "Total open orders: "
                |> text
            ]
        , table [ class "table table-striped" ]
            [ thead []
                [ tr []
                    [ th [] [ text "Market" ]
                    , th [] [ text "Quantity" ]
                    , th [] [ text "Opened at" ]
                    , th [] [ text "Order type" ]
                    , th [] [ text "Limit Sell / Buy" ]
                    , th [] [ text "Estimated total" ]
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
