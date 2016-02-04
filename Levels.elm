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
    , speed = 1
    , showId = Color.blue
    , speedId = G.FollowMouse
    , collitionId = G.NoCollition
    }
  , things = []
  , windowWidth = 1200
  , windowHeight = 800
  }
