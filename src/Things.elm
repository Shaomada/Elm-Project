module Things exposing (..)

import Thing exposing (..)
import Color exposing (blue, red, green, black, yellow)


player : Char -> { x : Float, y : Float } -> Thing
player c { x, y } =
    { id = Player { handle = c, handleDown = False }
    , x = x
    , y = y
    , target = Nothing
    , radius = 30
    , speed = 70
    , color = blue
    , alpha = 0.9
    }

isPlayer : Thing -> Bool
isPlayer thing =
    case thing.id of
        Player _ ->
            True

        _ ->
            False


zonePlayer : { x : Float, y : Float, radius : Float } -> Thing
zonePlayer { x, y, radius } =
    { id = Zone { pattern = isPlayer, done = False }
    , x = x
    , y = y
    , target = Nothing
    , radius = radius
    , speed = 0
    , color = blue
    , alpha = 0.25
    }


bouncy : { x : Float, y : Float } -> Thing
bouncy { x, y } =
    { id = Bouncy {}
    , x = x
    , y = y
    , target = Nothing
    , radius = 20
    , speed = 60
    , color = green
    , alpha = 0.9
    }


isBouncy : Thing -> Bool
isBouncy thing =
    case thing.id of
        Bouncy _ ->
            True

        _ ->
            False


zoneBouncy : { x : Float, y : Float, radius : Float } -> Thing
zoneBouncy { x, y, radius } =
    { id = Zone { pattern = isBouncy, done = False }
    , x = x
    , y = y
    , target = Nothing
    , radius = radius
    , speed = 0
    , color = green
    , alpha = 0.25
    }


enemy : { x : Float, y : Float } -> Thing
enemy { x, y } =
    { id = Enemy { distance = Nothing }
    , x = x
    , y = y
    , target = Nothing
    , radius = 50
    , speed = 45
    , color = red
    , alpha = 0.8
    }


isEnemy : Thing -> Bool
isEnemy thing =
    case thing.id of
        Enemy _ ->
            True

        _ ->
            False


zoneEnemy : { x : Float, y : Float, radius : Float } -> Thing
zoneEnemy { x, y, radius } =
    { id = Zone { pattern = isEnemy, done = False }
    , x = x
    , y = y
    , target = Nothing
    , radius = radius
    , speed = 0
    , color = red
    , alpha = 0.25
    }


die : Thing -> Thing
die thing =
    { thing
        | id = Dead {}
        , speed = 0
        , alpha = 0.4
    }


isDead : Thing -> Bool
isDead thing =
    case thing.id of
        Dead _ ->
            True

        _ ->
            False


zoneDead : { x : Float, y : Float, radius : Float } -> Thing
zoneDead { x, y, radius } =
    { id = Zone { pattern = isDead, done = False }
    , x = x
    , y = y
    , target = Nothing
    , radius = radius
    , speed = 0
    , color = black
    , alpha = 0.25
    }


block : { x : Float, y : Float } -> Thing
block { x, y } =
    { id = Block {}
    , x = x
    , y = y
    , target = Nothing
    , radius = 20
    , speed = 60
    , color = yellow
    , alpha = 0.9
    }
