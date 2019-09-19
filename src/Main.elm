module Main exposing (main)

import Browser
import Html exposing (Html)


main =
    Browser.element
        { init = initialModel
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    {}


type alias Flags =
    String


initialModel : Flags -> ( Model, Cmd Msg )
initialModel slackToken =
    ( {}, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    Html.div [] [ Html.text "Fresh app!" ]
