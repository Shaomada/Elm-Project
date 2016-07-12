module Editor exposing (..)

import Collage
import Text
import Geometry
import LevelSyntax
import GameModel
import Game
import Thing
import Shared
import Mouse
import List
import Color


type alias Model =
    { level : LevelSyntax.Model
    , mousePosition : { x : Float, y : Float }
    , subwindowPosition : { x : Float, y : Float }
    , state : State
    }


type State
    = NoOp
    | DraggingSubwindow
    | DraggingThing Int
    | FocusedThing Int


init : Model
init =
    { level = LevelSyntax.bouncy 100 100 <| LevelSyntax.player 0 0 <| LevelSyntax.empty
    , mousePosition = { x = 0, y = 0 }
    , subwindowPosition = { x = 0, y = 0 }
    , state = NoOp
    }



-- BUTTONS


type alias Button =
    { name : String
    , condition : Model -> Bool
    , onClick : Model -> Model
    }


buttonWidth : Float
buttonWidth =
    100


buttonHeight : Float
buttonHeight =
    50


heightHead : Float
heightHead =
    25


buttons : List Button
buttons =
    [ { name = "Add Player"
      , condition = \model -> model.state == NoOp
      , onClick = \model -> { model | level = LevelSyntax.player model.mousePosition.x model.mousePosition.y model.level, state = DraggingThing 0 }
      }
    , { name = "Add Bouncy"
      , condition = \model -> model.state == NoOp
      , onClick = \model -> { model | level = LevelSyntax.bouncy model.mousePosition.x model.mousePosition.y model.level, state = DraggingThing 0 }
      }
    ]


currButtons : Model -> List Button
currButtons model =
    List.filter (\button -> button.condition model) buttons


midOfButton : Model -> Int -> ( Float, Float )
midOfButton model i =
    ( model.subwindowPosition.x + buttonWidth / 2
    , model.subwindowPosition.y + buttonHeight / 2 + buttonHeight * toFloat i
    )


showButton : Model -> Int -> Button -> List Collage.Form
showButton model i button =
    [ Collage.rect buttonWidth buttonHeight
        |> Collage.outlined Collage.defaultLine
        |> Collage.move (midOfButton model i)
    , Text.fromString button.name
        |> Collage.text
        |> Collage.move (midOfButton model i)
    ]


showSubwindow : Model -> List Collage.Form
showSubwindow model =
    let
        buttons =
            currButtons model

        length =
            List.length buttons

        x =
            model.subwindowPosition.x + buttonWidth / 2

        y =
            model.subwindowPosition.y + (toFloat length) * buttonHeight / 2 + heightHead / 2
    in
        buttons
            |> List.indexedMap (showButton model)
            |> List.concat
            |> List.append
                [ Collage.rect buttonWidth (heightHead + buttonHeight * toFloat length)
                    |> Collage.filled Color.gray
                    |> Collage.move ( x, y )
                ]


buttonClick : Model -> Maybe Model
buttonClick model =
    let
        buttons =
            currButtons model

        length =
            List.length buttons

        x =
            model.mousePosition.x - model.subwindowPosition.x

        y =
            model.mousePosition.y - model.subwindowPosition.y

        i =
            floor <| y / buttonHeight
    in
        if y >= 0 && y < buttonHeight * toFloat length + heightHead && x >= 0 && x < buttonWidth then
            buttons
                |> List.drop i
                |> List.head
                |> Maybe.map (\button -> Just <| button.onClick model)
                |> Maybe.withDefault (Just { model | state = DraggingSubwindow })
        else
            Nothing



-- UPDATE --


type Msg
    = MouseDown
    | MouseUp
    | MouseMoved { x : Float, y : Float }


update : Msg -> Model -> ( Model, Shared.Msg )
update msg ({ level } as model) =
    let
        model' =
            case msg of
                MouseDown ->
                    buttonClick model
                        |> Maybe.withDefault
                            { model
                                | state =
                                    (List.indexedMap
                                        (\i t ->
                                            if Geometry.distance model.mousePosition t < t.radius then
                                                Just i
                                            else
                                                Nothing
                                        )
                                        model.level.things
                                    )
                                        |> Maybe.oneOf
                                        |> Maybe.map DraggingThing
                                        |> Maybe.withDefault NoOp
                            }

                MouseUp ->
                    { model
                        | state =
                            case model.state of
                                DraggingThing i ->
                                    FocusedThing i

                                _ ->
                                    NoOp
                    }

                MouseMoved { x, y } ->
                    case model.state of
                        DraggingThing i ->
                            { model
                                | mousePosition = { x = x, y = y }
                                , level =
                                    { level
                                        | things =
                                            List.indexedMap
                                                (\j t ->
                                                    if i /= j then
                                                        t
                                                    else
                                                        { t
                                                            | x = t.x + x - model.mousePosition.x
                                                            , y = t.y + y - model.mousePosition.y
                                                        }
                                                )
                                                level.things
                                    }
                            }

                        DraggingSubwindow ->
                            { model
                                | mousePosition = { x = x, y = y }
                                , subwindowPosition =
                                    { x = model.subwindowPosition.x + x - model.mousePosition.x
                                    , y = model.subwindowPosition.y + y - model.mousePosition.y
                                    }
                            }

                        _ ->
                            { model | mousePosition = { x = x, y = y } }
    in
        ( model', Shared.EndUpdate )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Mouse.downs (\_ -> MouseDown)
        , Mouse.ups (\_ -> MouseUp)
        ]



-- VIEW


view : Model -> ( List Collage.Form, List Collage.Form )
view model =
    ( List.append (List.map Thing.viewBody model.level.things)
        (showSubwindow model)
    , []
    )



{--
eval : Model -> List (LevelData.Command)
eval model =
    append (List.concatMap Object.eval model.objects) (List.map LevelData.text model.text)
        |> List.filterMap idenity


toGameModel : Model -> GameModel
toGameModel model =
    foldl (<|) LevelData.empty <| eval model


toString : Model -> String
toString model =
    "   [ empty\n"
    ++
--}
