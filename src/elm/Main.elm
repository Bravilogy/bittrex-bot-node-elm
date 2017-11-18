port module Main exposing (..)

import Time
import Http
import Json.Decode as JD
import Html exposing (..)
import Json.Decode.Pipeline as JDP
import Html.Attributes exposing (..)


-- model


type alias OrderItem =
    { uuid : Maybe String
    , quantity : Float
    , limit : Float
    , opened : String
    , exchange : String
    , orderType : String
    , price : Float
    , growth : Bool
    }


type alias Model =
    { orders : List OrderItem
    , error : Maybe String
    , connected : Bool
    }


type alias OrderItemsList =
    List OrderItem


initModel : Model
initModel =
    { orders = []
    , error = Nothing
    , connected = False
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, getOpenOrders )



-- update


type Msg
    = GetOpenOrders
    | GotOpenOrders (Result Http.Error (List OrderItem))


getApiUrl : String -> String
getApiUrl path =
    "http://localhost:8080/api" ++ path


openOrderDecoder : JD.Decoder OrderItem
openOrderDecoder =
    JDP.decode OrderItem
        |> JDP.required "Uuid" (JD.nullable JD.string)
        |> JDP.required "Quantity" JD.float
        |> JDP.required "Limit" JD.float
        |> JDP.required "Opened" JD.string
        |> JDP.required "Exchange" JD.string
        |> JDP.required "OrderType" JD.string
        |> JDP.required "Price" JD.float
        |> JDP.hardcoded False


openOrdersListDecoder : JD.Decoder (List OrderItem)
openOrdersListDecoder =
    JD.field "data" (JD.list openOrderDecoder)


getOpenOrders : Cmd Msg
getOpenOrders =
    let
        url =
            getApiUrl "/open-orders"

        request =
            Http.get url openOrdersListDecoder
    in
        Http.send GotOpenOrders request


formatOrders : List OrderItem -> List OrderItem -> List OrderItem
formatOrders oldOrders newOrders =
    List.map2
        (\a b ->
            { a | growth = a.price > b.price }
        )
        newOrders
        oldOrders


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetOpenOrders ->
            ( model, getOpenOrders )

        GotOpenOrders (Ok orders) ->
            let
                formattedOrders =
                    if not (List.isEmpty model.orders) then
                        formatOrders model.orders orders
                    else
                        orders
            in
                ( { model
                    | orders = formattedOrders
                    , connected = True
                  }
                , Cmd.none
                )

        GotOpenOrders (Err _) ->
            ( { model | error = Just "Could not fetch open orders" }, Cmd.none )



-- view


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
                    , th [] [ text "Last price" ]
                    ]
                ]
            , ordersListView model
            ]
        ]


emptyView : Html Msg
emptyView =
    div [ class "text-center small" ]
        [ text "Open orders list is empty."
        , br [] []
        , text "Once you add some on Bittrex, it will automatically appear here."
        ]


view : Model -> Html Msg
view model =
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



-- subs


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ if not (List.isEmpty model.orders) then
            Time.every (4 * Time.second) (always GetOpenOrders)
          else
            Sub.none
        ]


main : Program Never Model Msg
main =
    program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
