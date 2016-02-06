module Things where

import GameTypes exposing (..)
import Color exposing (blue, red, green, black)

player : Char -> Pos a -> Thing
player c {x, y} =
    { angle = 0
    , x = x
    , y = y
    , radius = 30
    , speed = 0
    , speedCap = 70
    , color = blue
    , inpId = FollowMouse c
    , intId = Player {}
    , movId = Move
    }


bouncy : Pos a -> Thing
bouncy {x, y} =
    { angle = 0
    , x = x
    , y = y
    , radius = 20
    , speed = 0
    , speedCap = 60
    , color = green
    , inpId = Ignore
    , intId = Bouncy {}
    , movId = Move
    }


enemy : Pos a -> Thing
enemy {x, y} =
    { angle = 0
    , x = x
    , y = y
    , radius = 50
    , speed = 0
    , speedCap = 45
    , color = red
    , inpId = Ignore
    , intId = Enemy {distance = Nothing}
    , movId = Move
    }


die : Thing -> Thing
die thing =
    { thing
        | speed = 0
        , speedCap = 0
        , color = black
        , inpId = Ignore
        , intId = Dead {}
        , movId = Move
    }
