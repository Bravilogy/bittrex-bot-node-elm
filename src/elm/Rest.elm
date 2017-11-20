module Rest exposing (..)

import Http
import Json.Decode as JD
import Types exposing (..)
import Json.Decode.Pipeline as JDP


getApiUrl : String -> String
getApiUrl path =
    "http://localhost:8080/api" ++ path


openOrderDecoder : JD.Decoder OrderItem
openOrderDecoder =
    JDP.decode OrderItem
        |> JDP.required "OrderUuid" JD.string
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
