module Main exposing (..)

import Display
import Game
import GameModel
import Level
import Shared
import Html
import Html.App
import Element


main : Program Never
main =
    Html.App.program
        { init = init ! []
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { display : Display.Model
    , game : GameModel.Model
    }


init : Model
init =
    { display = Display.init
    , game = Level.level 0
    }



-- UPDATE


type Msg
    = DisplayMsg Display.Msg
    | GameMsg Game.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        ( model', msg' ) =
            case msg of
                DisplayMsg displayMsg ->
                    let
                        ( display', x ) =
                            Display.update displayMsg model.display
                    in
                        ( { model | display = display' }, x )

                GameMsg gameMsg ->
                    let
                        ( game', x ) =
                            Game.update gameMsg model.game
                    in
                        ( { model | game = game' }, x )
    in
        case msg' of
            Shared.EndUpdate ->
                model' ! []

            Shared.MouseMoved pos ->
                update (GameMsg <| Game.MouseMoved pos) model'

            Shared.ResetViewPosition pos ->
                update (DisplayMsg <| Display.ResetViewPosition pos) model'



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    [ Sub.map DisplayMsg <| Display.subscriptions model.display
    , Sub.map GameMsg <| Game.subscriptions model.game
    ]
        |> Sub.batch



-- VIEW


view : Model -> Html.Html Msg
view model =
    Game.view model.game
        |> Display.view model.display
        |> Element.toHtml
