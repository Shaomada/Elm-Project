module Things where

import GameTypes exposing (..)
import Color exposing (blue, red, green, black, yellow)

player : Char -> Pos a -> Thing
player c {x, y} =
    { angle = 0
    , x = x
    , y = y
    , radius = 30
    , speed = 0
    , speedCap = 70
    , color = blue
    , alpha = 0.9
    , inpId = FollowMouse c
    , intId = Player {}
    , movId = Move
    }


isPlayer : Thing -> Bool
isPlayer thing =
    case thing.intId of
        (Player _) -> True
        _ -> False


zonePlayer : Pos (Cir a) -> Thing
zonePlayer {x, y, radius} =
    { angle = 0
    , x = x
    , y = y
    , radius = radius
    , speed = 0
    , speedCap = 0
    , color = blue
    , alpha = 0.25
    , inpId = Ignore
    , intId = Zone
        { pattern = isPlayer
        , done = False
        }
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
    , alpha = 0.9
    , inpId = Ignore
    , intId = Bouncy {}
    , movId = Move
    }


isBouncy : Thing -> Bool
isBouncy thing =
    case thing.intId of
        (Bouncy _) -> True
        _ -> False


zoneBouncy : Pos (Cir a) -> Thing
zoneBouncy {x, y, radius} =
    { angle = 0
    , x = x
    , y = y
    , radius = radius
    , speed = 0
    , speedCap = 0
    , color = green
    , alpha = 0.25
    , inpId = Ignore
    , intId = Zone
        { pattern = isBouncy
        , done = False
        }
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
    , alpha = 0.8
    , inpId = Ignore
    , intId = Enemy {distance = Nothing}
    , movId = Move
    }


isEnemy : Thing -> Bool
isEnemy thing =
    case thing.intId of
        (Enemy _) -> True
        _ -> False


zoneEnemy : Pos (Cir a) -> Thing
zoneEnemy {x, y, radius} =
    { angle = 0
    , x = x
    , y = y
    , radius = radius
    , speed = 0
    , speedCap = 0
    , color = red
    , alpha = 0.25
    , inpId = Ignore
    , intId = Zone
        { pattern = isEnemy
        , done = False
        }
    , movId = Move
    }


die : Thing -> Thing
die thing =
    { thing
        | speed = 0
        , speedCap = 0
        , alpha = 0.4
        , inpId = Ignore
        , intId = Dead {}
        , movId = Move
    }


isDead : Thing -> Bool
isDead thing =
    case thing.intId of
        (Dead _) -> True
        _ -> False





zoneDead : Pos (Cir a) -> Thing
zoneDead {x, y, radius} =
    { angle = 0
    , x = x
    , y = y
    , radius = radius
    , speed = 0
    , speedCap = 0
    , color = black
    , alpha = 0.25
    , inpId = Ignore
    , intId = Zone
        { pattern = isDead
        , done = False
        }
    , movId = Move
    }


block : Pos a -> Thing
block {x, y} =
    { angle = 0
    , x = x
    , y = y
    , radius = 20
    , speed = 0
    , speedCap = 60
    , color = yellow
    , alpha = 0.9
    , inpId = Ignore
    , intId = Bouncy {}
    , movId = Move
    }
