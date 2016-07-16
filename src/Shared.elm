module Shared exposing (..)


type Msg
    = EndUpdate
    | MouseMoved { x : Float, y : Float }
    | ResetViewPosition { x : Float, y : Float }
    | Launch


andThen : a -> Msg -> ( a, Msg )
andThen model msg =
    ( model, msg )


only : a -> ( a, Msg )
only model =
    ( model, EndUpdate )
