module Level exposing (..)

import LevelData exposing (..)
import GameModel
import Array


level : Int -> GameModel.Model
level i =
    Array.get i LevelData.levelData
        |> Maybe.withDefault (LevelData.invalidLevel i)
