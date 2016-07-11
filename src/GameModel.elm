module GameModel exposing (..)

import Thing


-- MODEL


type alias Model =
    { things : List Thing.Model
    , state : GameState
    , level : Int
    , text : List String
    }


type GameState
    = Won
    | Running
    | Paused
