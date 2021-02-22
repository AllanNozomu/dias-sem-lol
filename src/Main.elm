module Main exposing (..)

import Browser
import Html exposing (Html, div, h1, h3, li, span, text, ul, footer)
import Html.Attributes exposing (class)
import Http
import Json.Decode exposing (Decoder, field)
import Task
import Time



---- MODEL ----


secondConst : Int
secondConst =
    1000


minutesConst : Int
minutesConst =
    60 * secondConst


hoursconts : Int
hoursconts =
    60 * minutesConst


daysConst : Int
daysConst =
    24 * hoursconts


toStringMonth : Time.Month -> String
toStringMonth month =
    case month of
        Time.Jan ->
            "01"

        Time.Feb ->
            "02"

        Time.Mar ->
            "03"

        Time.Apr ->
            "04"

        Time.May ->
            "05"

        Time.Jun ->
            "06"

        Time.Jul ->
            "07"

        Time.Aug ->
            "08"

        Time.Sep ->
            "09"

        Time.Oct ->
            "10"

        Time.Nov ->
            "11"

        Time.Dec ->
            "12"


type Status
    = Failure
    | Loading
    | Success


type alias Period =
    { days : Int
    , hours : Int
    , minutes : Int
    , seconds : Int
    }


type alias Data =
    { lastPlayedInMillis : Int
    , lastUpdate : Int
    , longestSoFar : Int
    }


type alias Model =
    { data : Data
    , currentTime : Int
    , status : Status
    }


initModel : Model
initModel =
    Model
        (Data 0 0 0)
        0
        Loading


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.batch [ Task.perform Tick Time.now, getData ] )


dataDecoder : Decoder Data
dataDecoder =
    Json.Decode.map3 Data
        (field "lastPlayedInMillis" Json.Decode.int)
        (field "lastUpdate" Json.Decode.int)
        (field "longestSoFar" Json.Decode.int)


getData : Cmd Msg
getData =
    Http.get
        { url = "https://dias-sem-lol-default-rtdb.firebaseio.com/data.json"
        , expect = Http.expectJson GotData dataDecoder
        }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick



---- UPDATE ----


type Msg
    = Tick Time.Posix
    | GotData (Result Http.Error Data)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick newTime ->
            ( { model | currentTime = Time.posixToMillis newTime }, Cmd.none )

        GotData res ->
            case res of
                Ok data ->
                    ( { model | data = data, status = Success }, Cmd.none )

                Err _ ->
                    ( { model | status = Failure }, Cmd.none )



---- VIEW ----


getPeriod : Int -> Period
getPeriod t =
    let
        days =
            t // daysConst

        hours =
            remainderBy daysConst t // hoursconts

        minutes =
            remainderBy hoursconts t // minutesConst

        seconds =
            remainderBy minutesConst t // secondConst
    in
    Period days hours minutes seconds


view : Model -> Html Msg
view model =
    let
        diffTime =
            model.currentTime - model.data.lastPlayedInMillis

        diffPeriod =
            getPeriod diffTime

        recordPeriod =
            Basics.max model.data.longestSoFar diffTime |> getPeriod

        lastMatchPosix =
            Time.millisToPosix model.data.lastPlayedInMillis

        brazilZone =
            Time.customZone (-3 * 60) []
    in
    div [ ]
        [ h1 [] [ text "Nozomanu esta há " ]
        , ul []
            [ li []
                [ span [] [ text <| String.fromInt diffPeriod.days ]
                , text <|
                    if diffPeriod.days > 1 then
                        "DIAS"

                    else
                        "DIA"
                ]
            , li []
                [ span [] [ text <| String.fromInt diffPeriod.hours ]
                , text <|
                    if diffPeriod.hours > 1 then
                        "HORAS"

                    else
                        "HORA"
                ]
            , li []
                [ span [] [ text <| String.fromInt diffPeriod.minutes ]
                , text <|
                    if diffPeriod.minutes > 1 then
                        "MINUTOS"

                    else
                        "MINUTO"
                ]
            , li []
                [ span [] [ text <| String.fromInt diffPeriod.seconds ]
                , text <|
                    if diffPeriod.seconds > 1 then
                        "SEGUNDOS"

                    else
                        "SEGUNDO"
                ]
            ]
        , h1 [] [ text "sem jogar LOL" ]
        , h3 []
            [ text <|
                "Última partida foi em "
                    ++ String.fromInt (Time.toDay brazilZone lastMatchPosix)
                    ++ "/"
                    ++ toStringMonth (Time.toMonth brazilZone lastMatchPosix)
                    ++ "/"
                    ++ String.fromInt (Time.toYear brazilZone lastMatchPosix)
                    ++ " "
                    ++ String.fromInt (Time.toHour brazilZone lastMatchPosix)
                    ++ ":"
                    ++ String.fromInt (Time.toMinute brazilZone lastMatchPosix)
                    ++ ":"
                    ++ String.fromInt (Time.toSecond brazilZone lastMatchPosix)
            ]
        , h3 []
            [ text <|
                "O recorde atual é "
                    ++ String.fromInt recordPeriod.days
                    ++ " dias "
                    ++ String.fromInt recordPeriod.hours
                    ++ " horas "
                    ++ String.fromInt recordPeriod.minutes
                    ++ " minutos "
                    ++ String.fromInt recordPeriod.seconds
                    ++ " segundos "
            ]
        , footer [][
            text <|
                        "Última atualização ocorreu em "
                            ++ String.fromInt (Time.toDay brazilZone lastMatchPosix)
                            ++ "/"
                            ++ toStringMonth (Time.toMonth brazilZone lastMatchPosix)
                            ++ "/"
                            ++ String.fromInt (Time.toYear brazilZone lastMatchPosix)
                            ++ " "
                            ++ String.fromInt (Time.toHour brazilZone lastMatchPosix)
                            ++ ":"
                            ++ String.fromInt (Time.toMinute brazilZone lastMatchPosix)
                            ++ ":"
                            ++ String.fromInt (Time.toSecond brazilZone lastMatchPosix)
                ]
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = subscriptions
        }
