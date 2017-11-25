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


type alias AccountBalance =
    { currency : String
    , quantity : Float
    , totalPrice : Float
    , pricePerUnit : Float
    , currentPrice : Float
    }


type alias Model =
    { orders : List OrderItem
    , balances : List AccountBalance
    , error : Maybe String
    , connected : Bool
    , loadingBalances : Bool
    , pollOpenOrders : Bool
    , waitingOpenOrders : Bool
    }


type alias OrderItemsList =
    List OrderItem


type Msg
    = Tick
    | GotOpenOrders (Result Http.Error (List OrderItem))
    | GetAccountBalances
    | GotAccountBalances (Result Http.Error (List AccountBalance))
    | TogglePollOpenOrders
