module Updates (..) where

import List
import Set
import Color
import GameTypes exposing (..)


update : Maybe Input -> Model -> Model
update minput model =
    case minput of
        Just input ->
            gameUpdate
                (Debug.watch "input" input)
                { model
                    | windowHeight = input.windowHeight
                    , windowWidth = input.windowWidth
                }

        Nothing ->
            model


gameUpdate : GInp a -> GMod b -> GMod b
gameUpdate input model =
    { model
        | things =
            if input.isDown then
                model.things
                    |> List.map (handleInput input)
                    |> List.map (move input)
                    |> interaction
            else
                model.things
                    |> List.map (handleInput input)
    }


isDown : Char -> Key a -> Bool
isDown c { keysDown } =
    Set.member c keysDown


handleInput : GInp a -> Thing -> Thing
handleInput input thing =
    case thing.inpId of
        FollowMouse c ->
            if isDown c input then
                { thing
                    | movId = MoveTowards { x = input.x, y = input.y }
                }
            else
                thing

        Ignore ->
            thing


move : GInp a -> Thing -> Thing
move input thing =
    case thing.movId of
        MoveTowards target ->
            moveTowardsFor target input.timePassed thing

        Move ->
            moveFor input.timePassed thing


moveTowardsFor : Pos a -> Float -> Thing -> Thing
moveTowardsFor { x, y } time thing =
    let
        ( distance, angle ) = toPolar ( x - thing.x, y - thing.y )
    in
        moveFor
            time
            { thing
                | angle = angle
                , speed = min thing.speedCap <| distance / time
            }


moveFor : Float -> Mot (Pos a) -> Mot (Pos a)
moveFor time thing =
    let
        ( speedx, speedy ) = fromPolar ( thing.speed, thing.angle )
    in
        { thing
            | x = thing.x + time * speedx
            , y = thing.y + time * speedy
        }


interaction : List Thing -> List Thing
interaction list =
    List.foldl
        (\that ( things, i ) ->
            ( things
                |> List.indexedMap
                    (\j this ->
                        if i /= j then
                            interact that this
                        else
                            this
                    )
            , i + 1
            )
        )
        ( list, 0 )
        list
        |> fst


type alias F =
    Thing -> Thing -> Thing


interact : F
interact that this =
    case this.intId of
        Enemy ->
            case that.intId of
                Player ->
                    { this | movId = MoveTowards { x = that.x, y = that.y } }

                Bouncy ->
                    onTouch moveOutOff that this

                Enemy ->
                    onTouch moveOutOff that this

        Player ->
            case that.intId of
                Player ->
                    onTouch moveOutOff that this

                Bouncy ->
                    onTouch moveOutOff that this

                Enemy ->
                    onTouch (\_ t -> { t | color = Color.black }) that this

        Bouncy ->
            case that.intId of
                Player ->
                    onTouch (combine moveOutOff getPushedBy) that this

                Bouncy ->
                    onTouch moveOutOff that this

                Enemy ->
                    this


combine : F -> F -> F
combine f g that =
    f that << g that


onTouch : F -> F
onTouch f that this =
    if touching that this then
        f that this
    else
        this


moveOutOff : F
moveOutOff that this =
    let
        ( distance, angle ) = toPolar ( this.x - that.x, this.y - that.y )

        ( x, y ) = fromPolar ( max distance <| minDistance that this, angle )
    in
        { this
            | x = that.x + x
            , y = that.y + y
        }


getPushedBy : F
getPushedBy that this =
    let
        ( _, angle ) = toPolar ( this.x - that.x, this.y - that.y )

        ( x, y ) = fromPolar ( 300, angle )
    in
        { this | movId = MoveTowards { x = this.x + x, y = this.y + y } }


distance : Pos a -> Pos a -> Float
distance th1 th2 =
    (th1.x - th2.x)
        ^ 2
        + (th1.y - th2.y)
        ^ 2
        |> sqrt


minDistance : Cir a -> Cir a -> Float
minDistance th1 th2 =
    th1.radius + th2.radius


touching : Pos (Cir a) -> Pos (Cir a) -> Bool
touching th1 th2 =
    distance th1 th2 <= minDistance th1 th2
