module Update exposing (..)

import Msg exposing (..)
import Model exposing (..)
import Thing exposing (..)
import Geometry exposing (..)
import Levels

import List
import Random

toCmd : Msg -> Cmd Msg
toCmd msg = Random.generate identity (Random.map (\_ -> msg) Random.bool)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (model.state, msg) of
        (_, LoadLevel id) -> (Levels.level id) ! [toCmd <| WindowResize model.size]
        (_, WindowResize size) -> 
            { model | size = size } ! []
        (Running, TimeDiff t) ->
            { model |
                things = List.map (updateThing msg) model.things
            ,   viewPosition = autoScroll model t
            } ! [toCmd Interactions]
        (_, TimeDiff t) ->
            { model |
                viewPosition = autoScroll model t
            } ! []
        (Running, Interactions) -> 
            let
                (things, won) = case model.things of
                    [] -> ([], False)
                    x::xs -> recurse [] x xs
            in
                { model |
                    things = things
                ,   state = if won then Won else Running
                } ! []
        (_, Interactions) -> model ! []
        (Won, KeyDown c) ->
            case c of
                'N' -> model ! [toCmd <| LoadLevel <| model.level + 1]
                'R' -> model ! [toCmd <| LoadLevel model.level]
                _ -> model ! []
        (Running, KeyDown c) ->
            case c of
                'R' -> model ! [toCmd <| LoadLevel model.level]
                ' ' ->
                    { model | state = Paused } ! []
                _ ->
                    { model |
                        things = List.map (updateThing msg) model.things
                    } ! []
        (Paused, KeyDown c) ->
            case c of
                'R' -> model ! [toCmd <| LoadLevel model.level]
                ' ' ->
                    { model | state = Running } ! []
                _ ->
                    { model |
                        things = List.map (updateThing msg) model.things
                    } ! []
        (Won, MouseMoved pos) ->
            model ! []
        (_, MouseMoved pos) ->
            let
                pos' =
                    { x =  pos.x - (toFloat model.size.width)/2
                    , y = (toFloat model.size.height)/2 - pos.y
                    }
                pos'' =
                    { x = pos'.x + model.viewPosition.x
                    , y = pos'.y + model.viewPosition.y
                    }
            in
                { model |
                    things = List.map (updateThing <| MouseMoved pos'') model.things
                ,   position = pos'
                } ! []
        (Won, _) -> model ! []
        (_, _ )->
            { model |
                things = List.map (updateThing msg) model.things
            } ! []

autoScroll : Model -> Float -> { x : Float, y : Float }
autoScroll model t =
    { x = model.viewPosition.x
        - 2*t * ( min 0 <| toFloat model.size.width / 2 - 100 - model.position.x )
        + 2*t * ( min 0 <| toFloat model.size.width / 2 - 100 + model.position.x )
    , y = model.viewPosition.y
        - 2*t * ( min 0 <| toFloat model.size.height / 2 - 100 - model.position.y )
        + 2*t * ( min 0 <| toFloat model.size.height / 2 - 100 + model.position.y )
    }

updateThing : Msg -> Thing -> Thing
updateThing msg thing = case (msg, thing.id) of
    (KeyDown char, Player {handle, handleDown}) ->
        { thing
            | id = Player
                { handle = handle
                , handleDown = handleDown || handle == char
                }
        }
    (KeyUp char, Player {handle, handleDown}) ->
        { thing
            | id = Player
                { handle = handle
                , handleDown = handleDown && handle /= char
                }
        }
    (MouseMoved pos, Player {handle, handleDown}) ->
        if handleDown
        then
            { thing | target = Just pos
            }
        else thing
    (TimeDiff t, _) ->
        reset <| moveFor t thing
    _ -> thing

reset : Thing -> Thing
reset thing =
    case thing.id of
        Enemy _ ->
            { thing | id = Enemy { distance = Nothing } }
        Zone x ->
            { thing | id = Zone { x | done = False } }
        _ ->
            thing

moveFor : Float -> Thing -> Thing
moveFor time thing =
    case thing.target of
        Nothing -> thing
        Just {x, y} ->
            let
                (distance, angle) = toPolar ( x - thing.x, y - thing.y )
                (dx, dy) = fromPolar (min distance <| thing.speed * time, angle)
            in
                { thing |
                    x = thing.x + dx
                ,   y = thing.y + dy
                }

recurse : List Thing -> Thing -> List Thing -> (List Thing, Bool)
recurse before current after =
    let
        thing = List.foldl
            interact
            current
            (List.append before after)
        (things, won) = case after of
            [] -> ([], True)
            x::xs -> recurse (List.append before [current]) x xs
        won' = case thing.id of
            Zone {pattern, done} -> done
            _ -> True
    in
        (thing :: things, won' && won)

interact : Thing -> Thing -> Thing
interact that this =
    case (this.id, that.id) of
        (Zone {pattern, done}, _) ->
            if isWithin that this
            then { this | id = Zone { pattern = pattern, done = done || pattern that } }
            else this
        (_, Block _) ->
            moveOutOff that this
        (Enemy e, Player _) ->
            if
                e.distance
                |> Maybe.map (\d -> d > distance that this)
                |> Maybe.withDefault True
            then
                { this |
                    target = Just
                        { x = that.x
                        , y = that.y
                        }
                ,   id = Enemy
                        { distance = Just <| distance that this }
                 }
            else
                this
        (Player _, Bouncy _) ->
             this
        (_, Bouncy _) ->
            moveOutOff that this
        (Player _, Enemy _) ->
            if touching that this
            then { this | id = Dead {} }
            else this
        (Bouncy _, Player _) ->
            if touching that this
            then moveOutOff that <| getPushedBy that this
            else this
        _ -> this