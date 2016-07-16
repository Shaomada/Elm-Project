module Main exposing (..)

import Display
import Game
import GameModel
import Editor
import Menue
import Level
import LevelData
import Shared
import Html
import Html.App
import Element
import Window
import Task.Extra


main : Program Never
main =
    Html.App.program
        { init = init ! [ Task.Extra.performFailproof (DisplayMsg << Display.WindowResize) Window.size ]
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type State
    = Playing
    | Editing
    | InMenue


type alias Model =
    { display : Display.Model
    , game : GameModel.Model
    , editor : Editor.Model
    , menue : Menue.Model
    , state : State
    }


init : Model
init =
    { display = Display.init
    , game = Level.level 0
    , editor = Editor.init
    , menue = Menue.init
    , state = InMenue
    }



-- UPDATE


type Msg
    = DisplayMsg Display.Msg
    | GameMsg Game.Msg
    | EditorMsg Editor.Msg
    | MenueMsg Menue.Msg


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

                MenueMsg menueMsg ->
                    let
                        ( menue', x ) =
                            Menue.update menueMsg model.menue
                    in
                        ( { model | menue = menue' }, x )
    in
        case msg' of
            Shared.EndUpdate ->
                model' ! []

            Shared.MouseMoved pos ->
                case model.state of
                    Playing ->
                        update (GameMsg <| Game.MouseMoved { x = pos.x, y = pos.y }) model'

                    Editing ->
                        update (EditorMsg <| Editor.MouseMoved pos) model'

                    _ ->
                        model ! []

            Shared.ResetViewPosition pos ->
                update (DisplayMsg <| Display.ResetViewPosition pos) model'

            Shared.Launch ->
                { model | game = LevelData.finalise -1 model.editor.level, state = Playing } ! []

            Shared.OpenEditor ->
                { model | state = Editing } ! []

            Shared.Play ->
                { model | state = Playing } ! []

            Shared.Menue ->
                init ! []



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    [ Sub.map DisplayMsg <| Display.subscriptions model.display
    , case model.state of
        Playing ->
            Sub.map GameMsg <| Game.subscriptions model.game

        Editing ->
            Sub.map EditorMsg <| Editor.subscriptions model.editor

        InMenue ->
            Sub.map MenueMsg <| Menue.subscriptions model.menue
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

        InMenue ->
            Menue.view model.menue
    )
        |> Display.view model.display
        |> Element.toHtml
