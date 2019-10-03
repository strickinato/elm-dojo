module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (hardcoded, optional, required, requiredAt)



main =
    Browser.element
        { init = initialModel
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


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
    Sub.none


type Msg
    = NoOp
    | GotUsers (Result Http.Error (List User))


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

        HasData listUsers ->
            List.map renderUser listUsers
                |> Html.ul []

        Error httpError ->
            Html.text "Other error message"


getUsers : String -> String -> Cmd Msg
getUsers authString hashedSlackToken =
    Http.get
        { url = slackUserEndpoint authString hashedSlackToken
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


slackUserEndpoint : String -> String -> String
slackUserEndpoint authString hashedSlackToken =
    String.concat
        [ "https://slack.com/api/users.list?token="
        , hashedSlackToken
        ]
