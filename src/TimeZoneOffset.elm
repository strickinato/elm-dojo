module TimeZoneOffset exposing (TimeZoneOffset, asInt, decode, fromInt)

import Json.Decode as Decode exposing (Decoder)


type TimeZoneOffset
    = TimeZoneOffsetConstructor Int


fromInt : Int -> TimeZoneOffset
fromInt int =
    TimeZoneOffsetConstructor int


asInt : TimeZoneOffset -> Int
asInt (TimeZoneOffsetConstructor int) =
    int // 3600


asText : TimeZoneOffset -> String
asText tz =
    String.fromInt (asInt tz)


decode : Decoder TimeZoneOffset
decode =
    Decode.map fromInt Decode.int