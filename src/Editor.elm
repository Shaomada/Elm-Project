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
    , mousePosition : { x : Float, y : Float, xRaw : Float, yRaw : Float }
    , subwindowPosition : { x : Float, y : Float }
    , state : State
    }


type State
    = NoOp
    | DraggingSubwindow
    | DraggingThing Int
    | FocusedThing Int
    | Launch
    | Menue


init : Model
init =
    { level = LevelSyntax.text "press n at any time to return to the Editor" <| LevelSyntax.empty
    , mousePosition = { x = 0, y = 0, xRaw = 0, yRaw = 0 }
    , subwindowPosition = { x = 400, y = 200 }
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
    , { name = "Add Block"
      , condition = \model -> model.state == NoOp
      , onClick = \model -> { model | level = LevelSyntax.block model.mousePosition.x model.mousePosition.y model.level, state = DraggingThing 0 }
      }
    , { name = "Add Enemy"
      , condition = \model -> model.state == NoOp
      , onClick = \model -> { model | level = LevelSyntax.enemy model.mousePosition.x model.mousePosition.y model.level, state = DraggingThing 0 }
      }
    , { name = "Zone Player"
      , condition = \model -> model.state == NoOp
      , onClick = \model -> { model | level = LevelSyntax.asZone <| LevelSyntax.player model.mousePosition.x model.mousePosition.y model.level, state = DraggingThing 0 }
      }
    , { name = "Zone Bouncy"
      , condition = \model -> model.state == NoOp
      , onClick = \model -> { model | level = LevelSyntax.asZone <| LevelSyntax.bouncy model.mousePosition.x model.mousePosition.y model.level, state = DraggingThing 0 }
      }
    , { name = "Zone Enemy"
      , condition = \model -> model.state == NoOp
      , onClick = \model -> { model | level = LevelSyntax.asZone <| LevelSyntax.enemy model.mousePosition.x model.mousePosition.y model.level, state = DraggingThing 0 }
      }
    , { name = "Zone Dead"
      , condition = \model -> model.state == NoOp
      , onClick = \model -> { model | level = LevelSyntax.asZone <| LevelSyntax.asDead <| LevelSyntax.player model.mousePosition.x model.mousePosition.y model.level, state = DraggingThing 0 }
      }
    , { name = "Menue"
      , condition = \model -> model.state == NoOp
      , onClick = \model -> { model | state = Menue }
      }
    , { name = "Play Level"
      , condition = \model -> model.state == NoOp
      , onClick = \model -> { model | state = Launch }
      }
    , { name = "Delete"
      , condition =
            \model ->
                case model.state of
                    FocusedThing i ->
                        True

                    _ ->
                        False
      , onClick =
            \({ level } as model) ->
                case model.state of
                    FocusedThing i ->
                        { model
                            | level =
                                { level
                                    | things =
                                        level.things
                                            |> List.indexedMap
                                                (\j t ->
                                                    if i == j then
                                                        Nothing
                                                    else
                                                        Just t
                                                )
                                            |> List.filterMap identity
                                }
                        }

                    _ ->
                        model
      }
    , { name = "+ Radius"
      , condition =
            \model ->
                case model.state of
                    FocusedThing i ->
                        True

                    _ ->
                        False
      , onClick =
            \({ level } as model) ->
                case model.state of
                    FocusedThing i ->
                        { model
                            | level =
                                { level
                                    | things =
                                        level.things
                                            |> List.indexedMap
                                                (\j t ->
                                                    if i == j then
                                                        { t | radius = t.radius * 1.1 }
                                                    else
                                                        t
                                                )
                                }
                        }

                    _ ->
                        model
      }
    , { name = "- Radius"
      , condition =
            \model ->
                case model.state of
                    FocusedThing i ->
                        True

                    _ ->
                        False
      , onClick =
            \({ level } as model) ->
                case model.state of
                    FocusedThing i ->
                        { model
                            | level =
                                { level
                                    | things =
                                        level.things
                                            |> List.indexedMap
                                                (\j t ->
                                                    if i == j then
                                                        { t | radius = t.radius / 1.1 }
                                                    else
                                                        t
                                                )
                                }
                        }

                    _ ->
                        model
      }
    ]


currButtons : Model -> List Button
currButtons model =
    List.filter (\button -> button.condition model) buttons


midOfButton : Model -> Int -> ( Float, Float )
midOfButton model i =
    ( model.subwindowPosition.x + buttonWidth / 2
    , model.subwindowPosition.y - buttonHeight / 2 - buttonHeight * toFloat i
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
            model.subwindowPosition.y - (toFloat length) * buttonHeight / 2 + heightHead / 2
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
            model.mousePosition.xRaw - model.subwindowPosition.x

        y =
            model.subwindowPosition.y - model.mousePosition.yRaw

        i =
            floor <| y / buttonHeight
    in
        if y >= 0 - buttonHeight * heightHead && y < buttonHeight * toFloat length && x >= 0 && x < buttonWidth then
            if y < 0 then
                Just { model | state = DraggingSubwindow }
            else
                buttons
                    |> List.drop i
                    |> List.head
                    |> Maybe.map (\button -> Just <| button.onClick model)
                    |> Maybe.withDefault Nothing
        else
            Nothing



-- UPDATE --


type Msg
    = MouseDown
    | MouseUp
    | MouseMoved { x : Float, y : Float, xRaw : Float, yRaw : Float }


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

                                DraggingSubwindow ->
                                    NoOp

                                _ ->
                                    model.state
                    }

                MouseMoved { x, y, xRaw, yRaw } ->
                    case model.state of
                        DraggingThing i ->
                            { model
                                | mousePosition = { x = x, y = y, xRaw = xRaw, yRaw = yRaw }
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
                                | mousePosition = { x = x, y = y, xRaw = xRaw, yRaw = yRaw }
                                , subwindowPosition =
                                    { x = model.subwindowPosition.x + xRaw - model.mousePosition.xRaw
                                    , y = model.subwindowPosition.y + yRaw - model.mousePosition.yRaw
                                    }
                            }

                        _ ->
                            { model | mousePosition = { x = x, y = y, xRaw = xRaw, yRaw = yRaw } }
    in
        ( model'
        , if model'.state == Launch then
            Shared.Launch
          else if model'.state == Menue then
            Shared.Menue
          else
            Shared.EndUpdate
        )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Mouse.downs (\_ -> MouseDown)
        , Mouse.ups (\_ -> MouseUp)
        ]



-- VIEW


viewFocused : Model -> List Collage.Form
viewFocused model =
    case model.state of
        FocusedThing i ->
            model.level.things
                |> List.indexedMap
                    (\j t ->
                        if i == j then
                            [ Thing.viewBoundry t ]
                        else
                            []
                    )
                |> List.concat

        _ ->
            []


view : Model -> ( List Collage.Form, List Collage.Form )
view model =
    ( List.concat
        [ List.map Thing.viewBody model.level.things
        , viewFocused model
        ]
    , showSubwindow model
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
