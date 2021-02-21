module Main exposing (..)

import Browser
import Html exposing (Html, div, h1, li, span, text, ul)
import Html.Attributes exposing (class)
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


lastPlayedTimeMillis : Int
lastPlayedTimeMillis =
    1613846619000


type alias Model =
    { lastTime : Int
    , currentTime : Int
    }


initModel : Model
initModel =
    Model
        lastPlayedTimeMillis
        0


init : ( Model, Cmd Msg )
init =
    ( initModel, Task.perform Tick Time.now )



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
    div [ class "container" ]
        [ h1 [] [ text "Nozomanu esta há " ]
        , ul []
            [ li [] [ span [] [ text <| days ], text "DIAS" ]
            , li [] [ span [] [ text <| hours ], text "HORAS" ]
            , li [] [ span [] [ text <| minutes ], text "MINUTOS" ]
            , li [] [ span [] [ text <| seconds ], text "SEGUNDOS" ]
            ]
        , h1 [] [ text "sem jogar LOL" ]
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
