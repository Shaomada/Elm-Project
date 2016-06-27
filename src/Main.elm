module Main exposing (..)

import Display
import Game
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
    , game : Game.Model
    }


init : Model
init =
    { display = Display.init
    , game = Game.init
    }



-- UPDATE


type Msg
    = DisplayMsg Display.Msg
    | GameMsg Game.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- Output Msg's
        GameMsg (Game.ResetViewPosition) ->
            update (DisplayMsg <| Display.ResetViewPosition { x = 0, y = 0 }) model

        DisplayMsg (Display.MouseMoved pos) ->
            update (GameMsg <| Game.MouseMoved pos) model

        -- Input Msg's
        DisplayMsg msg' ->
            let
                ( display, cmd ) =
                    Display.update msg' model.display
            in
                ( { model | display = display }, Cmd.map DisplayMsg cmd )

        GameMsg msg' ->
            let
                ( game, cmd ) =
                    Game.update msg' model.game
            in
                ( { model | game = game }, Cmd.map GameMsg cmd )



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
