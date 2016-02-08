module Levels (..) where

import Array
import Maybe
import GameTypes
import Things


initial : GameTypes.Model
initial =
    level 0


level : Int -> GameTypes.Model
level n =
    Array.get n levels
    |> Maybe.withDefault
        { things = []
        , windowWidth = 0
        , windowHeight = 0
        , won = False
        , level = 0
        }


levels : Array.Array GameTypes.Model
levels = Array.fromList
    [ { things =
        [ Things.player '1' {x = -200, y = 200}
        , Things.zonePlayer {x = 200, y = 200, radius = 70}
        ]
      , windowHeight = 0
      , windowWidth = 0
      , won = False,
      level = 0
      }
    , { things =
          [ Things.player '2' {x = 0, y = 0}
          , Things.player '3' {x = 100, y = 0}
          , Things.player '1' {x = -100, y = 0}
          , Things.bouncy {x = 300, y = 0}
          , Things.enemy {x = 500, y = 350}
          , Things.enemy {x = 500, y = -350}
          , Things.enemy {x = -500, y = 350}
          , Things.enemy {x = -500, y = -350}
          , Things.zonePlayer {x = 0, y = 200, radius = 100}
          ]
      , windowWidth = 0
      , windowHeight = 0
      , won = False
      , level = 1
      }
    ]
