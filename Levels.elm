module Levels (..) where

import Array
import Maybe
import GameTypes
import Things


initial : GameTypes.Model
initial =
    level 2


level : Int -> GameTypes.Model
level i =
    Array.get i levels
    |> Maybe.withDefault
        ( createLevel i ([], ["Index out of range, loading empty Level"]))


levels : Array.Array GameTypes.Model
levels =
    levelData
        |> List.indexedMap createLevel
        |> Array.fromList


createLevel : Int -> (List GameTypes.Thing, List String) -> GameTypes.Model
createLevel i (things, messages) =
    { things = things
    , windowWidth = 0
    , windowHeight = 0
    , won = False
    , level = i
    , messages = messages
    }


levelData : List (List GameTypes.Thing, List String)
levelData =
    [ ( [ Things.player '1' {x = -200, y = 200}
        , Things.zonePlayer {x = 200, y = 200, radius = 70}
        ]
      , [ "Use '1' to set a target,"
        , "then press a Mouse Button."
        , "Try to get into the blue Zone"
        ]
      )
    , ( [ Things.player '1' {x = -200, y = 100}
        , Things.bouncy {x = 200, y = 100}
        , Things.zonePlayer {x = 400, y = 100, radius = 70}
        , Things.zoneBouncy {x = -400, y = 100, radius = 50}
        ]
      , [ "some Things might need a push"
        , "to go where you want them to"
        ]
      )
    , ( [ Things.zoneDead {x = 0, y = 0, radius = 0}
        ]
      , [ "Congratulations"
        , "You completed all the Levels" 
        ]
      )
    ]
