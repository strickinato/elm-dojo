module TimeZoneOffset exposing (TimeZoneOffset, asInt, decode, fromInt, toTimeZone)

import Time
import Json.Decode as Decode exposing (Decoder)


type TimeZoneOffset
    = TimeZoneOffsetConstructor Int


fromInt : Int -> TimeZoneOffset
fromInt int =
    TimeZoneOffsetConstructor int


asInt : TimeZoneOffset -> Int
asInt (TimeZoneOffsetConstructor int) =
    int * 60// 3600


asText : TimeZoneOffset -> String
asText tz =
    String.fromInt (asInt tz)

toTimeZone : TimeZoneOffset -> Time.Zone
toTimeZone timezoneOffset =
    Time.customZone (asInt timezoneOffset) []
     

decode : Decoder TimeZoneOffset
decode =
    Decode.map fromInt Decode.int
