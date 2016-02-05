module Input (..) where

import Signal
import Mouse
import Window
import Keyboard
import Set
import Time
import Char
import Maybe
import Debug
import GameTypes exposing (..)


keysParsed : Signal (Mot Emp)
keysParsed =
    Signal.map
        (\keysDown ->
            let
                forward : Float
                forward =
                    if Set.member (Char.toCode 'V') keysDown then
                        1
                    else
                        0

                backward =
                    if Set.member (Char.toCode 'I') keysDown then
                        1
                    else
                        0

                left =
                    if Set.member (Char.toCode 'U') keysDown then
                        1
                    else
                        0

                right =
                    if Set.member (Char.toCode 'I') keysDown then
                        1
                    else
                        0
            in
                { speed = forward - backward
                , angle = left - right
                }
        )
        Keyboard.keysDown


input : Signal (Maybe Input)
input =
    (Signal.map5
        (\x y w h k ->
            Just
                { x = toFloat x - toFloat w / 2
                , y = toFloat h / 2 - toFloat y
                , keysDown = Set.map Char.fromCode k
                , windowWidth = w
                , windowHeight = h
                , timePassed = Nothing
                }
        )
        Mouse.x
        Mouse.y
        Window.width
        Window.height
        Keyboard.keysDown
    )
        |> Signal.sampleOn (Time.fps 60)
        |> Time.timestamp
        |> Signal.map
            (\( t, ma ) ->
                ma
                    |> Maybe.map (\a -> ( t, a ))
            )
        |> Signal.foldp
            (\mnew ( _, mold ) -> ( Maybe.map fst mold, mnew ))
            ( Nothing, Nothing )
        |> Signal.map
            (\( mtold, mpair ) ->
                mpair
                    |> Maybe.map
                        (\( t, a ) ->
                            { a
                                | timePassed =
                                    mtold
                                        |> Maybe.map (\told -> Time.inSeconds (t - told))
                                        |> Maybe.withDefault 0
                                        |> Debug.watch "time Passed"
                            }
                        )
            )
