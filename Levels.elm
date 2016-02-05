module Levels (..) where

import GameTypes as G
import Color


initial : G.Model
initial =
    { things =
        [ { angle = 0
          , x = 0
          , y = 0
          , radius = 30
          , speed = 0
          , speedCap = 30
          , color = Color.blue
          , inpId = G.FollowMouse '1'
          , intId = G.Player
          , movId = G.Move
          }
        , { angle = 0
          , x = 300
          , y = 0
          , radius = 10
          , speed = 0
          , speedCap = 20
          , color = Color.green
          , inpId = G.Ignore
          , intId = G.Bouncy
          , movId = G.Move
          }
        , { angle = 0
          , x = 500
          , y = 350
          , radius = 50
          , speed = 0
          , speedCap = 10
          , color = Color.red
          , inpId = G.Ignore
          , intId = G.Enemy
          , movId = G.Move
          }
        ]
    , windowWidth = 1200
    , windowHeight = 800
    }
