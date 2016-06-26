module Thing exposing (..)

import Maybe exposing (Maybe)
import Color

type Id
    = Player { handle : Char, handleDown : Bool }
    | Enemy { distance : Maybe Float }
    | Bouncy {}
    | Block {}
    | Dead {}
    | Zone
        { pattern : Thing -> Bool
        , done : Bool
        }

type alias Thing =
    { id : Id
    , x : Float
    , y : Float
    , target : Maybe { x : Float, y : Float }
    , speed : Float
    , radius : Float
    , color : Color.Color
    , alpha : Float
    }