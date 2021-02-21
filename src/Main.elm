module Main exposing (..)

import Browser
import Html exposing (Html, div, h1, li, text, ul)
import Html.Attributes exposing (src)
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


lastPlayedTimeMillis : Int
lastPlayedTimeMillis =
    1613846619000


type alias Model =
    { lastTime : Int
    , currentTime : Int
    }


init : ( Model, Cmd Msg )
init =
    ( Model lastPlayedTimeMillis 0, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick



---- UPDATE ----


type Msg
    = Tick Time.Posix


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick newTime ->
            ( { model | currentTime = Time.posixToMillis newTime }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    let
        diffTime =
            model.currentTime - model.lastTime

        days =
            String.fromInt <| diffTime // daysConst

        hours =
            String.fromInt <| remainderBy daysConst diffTime // hoursconts

        minutes =
            String.fromInt <| remainderBy hoursconts diffTime // minutesConst

        seconds =
            String.fromInt <| remainderBy minutesConst diffTime // secondConst
    in
    div []
        [ h1 [] [ text <| String.fromInt model.currentTime ]
        , h1 [] [ text <| String.fromInt model.lastTime ]
        , ul []
            [ li [] [ text <| "DIAS " ++ days ]
            , li [] [ text <| "HORAS " ++ hours ]
            , li [] [ text <| "MINUTOS " ++ minutes ]
            , li [] [ text <| "SEGUNDOS " ++ seconds ]
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
