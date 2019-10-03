port module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes
import Html.Events exposing (onInput)
import Http
import Json.Encode as Encode
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (hardcoded, optional, required, requiredAt)


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
      }
    , Cmd.none
    )

subscriptions : Model -> Sub Msg
subscriptions model =
    getDecrypted GotDecrypted


type Msg
    = NoOp
    | GotUsers (Result Http.Error (List User))
    | GotDecrypted Encode.Value
    | InputAuthString String


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
            (model, cmd)

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


view : Model -> Html Msg
view model =
    case model.applicationData of
        Fetching ->
            Html.div []
              [ Html.text "Loading"
              , authInput model.authString
              ]

        HasData listUsers ->
            List.map renderUser listUsers
                |> Html.ul []

        Error httpError ->
            Html.div []
              [ Html.text "Some error happened"
              , authInput model.authString
              ]


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
        , expect = Http.expectJson GotUsers usersDecoder
        }


usersDecoder : Decoder (List User)
usersDecoder =
    Decode.field "members" (Decode.list userDecoder)


userDecoder : Decoder User
userDecoder =
    Decode.succeed User
        |> required "name" Decode.string
        |> required "is_bot" Decode.bool
        |> requiredAt [ "profile", "image_24" ] Decode.string


type alias User =
    { name : String
    , bot : Bool
    , profilePic : String
    }


renderUser : User -> Html Msg
renderUser user =
    if user.bot then
        Html.li []
            [ Html.text "\u{1F916}"
            , Html.text user.name
            ]

    else
        Html.li []
            [ Html.img [ Html.Attributes.src user.profilePic, Html.Attributes.alt user.name ] []
            , Html.text user.name
            ]


slackUserEndpoint : String -> String
slackUserEndpoint slackToken =
    String.concat
        [ "https://slack.com/api/users.list?token="
        , slackToken
        ]
