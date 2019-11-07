module User exposing (User, decode, decodeList, isActiveNonBot)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (hardcoded, optional, required, requiredAt)
import TimeZoneOffset exposing (TimeZoneOffset)


type alias User =
    { name : String
    , bot : Bool
    , profilePic : String
    , deleted : Bool
    , timeZoneOffset : TimeZoneOffset
    }


isActiveNonBot : User -> Bool
isActiveNonBot user =
    not user.bot && not user.deleted


decodeList : Decoder (List User)
decodeList =
    Decode.field "members" (Decode.list decode)


defaultTimezone : TimeZoneOffset
defaultTimezone =
    TimeZoneOffset.fromInt -25200


decode : Decoder User
decode =
    Decode.succeed User
        |> required "name" Decode.string
        |> required "is_bot" Decode.bool
        |> requiredAt [ "profile", "image_24" ] Decode.string
        |> required "deleted" Decode.bool
        |> optional "tz_offset" TimeZoneOffset.decode defaultTimezone
