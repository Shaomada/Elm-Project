module LevelData exposing (..)

import LevelSyntax exposing (..)
import GameModel
import Array


invalidLevel : Int -> GameModel.Model
invalidLevel i =
    empty
        |> asZone
        |> text "Loaded invalid Level."
        |> text "This is probably due to a bug."
        |> finalise i


levelData : Array.Array (GameModel.Model)
levelData =
    [ empty
        |> player -200 100
        |> zone 200 100
        |> text "Try to get into the blue Zone. While you hold down"
        |> text "the Key '1', your Circle labeled with the same key"
        |> text "will select the mouse position as it's target."
    , empty
        |> player -200 0
        |> zone 200 0
        |> enemy 0 0
        |> text "You can reset a Level at any time by pressing 'R'."
        |> text "Also, you can toggle Pause on and off pressing Space."
        |> text "During Pause, you can still select targets."
    , empty
        |> player -200 50
        |> zone 400 50
        |> bouncy 200 50
        |> zone -400 50
        |> text "Some Things might need a push"
        |> text "to go where you want them to."
    , empty
        |> player 0 0
        |> zone 1000 0
        |> enemy -200 0
        |> block -100 -1
        |> text "Sometimes all you need to do is go right"
    , empty
        |> player -300 50
        |> zone 400 50
        |> enemy 250 50
        |> zone 0 50
        |> radius 150
        |> text "Red isn't allways bad."
    , empty
        |> player -100 0
        |> zone -300 0
        |> player 100 0
        |> zone 300 0
        |> text "The controll is intuitive."
    , empty
        |> player 0 0
        |> dead 350 0
        |> asZone
        |> enemy -300 0
        |> block -200 50
        |> block -200 -50
        |> text "Other Things might or might not be less intuitive."
    , empty
        |> player 0 300
        |> dead 400 0
        |> asZone
        |> player 0 -300
        |> dead -400 0
        |> asZone
        |> enemy 100 -500
        |> enemy -100 500
        |> zone 0 0
        |> radius 90
        |> text "This is easier than it might seem."
    , empty
        |> player 0 300
        |> zone 400 300
        |> player 0 -300
        |> dead -400 0
        |> asZone
        |> player 0 0
        |> dead 400 0
        |> asZone
        |> enemy 100 500
        |> zone 400 150
        |> radius 90
        |> enemy -100 -500
        |> zone 0 0
        |> radius 90
        |> text "This is not."
    , empty
        |> zone 0 0
        |> text "Congratulations"
        |> text "You completed all Levels"
    ]
        |> List.indexedMap finalise
        |> Array.fromList


finalise : Int -> Model -> GameModel.Model
finalise i model =
    { things = List.reverse model.things
    , state = GameModel.Paused
    , level = i
    , text = List.reverse model.text
    }
