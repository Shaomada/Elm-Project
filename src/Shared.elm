module Shared exposing (..)


type Msg
    = EndUpdate
    | MouseMoved { x : Float, y : Float, xRaw : Float, yRaw : Float }
    | ResetViewPosition { x : Float, y : Float }
    | Launch
    | OpenEditor
    | Play


andThen : a -> Msg -> ( a, Msg )
andThen model msg =
    ( model, msg )


only : a -> ( a, Msg )
only model =
    ( model, EndUpdate )
