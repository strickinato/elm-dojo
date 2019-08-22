module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes exposing (style, value)
import Html.Events exposing (onClick)
import List.Extra
import Random


type alias Model =
    { counter : Int
    , savedCounters : List SavedCounter
    , inputBoxText : String
    }


type alias SavedCounter =
    { name : String
    , number : Int
    , editing : Bool
    }


initialModel : () -> ( Model, Cmd Msg )
initialModel argumentIDontCareAbout =
    ( { counter = 0
      , savedCounters = []
      , inputBoxText = "input text here!"
      }
    , Random.generate GeneratedNumber randomNumber
    )


main =
    Browser.element
        { init = initialModel
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


type Msg
    = Increment
    | Decrement
    | Reset
    | SaveCurrentCounterValue
    | InputChanged String
    | GeneratedNumber Int
    | GenerateANewNumber
    | MakeCounterEditable Int


randomNumber : Random.Generator Int
randomNumber =
    Random.int -100 100


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( { model | counter = model.counter + 1 }
            , Cmd.none
            )

        Decrement ->
            ( { model | counter = model.counter - 1 }
            , Cmd.none
            )

        Reset ->
            ( { model | counter = 0 }
            , Cmd.none
            )

        GenerateANewNumber ->
            ( model
            , Random.generate GeneratedNumber randomNumber
            )

        SaveCurrentCounterValue ->
            let
                newCounter =
                    { number = model.counter
                    , name = model.inputBoxText
                    , editing = False
                    }
            in
            ( { model
                | savedCounters = newCounter :: model.savedCounters
                , inputBoxText = ""
              }
            , Cmd.none
            )

        InputChanged text ->
            ( { model | inputBoxText = text }
            , Cmd.none
            )

        GeneratedNumber int ->
            ( { model | counter = int }, Cmd.none )

        MakeCounterEditable index ->
            let
                newCounters =
                    List.Extra.updateAt
                        index
                        (\s -> { s | editing = True })
                        model.savedCounters
            in
            ( { model | savedCounters = newCounters }
            , Cmd.none
            )


makeEditable : SavedCounter -> SavedCounter
makeEditable savedCounter =
    { savedCounter | editing = True }


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.button [ onClick Increment ] [ Html.text "+" ]
        , Html.text (String.fromInt model.counter)
        , Html.button [ onClick Decrement ] [ Html.text "-" ]
        , Html.button [ onClick Reset ] [ Html.text "reset" ]
        , Html.button [ onClick SaveCurrentCounterValue ] [ Html.text "save" ]
        , Html.button [ onClick GenerateANewNumber ] [ Html.text "random number" ]
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
        |> List.indexedMap renderSavedCounter
        |> List.reverse
        |> Html.ul []


renderSavedCounter : Int -> SavedCounter -> Html Msg
renderSavedCounter idx savedCounter =
    let
        writtenArea =
            if savedCounter.editing then
                Html.input [ value savedCounter.name ] []

            else
                Html.text savedCounter.name
    in
    Html.li [ onClick (MakeCounterEditable idx) ]
        [ Html.text (String.fromInt savedCounter.number)
        , Html.text ", "
        , writtenArea
        ]
