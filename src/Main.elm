module Main exposing (..)

import Display
import Game
import GameModel
import Editor
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


type State
    = Playing
    | Editing


type alias Model =
    { display : Display.Model
    , game : GameModel.Model
    , editor : Editor.Model
    , state : State
    }


init : Model
init =
    { display = Display.init
    , game = Level.level 0
    , editor = Editor.init
    , state = Editing
    }



-- UPDATE


type Msg
    = DisplayMsg Display.Msg
    | GameMsg Game.Msg
    | EditorMsg Editor.Msg


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

                EditorMsg editorMsg ->
                    let
                        ( editor', x ) =
                            Editor.update editorMsg model.editor
                    in
                        ( { model | editor = editor' }, x )
    in
        case msg' of
            Shared.EndUpdate ->
                model' ! []

            Shared.MouseMoved pos ->
                case model.state of
                    Playing ->
                        update (GameMsg <| Game.MouseMoved pos) model'

                    Editing ->
                        update (EditorMsg <| Editor.MouseMoved pos) model'

            Shared.ResetViewPosition pos ->
                update (DisplayMsg <| Display.ResetViewPosition pos) model'



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    [ Sub.map DisplayMsg <| Display.subscriptions model.display
    , case model.state of
        Playing ->
            Sub.map GameMsg <| Game.subscriptions model.game

        Editing ->
            Sub.map EditorMsg <| Editor.subscriptions model.editor
    ]
        |> Sub.batch



-- VIEW


view : Model -> Html.Html Msg
view model =
    (case model.state of
        Playing ->
            Game.view model.game

        Editing ->
            Editor.view model.editor
    )
        |> Display.view model.display
        |> Element.toHtml
