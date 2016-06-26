module Subscriptions exposing (..)

import Msg

import Mouse
import Window
import Keyboard
import Time
import AnimationFrame
import Char

subscriptions _ =
    Sub.batch
        [ Keyboard.downs <| Msg.KeyDown << Char.fromCode
        , Keyboard.ups <| Msg.KeyUp << Char.fromCode
        , Mouse.moves (\ {x, y} -> Msg.MouseMoved {x = toFloat x, y = toFloat <| y})
        , AnimationFrame.diffs <| Msg.TimeDiff << Time.inSeconds
        , Window.resizes Msg.WindowResize
        ]