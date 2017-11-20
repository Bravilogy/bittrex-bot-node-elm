module Types exposing (..)

import Http


type alias OrderItem =
    { orderId : String
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
    , pollOpenOrders : Bool
    , waitingOpenOrders : Bool
    }


type alias OrderItemsList =
    List OrderItem


type Msg
    = Tick
    | GotOpenOrders (Result Http.Error (List OrderItem))
    | TogglePollOpenOrders
