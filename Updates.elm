module Updates (..) where

import List
import Set
import Color
import GameTypes exposing (..)
import Things


update : Input -> Model -> Model
update input model =
        { model
            | windowHeight = input.windowHeight
            , windowWidth = input.windowWidth
        }
            |> (gameUpdate input)
            |> (autoScroll input)
            |> (manualScroll input)


autoScroll : Input -> Model -> Model
autoScroll input = scroll
  { x
      = (min 0 <| toFloat input.windowWidth / 2 - 100 - input.x)
      - (min 0 <| toFloat input.windowWidth / 2 - 100 + input.x)
          |> \ x -> input.timePassed * x
  , y
      = (min 0 <| toFloat input.windowHeight / 2 - 100 - input.y)
      - (min 0 <| toFloat input.windowHeight / 2 - 100 + input.y)
          |> \ y -> input.timePassed * y
  }


manualScroll : Input -> Model -> Model
manualScroll input model =
    if
        isDown ' ' input
    then
        scroll
            ( searchActive input model.things
                |> Maybe.map (\ {x, y} -> {x = -x, y = -y} )
                |> Maybe.withDefault {x = 0, y = 0}
            )
            model
    else
        model


searchActive input list =
    case list of
        (thing :: things) ->
            case thing.inpId of
                (FollowMouse c) ->
                    if
                        isDown c input
                    then
                        Just thing
                    else
                        searchActive input things
                _ -> searchActive input things
        [] -> Nothing


scroll : Pos a -> Model -> Model
scroll {x, y} model =
    { model
        | things = List.map
            (\thing ->
                { thing
                    | x = thing.x + x
                    , y = thing.y + y
                    , movId = case thing.movId of
                        Move -> Move
                        MoveTowards pos -> MoveTowards
                            { pos
                                | x = pos.x + x
                                , y = pos.y + y
                            }
                }
            )
            model.things
    }


gameUpdate : GInp a -> GMod b -> GMod b
gameUpdate input model =
    { model
        | things =
            if input.isDown then
                model.things
                    |> List.map tick
                    |> List.map (handleInput input)
                    |> List.map (move input)
                    |> interaction
            else
                model.things
                    |> List.map (handleInput input)
    }


tick : Thing -> Thing
tick thing =
    case thing.intId of
        (Enemy _) -> {thing | intId = Enemy {distance = Nothing} }
        (Zone x) -> {thing | intId = Zone {x | done = False} }
        _ -> thing


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
        (Enemy dataThis) ->
            case that.intId of
                (Player _) ->
                    if
                        dataThis.distance
                            |> Maybe.map (\d -> d > distance that this)
                            |> Maybe.withDefault True
                    then
                        { this
                            | movId = MoveTowards
                                { x = that.x
                                , y = that.y
                                }
                            , intId = Enemy
                                { distance = Just <| distance that this
                                }
                        }
                    else
                        this
                    

                (Bouncy _) ->
                    onTouch moveOutOff that this

                (Enemy _) ->
                    onTouch moveOutOff that this

                _ -> this
        (Player _) ->
            case that.intId of
                (Player _) ->
                    onTouch moveOutOff that this

                (Bouncy _) ->
                    onTouch moveOutOff that this

                (Enemy _) ->
                    onTouch dieFrom that this
                
                _ -> this

        (Bouncy _) ->
            case that.intId of
                (Player _) ->
                    onTouch (combine moveOutOff getPushedBy) that this

                (Bouncy _) ->
                    onTouch moveOutOff that this

                (Enemy _) ->
                    this
                
                _ -> this

        (Zone x) ->
            onWithin (checkPattern x) that this
        _ -> this


checkPattern x that this =
    if
        x.pattern that
    then
        { this | intId = Zone {x | done = True } }
    else
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


onWithin : F -> F
onWithin f that this =
    if isWithin that this then
        f that this
    else
        this


dieFrom : F
dieFrom _ this =
    Things.die this


moveOutOff : F
moveOutOff that this =
    let
        ( distance, angle ) = toPolar ( this.x - that.x, this.y - that.y )

        ( x, y ) = fromPolar ( max distance <| that.radius + this.radius, angle )
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
distance that this =
    (that.x - this.x)
        ^ 2
        + (that.y - this.y)
        ^ 2
        |> sqrt


touching : Pos (Cir a) -> Pos (Cir a) -> Bool
touching that this =
    distance that this <= this.radius + that.radius


isWithin : Pos (Cir a) -> Pos (Cir a) -> Bool
isWithin that this =
    distance that this < this.radius - that.radius
