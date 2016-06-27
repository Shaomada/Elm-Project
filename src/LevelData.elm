module LevelData exposing (..)

import Thing

import Array
import Maybe

invalidLevel : ( List Thing.Model , List String )
invalidLevel =
    (   [ Thing.zoneDead 0 { x = 0, y = 0 }
        ]
    ,   [ "Tried to load a Level out of Bounds."
        , "That is a bug."
        ]
    )

levelData : Array.Array ( List Thing.Model, List String )
levelData =
    [ ( [ Thing.player '1' { x = -200, y = 100 }
        , Thing.zonePlayer 50 { x = 200, y = 100 }
        ]
      , [ "Try to get into the blue Zone. While you hold down"
        , "the Key '1', your Circle labeled with the same key"
        , "will select the mouse position as it's target"
        ]
      )
    , ( [ Thing.player '1' { x = -200, y = 0 }
        , Thing.enemy { x = 0, y = 0 }
        , Thing.zonePlayer 35 { x = 200, y = 0 }
        ]
      , [ "You can reset a Level at any time by pressing 'R'."
        , "Also, you can toggle Pause on and off pressing Space."
        , "During Pause, you can still select targets"]
      )
    , ( [ Thing.player '1' { x = -200, y = 50 }
        , Thing.bouncy { x = 200, y = 50 }
        , Thing.zonePlayer 40 { x = 400, y = 50 }
        , Thing.zoneBouncy 40 { x = -400, y = 50 }
        ]
      , [ "Some Things might need a push"
        , "to go where you want them to."
        ]
      )
    , ( [ Thing.player '1' { x = 0, y = 0 }
        , Thing.enemy { x = -200, y = 0 }
        , Thing.block { x = -100, y = -1 }
        , Thing.zonePlayer 55 { x = 1000, y = 0 }
        ]
      , [ "Sometimes all you need to do is go right."
        ]
      )
    , ( [ Thing.player '1' { x = -300, y = 50 }
        , Thing.enemy { x = 250, y = 50 }
        , Thing.zonePlayer 40 { x = 400, y = 50 }
        , Thing.zoneEnemy 150 { x = 0, y = 50 }
        ]
      , [ "Red isn't allways Bad."
        ]
      )
    , ( [ Thing.player '1' { x = -100, y = 0 }
        , Thing.player '2' { x = 100, y = 0 }
        , Thing.zonePlayer 35 { x = -300, y = 0 }
        , Thing.zonePlayer 35 { x = 300, y = 0 }
        ]
      , [ "The controll is intuitive." ]
      )
    , ( [ Thing.player '1' { x = 0, y = 0 }
        , Thing.zoneDead 50 { x = 350, y = 0 }
        , Thing.enemy { x = -300, y = 0 }
        , Thing.block { x = -200, y = 50 }
        , Thing.block { x = -200, y = -50 }
        ]
      , [ "Other Things might or might not be less intuitive." ]
      )
    , ( [ Thing.player '1' { x = 0, y = 300 }
        , Thing.player '2' { x = 0, y = -300 }
        , Thing.enemy { x = 100, y = 500 }
        , Thing.enemy { x = -100, y = -500 }
        , Thing.zoneEnemy 90 { x = 0, y = 0 }
        , Thing.zoneDead 50 { x = 400, y = 0 }
        , Thing.zoneDead 50 { x = -400, y = 0 }
        ]
      , [ "This is easier than it might seem."
        ]
      )
    , ( [ Thing.player '1' { x = 0, y = 300 }
        , Thing.player '2' { x = 0, y = -300 }
        , Thing.player '3' { x = 0, y = 0 }
        , Thing.enemy { x = 100, y = 500 }
        , Thing.enemy { x = -100, y = -500 }
        , Thing.zoneEnemy 90 { x = 0, y = 0 }
        , Thing.zoneEnemy 90 { x = 400, y = 150 }
        , Thing.zoneDead 50 { x = 400, y = 0 }
        , Thing.zoneDead 50 { x = -400, y = 0 }
        , Thing.zonePlayer 50 { x = 400, y = 300 }
        ]
      , [ "This is not."
        ]
      )
    , ( [ Thing.zoneDead 0 { x = 0, y = 0 }
        ]
      , [ "Congratulations"
        , "You completed all the Levels"
        ]
      )
    ]
    |> Array.fromList