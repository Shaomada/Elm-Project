module Game exposing (..)

import Thing
import LevelData

import Array
import Keyboard
import AnimationFrame
import Time
import Char
import Collage
import Text
import Color
import Random

-- MODEL

type alias Model =
    {   things : List Thing.Model
    ,   state : GameState
    ,   level : Int
    ,   text : List String
    }

type GameState
    = Won
    | Running
    | Paused

init : Model
init = level 0

level : Int -> Model
level i =
    Array.get i LevelData.levelData
    |> Maybe.withDefault LevelData.invalidLevel
    |> createLevel i

createLevel : Int -> ( List Thing.Model, List String ) -> Model
createLevel i ( things, text ) =
    {   things = things
    ,   state = Paused
    ,   level = i
    ,   text = text
    }

-- UPDATE

type Msg
    = Interactions
    | LoadLevel Int
    | KeyDown Char
    | KeyUp Char
    | MouseMoved { x : Float, y : Float }
    | TimeDiff Float
    | ResetViewPosition -- OUTPUT

toCmd : Msg -> Cmd Msg
toCmd msg = Random.generate identity (Random.map (\_ -> msg) Random.bool)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (msg, model.state) of
        (ResetViewPosition, _) -> model ! []

        (Interactions, Running) -> 
            let
                (things, won) = case model.things of
                    [] -> ([], False)
                    x::xs -> recurse [] x xs
            in
                { model |
                    things = things
                ,   state = if won then Won else Running
                } ! []
        (Interactions, _) -> model ! []

        (LoadLevel id, _) -> (level id) ! [toCmd ResetViewPosition]

        (KeyDown c, Won) ->
            case c of
                'N' -> model ! [toCmd <| LoadLevel <| model.level + 1]
                'R' -> model ! [toCmd <| LoadLevel model.level]
                _ -> model ! []
        (KeyDown c, Running) ->
            case c of
                'R' -> model ! [toCmd <| LoadLevel model.level]
                ' ' -> { model | state = Paused } ! []
                _ ->
                    { model |
                        things = List.map (Thing.update <| Thing.KeyDown c) model.things
                    } ! []
        (KeyDown c, Paused) ->
            case c of
                'R' -> model ! [toCmd <| LoadLevel model.level]
                ' ' -> { model | state = Running } ! []
                _ ->
                    { model |
                        things = List.map (Thing.update <| Thing.KeyDown c) model.things
                    } ! []

        (KeyUp c, Won) ->
            model ! []
        (KeyUp c, _) ->
            { model |
                things = List.map (Thing.update <| Thing.KeyUp c) model.things
            } ! []

        (MouseMoved pos, Won) ->
            model ! []
        (MouseMoved pos, _) ->
            { model |
                things = List.map (Thing.update <|Thing.MouseMoved pos) model.things
            } ! []

        (TimeDiff t, Running) ->
            { model |
                things = List.map (Thing.update <| Thing.TimeDiff t) model.things
            } ! [toCmd Interactions]
        (TimeDiff t, _) ->
            model ! []


recurse : List Thing.Model -> Thing.Model -> List Thing.Model -> (List Thing.Model, Bool)
recurse before current after =
    let
        thing = List.foldl
            Thing.interact
            current
            (List.append before after)
        (things, won) = case after of
            [] -> ([], True)
            x::xs -> recurse (List.append before [current]) x xs
        won' = case thing.id of
            Thing.Zone {pattern, done} -> done
            _ -> True
    in
        (thing :: things, won' && won)

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    [ Keyboard.downs <| KeyDown << Char.fromCode
    , Keyboard.ups <| KeyUp << Char.fromCode
    , AnimationFrame.diffs <| TimeDiff << Time.inSeconds
    ]
        |> Sub.batch


-- VIEW

view : Model -> (List Collage.Form, List Collage.Form)
view { things, state, text } =
    (   List.map (\layer -> List.map (Thing.view layer) things) [0, 1, 2, 3]
        |> List.concat
    , message state text
    )

message : GameState -> List String -> List Collage.Form
message state text = case state of
    Won ->
        [ "Victory"
            |> Text.fromString
            |> Text.style
                { typeface = []
                , height = Just 100
                , color = Color.lightPurple
                , bold = True
                , italic = False
                , line = Nothing
                }
            |> Collage.text
            |> Collage.alpha 0.8
        , "Press n to proceed to the next Level"
            |> Text.fromString
            |> Text.style
                { typeface = []
                , height = Just 30
                , color = Color.lightPurple
                , bold = False
                , italic = False
                , line = Nothing
                }
            |> Collage.text
            |> Collage.alpha 0.8
            |> Collage.move ( 0, -100 )
        ]
    Running ->
        text
            |> List.indexedMap
                (\line message ->
                    message
                        |> Text.fromString
                        |> Text.style
                            { typeface = []
                            , height = Just 30
                            , color = Color.lightPurple
                            , bold = False
                            , italic = False
                            , line = Nothing
                            }
                        |> Collage.text
                        |> Collage.alpha 0.8
                        |> Collage.move ( 0, -40 * toFloat (3 + line) )
                )
    Paused ->
        [   "Paused"
            |> Text.fromString
            |> Text.style
                { typeface = []
                , height = Just 100
                , color = Color.lightPurple
                , bold = True
                , italic = False
                , line = Nothing
                }
            |> Collage.text
            |> Collage.alpha 0.8
        ,   "Press Space to Unpause"
            |> Text.fromString
            |> Text.style
                { typeface = []
                , height = Just 30
                , color = Color.lightPurple
                , bold = False
                , italic = False
                , line = Nothing
                }
            |> Collage.text
            |> Collage.alpha 0.8
            |> Collage.move ( 0, -100 )
        ]