module Model exposing (..)

import Thing exposing (Thing)

type alias Position =
    {   x : Float
    ,   y : Float
    }

type Gamestate
    = Running
    | Won
    | Paused

type alias Model =
    {   things : List Thing
    ,   position : { x : Float, y : Float }
    ,   size : { width : Int, height : Int }
    ,   viewPosition : { x : Float, y : Float }
    ,   state : Gamestate
    ,   level : Int
    ,   text : List String
    }