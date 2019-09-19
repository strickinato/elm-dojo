module Main exposing (main)

import Browser
import Html exposing (Html)
import Http
import Json.Decode as Decode exposing (Decoder)


main =
    Browser.element
        { init = initialModel
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { slackToken : String
    , applicationData : ApplicationData
    }


type ApplicationData
    = Fetching
    | HasData String
    | Error Http.Error


type alias Flags =
    String


initialModel : Flags -> ( Model, Cmd Msg )
initialModel slackToken =
    ( { slackToken = slackToken
      , applicationData = Fetching
      }
    , getUsers slackToken
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


type Msg
    = NoOp
    | GotUsers (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GotUsers result ->
            let
                data =
                    case result of
                        Ok response ->
                            HasData response

                        Err httpError ->
                            Error httpError
            in
            ( { model | applicationData = data }
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    case model.applicationData of
        Fetching ->
            Html.text "Loading"

        HasData string ->
            Html.div [] [ Html.text string ]

        Error httpError ->
            Html.text "SOMETHING IS MESSED UP"


getUsers : String -> Cmd Msg
getUsers token =
    Http.get
        { url = slackUserEndpoint token
        , expect = Http.expectJson GotUsers usersDecoder
        }


{-|

    What's wrong with this?
        - We're getting back real data... and we'd expect to be able to decode it into a string
        - We're saying "We expect the value of the HTTP response will be a string"
        - However, we're doing Decode.value.
        - Under the hood, the Http package accounts for *not* decoding properly
          by wrapping it into the BadBody error type
        - See: https://package.elm-lang.org/packages/elm/http/latest/Http#Error

-}
usersDecoder : Decoder String
usersDecoder =
    Decode.string


slackUserEndpoint : String -> String
slackUserEndpoint token =
    String.concat
        [ "https://slack.com/api/users.list?token="
        , token
        ]
