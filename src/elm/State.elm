module State exposing (init, update, subscriptions)

import Time
import Types exposing (..)
import Rest exposing (getOpenOrders)


initModel : Model
initModel =
    { orders = []
    , error = Nothing
    , connected = False
    , waitingForData = True
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, getOpenOrders )


formatOrders : List OrderItem -> List OrderItem -> List OrderItem
formatOrders oldOrders newOrders =
    List.map
        (\order ->
            let
                oldEntry =
                    oldOrders
                        |> List.filter
                            (\old ->
                                old.orderId == order.orderId
                            )
                        |> List.head

                growth =
                    case oldEntry of
                        Nothing ->
                            False

                        Just entry ->
                            order.price > entry.price
            in
                { order | growth = growth }
        )
        newOrders


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick ->
            ( { model
                | waitingForData = True
              }
            , Cmd.batch
                [ getOpenOrders
                ]
            )

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
                    , waitingForData = False
                    , connected = True
                  }
                , Cmd.none
                )

        GotOpenOrders (Err _) ->
            ( { model
                | error = Just "Could not fetch open orders"
                , waitingForData = False
              }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ if not model.waitingForData then
            Time.every (10 * Time.second) (always Tick)
          else
            Sub.none
        ]
