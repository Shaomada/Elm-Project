module Game exposing (..)

import GameModel exposing (..)
import Level
import Shared exposing (only, andThen)
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


-- UPDATE


type Msg
    = Interactions
    | LoadLevel Int
    | KeyDown Char
    | KeyUp Char
    | MouseMoved { x : Float, y : Float }
    | TimeDiff Float


update : Msg -> Model -> ( Model, Shared.Msg )
update msg model =
    case ( msg, model.state ) of
        ( Interactions, Running ) ->
            let
                ( things, won ) =
                    case model.things of
                        [] ->
                            ( [], False )

                        x :: xs ->
                            recurse [] x xs
            in
                only
                    { model
                        | things = things
                        , state =
                            if won then
                                Won
                            else
                                Running
                    }

        ( Interactions, _ ) ->
            only model

        ( LoadLevel id, _ ) ->
            andThen (Level.level id)
                <| Shared.ResetViewPosition { x = 0, y = 0 }

        ( KeyDown c, Won ) ->
            case c of
                'N' ->
                    update (LoadLevel <| model.level + 1) model

                'R' ->
                    update (LoadLevel model.level) model

                _ ->
                    only model

        ( KeyDown c, Running ) ->
            case c of
                'R' ->
                    update (LoadLevel model.level) model

                ' ' ->
                    only { model | state = Paused }

                _ ->
                    only
                        { model
                            | things = List.map (Thing.update <| Thing.KeyDown c) model.things
                        }

        ( KeyDown c, Paused ) ->
            case c of
                'R' ->
                    update (LoadLevel model.level) model

                ' ' ->
                    only { model | state = Running }

                _ ->
                    only
                        { model
                            | things = List.map (Thing.update <| Thing.KeyDown c) model.things
                        }

        ( KeyUp c, Won ) ->
            only model

        ( KeyUp c, _ ) ->
            only
                { model
                    | things = List.map (Thing.update <| Thing.KeyUp c) model.things
                }

        ( MouseMoved pos, Won ) ->
            only model

        ( MouseMoved pos, _ ) ->
            only
                { model
                    | things = List.map (Thing.update <| Thing.MouseMoved pos) model.things
                }

        ( TimeDiff t, Running ) ->
            update Interactions
                { model
                    | things = List.map (Thing.update <| Thing.TimeDiff t) model.things
                }

        ( TimeDiff t, _ ) ->
            only model


recurse : List Thing.Model -> Thing.Model -> List Thing.Model -> ( List Thing.Model, Bool )
recurse before current after =
    let
        thing =
            List.foldl Thing.interact
                current
                (List.append before after)

        ( things, won ) =
            case after of
                [] ->
                    ( [], True )

                x :: xs ->
                    recurse (List.append before [ current ]) x xs

        won' =
            case thing.id of
                Thing.Zone { pattern, done } ->
                    done

                _ ->
                    True
    in
        ( thing :: things, won' && won )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    [ Keyboard.downs <| KeyDown << Char.fromCode
    , Keyboard.ups <| KeyUp << Char.fromCode
    , AnimationFrame.diffs <| TimeDiff << Time.inSeconds
    ]
        |> Sub.batch



-- VIEW


view : Model -> ( List Collage.Form, List Collage.Form )
view { things, state, text } =
    ( List.map (\layer -> List.map (Thing.view layer) things) [ 0, 1, 2, 3 ]
        |> List.concat
    , message state text
    )


message : GameState -> List String -> List Collage.Form
message state text =
    case state of
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
            [ "Paused"
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
            , "Press Space to Unpause"
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
