module Levels (..) where

import GameTypes
import Things


initial : GameTypes.Model
initial =
    { things =
        [ Things.player '1' {x = 0, y = 0} 
        , Things.bouncy {x = 300, y = 0}
        , Things.enemy {x = 500, y = 350}
        ]
    , windowWidth = 0
    , windowHeight = 0
    }
