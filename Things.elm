module Things where

import GameTypes exposing (..)
import Color exposing (blue, red, green)

player : Char -> Pos a -> Thing
player c {x, y} =
    { angle = 0
    , x = x
    , y = y
    , radius = 30
    , speed = 0
    , speedCap = 30
    , color = blue
    , inpId = FollowMouse c
    , intId = Player
    , movId = Move
    }

bouncy : Pos a -> Thing
bouncy {x, y} =
    { angle = 0
    , x = x
    , y = y
    , radius = 20
    , speed = 0
    , speedCap = 20
    , color = green
    , inpId = Ignore
    , intId = Bouncy
    , movId = Move
    }


enemy : Pos a -> Thing
enemy {x, y} =
    { angle = 0
    , x = x
    , y = y
    , radius = 50
    , speed = 0
    , speedCap = 10
    , color = red
    , inpId = Ignore
    , intId = Enemy
    , movId = Move
    }
