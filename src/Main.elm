module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes exposing (style, value)
import Html.Events exposing (onClick)


type alias Model =
    { counter : Int
    , savedCounters : List SavedCounter
    , inputBoxText : String
    }


type alias SavedCounter =
    { name : String
    , number : Int
    }


initialModel : Model
initialModel =
    { counter = 0
    , savedCounters = []
    , inputBoxText = "input text here!"
    }


main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }


type Msg
    = Increment
    | Decrement
    | Reset
    | SaveCurrentCounterValue
    | InputChanged String


update : Msg -> Model -> Model
update dog model =
    case dog of
        Increment ->
            { model | counter = model.counter + 1 }

        Decrement ->
            { model | counter = model.counter - 1 }

        Reset ->
            { model | counter = 0 }

        SaveCurrentCounterValue ->
            let
                newCounter =
                    { number = model.counter
                    , name = model.inputBoxText
                    }
            in
            { model
                | savedCounters = newCounter :: model.savedCounters
                , inputBoxText = ""
            }

        InputChanged text ->
            { model | inputBoxText = text }


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.button [ onClick Increment ] [ Html.text "+" ]
        , Html.text (String.fromInt model.counter)
        , Html.button [ onClick Decrement ] [ Html.text "-" ]
        , Html.button [ onClick Reset ] [ Html.text "reset" ]
        , Html.button [ onClick SaveCurrentCounterValue ] [ Html.text "save" ]
        , Html.input
            [ value model.inputBoxText
            , Html.Events.onInput InputChanged
            ]
            []
        , renderSavedCounters model.savedCounters
        ]


renderSavedCounters : List SavedCounter -> Html Msg
renderSavedCounters savedCounters =
    savedCounters
        |> List.reverse
        |> List.map renderSavedCounter
        |> Html.ul []


renderSavedCounter : SavedCounter -> Html Msg
renderSavedCounter savedCounter =
    Html.li []
        [ Html.text (String.fromInt savedCounter.number)
        , Html.text ", "
        , Html.text savedCounter.name
        ]
