module Dashboard exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)


-- model


type alias Model =
    { apiKey : String
    , apiSecret : String
    }


initialModel : Model
initialModel =
    Model "" ""


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )



-- update


type Msg
    = UpdateApiKey String
    | UpdateApiSecret String
    | Submit


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateApiKey key ->
            ( { model | apiKey = key }, Cmd.none )

        UpdateApiSecret secret ->
            ( { model | apiSecret = secret }, Cmd.none )

        _ ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "row" ]
            [ div [ class "col-sm-6 col-md-offset-3" ]
                [ h3 [] [ text "Add your credentials to start" ]
                , div [ class "form-group" ]
                    [ label [] [ text "API Key" ]
                    , input [ class "form-control" ] []
                    ]
                , div [ class "form-group" ]
                    [ label [] [ text "API Secret" ]
                    , input [ class "form-control" ] []
                    ]
                , div [ class "form-group" ]
                    [ button [ class "btn btn-danger btn-block" ] [ text "Go" ]
                    ]
                ]
            ]
        ]
