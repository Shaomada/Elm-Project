module Levels (..) where

import Array
import Maybe
import GameTypes
import Things


initial : GameTypes.Model
initial =
    level 0

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
    [ ( [ Things.player '1' {x = -200, y = 100}
        , Things.zonePlayer {x = 200, y = 100, radius = 50}
        ]
      , [ "Use '1' to set a target,"
        , "then press a Mouse Button."
        , "Try to get into the blue Zone"
        ]
      )
    , ( [ Things.player '1' {x = -200, y = 50}
        , Things.bouncy {x = 200, y = 50}
        , Things.zonePlayer {x = 400, y = 50, radius = 40}
        , Things.zoneBouncy {x = -400, y = 50, radius = 40}
        ]
      , [ "Some Things might need a push"
        , "to go where you want them to."
        ]
      )
    , ( [ Things.player '1' {x = -200, y = 0}
        , Things.enemy {x = 0, y = 0}
        , Things.zonePlayer {x = 200, y = 0, radius = 35}
        ]
      , [ "You can reset a Level at anytime by pressing 'R'" ]
      )
    , ( [ Things.player '1' {x = 0, y = 0}
        , Things.enemy {x = -200, y = 0}
        , Things.block {x = -100, y = -1}
        , Things.zonePlayer {x = 1000, y = 0, radius = 55}
        ]
      , [ "Sometimes all you need to do is go right."
        ]
      )
    , ( [ Things.player '1' {x = -300, y = 50}
        , Things.enemy {x = 250, y = 50}
        , Things.zonePlayer {x = 400, y = 50, radius = 40}
        , Things.zoneEnemy {x = 0, y = 50, radius = 150}
        ]
      , [ "Red isn't allways Bad."
        ]
      )
    , ( [ Things.player '1' {x = -100, y = 0}
        , Things.player '2' {x =  100, y = 0}
        , Things.zonePlayer {x = -300, y = 0, radius = 35}
        , Things.zonePlayer {x =  300, y = 0, radius = 35}
        ]
      , [ "The controll is intuitive." ]
      )
    , ( [ Things.player '1' {x = 0, y = 0}
        , Things.zoneDead {x = 350, y = 0, radius = 50}
        , Things.enemy {x = -300, y = 0}
        , Things.block {x = -200, y =  50}
        , Things.block {x = -200, y = -50}
        ]
      , [ "Other things might or might not be less intuitive." ]
      )
    , ( [ Things.player '1' {x = 0, y =  300}
        , Things.player '2' {x = 0, y = -300}
        , Things.enemy {x =  100, y =  500}
        , Things.enemy {x = -100, y = -500}
        , Things.zoneEnemy {x = 0, y = 0, radius = 90}
        , Things.zoneDead {x =  400, y = 0, radius = 50}
        , Things.zoneDead {x = -400, y = 0, radius = 50}
        ]
      , [ "This is easier than it might seem."
        ]
      )
    , ( [ Things.player '1' {x = 0, y =  300}
        , Things.player '2' {x = 0, y = -300}
        , Things.player '3' {x = 0, y = 0}
        , Things.enemy {x =  100, y =  500}
        , Things.enemy {x = -100, y = -500}
        , Things.zoneEnemy {x = 0, y = 0, radius = 90}
        , Things.zoneEnemy {x = 400, y = 150, radius = 90}
        , Things.zoneDead {x =  400, y = 0, radius = 50}
        , Things.zoneDead {x = -400, y = 0, radius = 50}
        , Things.zonePlayer {x = 400, y = 300, radius = 50}
        ]
      , [ "This is not."
        ]
      )
    , ( [ Things.zoneDead {x = 0, y = 0, radius = 0}
        ]
      , [ "Congratulations"
        , "You completed all the Levels" 
        ]
      )
    ]
