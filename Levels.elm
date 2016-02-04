module Levels where

import GameTypes as G
import Color

initial : G.Model
initial =
  { player = 
    { angle = 0
    , x = 0
    , y = 0
    , radius = 30
    , speed = 0
    , speedCap = 30
    , showId = Color.blue
    , speedId = G.FollowMouse
    , collitionId = G.NoCollition
    }
  , things =
    [ { angle = 0
      , x = 300
      , y = 0
      , radius = 10
      , speed = 0
      , speedCap = 20
      , showId = Color.green
      , speedId = G.FollowPlayer
      , collitionId = G.NoCollition
      }
    ]
  , windowWidth = 1200
  , windowHeight = 800
  }
