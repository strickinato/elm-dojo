port module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes exposing (style)
import Html.Events exposing (onInput)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Task
import Time
import Time.Format
import Time.Format.Config.Config_en_us as UsConfig
import TimeZoneOffset exposing (TimeZoneOffset)
import User exposing (User)


main =
    Browser.element
        { init = initialModel
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


port decrypt : Encode.Value -> Cmd msg


port getDecrypted : (Encode.Value -> msg) -> Sub msg


type alias Model =
    { hashedSlackToken : String
    , authString : String
    , applicationData : ApplicationData
    , time : Time.Posix
    }


type ApplicationData
    = Fetching
    | HasData (List User)
    | Error Http.Error


type alias Flags =
    String


initialModel : Flags -> ( Model, Cmd Msg )
initialModel hashedSlackToken =
    ( { hashedSlackToken = hashedSlackToken
      , authString = ""
      , applicationData = Fetching
      , time = Time.millisToPosix 0
      }
    , initCmd
    )


initCmd : Cmd Msg
initCmd =
    Cmd.batch
        [ getTime
        , decrypt (Encode.string "secret key 123")
        ]


getTime : Cmd Msg
getTime =
    Task.perform NewTime Time.now


subscriptions : Model -> Sub Msg
subscriptions model =
    getDecrypted GotDecrypted


type Msg
    = NoOp
    | GotUsers (Result Http.Error (List User))
    | GotDecrypted Encode.Value
    | InputAuthString String
    | NewTime Time.Posix


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GotDecrypted decryptedApiToken ->
            let
                cmd =
                    decryptedApiToken
                        |> Decode.decodeValue Decode.string
                        |> Result.map getUsers
                        |> Result.withDefault Cmd.none
            in
            ( model, cmd )

        InputAuthString string ->
            ( { model | authString = string }
            , decrypt (Encode.string string)
            )

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

        NewTime posix ->
            ( { model | time = posix }, Cmd.none )


view : Model -> Html Msg
view model =
    case model.applicationData of
        Fetching ->
            Html.div []
                [ Html.text (String.fromInt (Time.toYear Time.utc model.time))
                , Html.text "Loading"
                , authInput model.authString
                ]

        HasData listUsers ->
            renderUsers model.time listUsers

        Error httpError ->
            Html.div []
                [ Html.text "Some error happened"
                , authInput model.authString
                ]


renderUsers : Time.Posix -> List User -> Html Msg
renderUsers posix users =
    users
        |> List.filter User.isActiveNonBot
        |> List.map (renderUser posix)
        |> Html.ul []

authInput : String -> Html Msg
authInput value =
    Html.input
        [ Html.Attributes.value value
        , onInput InputAuthString
        ]
        []


getUsers : String -> Cmd Msg
getUsers hashedSlackToken =
    Http.get
        { url = slackUserEndpoint hashedSlackToken
        , expect = Http.expectJson GotUsers User.decodeList
        }


newDisplay : Time.Posix -> TimeZoneOffset -> String
newDisplay posix timeZoneOffset =
    Time.Format.format UsConfig.config "%H:%M" (TimeZoneOffset.toTimeZone timeZoneOffset) posix


displayUserTime : Time.Posix -> TimeZoneOffset -> String
displayUserTime now userTimeOffset =
    let
        hour =
            Time.toHour Time.utc now
                + TimeZoneOffset.asInt userTimeOffset

        hourTime =
            modBy 12 hour

        minutes =
            Time.toMinute Time.utc now
    in
    String.fromInt hourTime ++ ":" ++ String.fromInt minutes


renderUser : Time.Posix -> User -> Html Msg
renderUser posix user =
    Html.li [style "list-style-type" "none"]
        [ Html.img [ Html.Attributes.src user.profilePic, Html.Attributes.alt user.name ] []
        , Html.span [ style "margin" "8px"] [ Html.text user.name ]
        , Html.text (newDisplay posix user.timeZoneOffset)
        ]


slackUserEndpoint : String -> String
slackUserEndpoint slackToken =
    String.concat
        [ "https://slack.com/api/users.list?token="
        , slackToken
        ]
