module Msg exposing (..)

type Msg
    = KeyDown Char
    | KeyUp Char
    | MouseMoved { x : Float, y : Float }
    | TimeDiff Float
    | WindowResize { width : Int, height : Int }
    | LoadLevel Int
    | Interactions