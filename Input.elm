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


type alias SignalMap a x y = (a -> x) -> Signal a -> y


mapOneMore : SignalMap (a, b) x y -> (a -> b -> x) -> Signal a -> Signal b -> y
mapOneMore map f sa sb =
    map (\(a, b) -> f a b) (Signal.map2 (,) sa sb)


map6 : (a -> b -> c -> d -> e -> f -> g) ->
    Signal a -> Signal b -> Signal c -> Signal d -> Signal e -> Signal f ->
    Signal g
map6 =
    mapOneMore Signal.map5


map7 : (a -> b -> c -> d -> e -> f -> g -> h) ->
    Signal a -> Signal b -> Signal c -> Signal d -> Signal e -> Signal f ->
    Signal g -> Signal h
map7 = mapOneMore map6


input : Signal (Maybe Input)
input =
    (map7
        (\x y w h k d _ ->
            Just
                { x = toFloat x - toFloat w / 2
                , y = toFloat h / 2 - toFloat y
                , keysDown = Set.map Char.fromCode k
                , windowWidth = w
                , windowHeight = h
                , timePassed = 0
                , isDown = d
                }
        )
        Mouse.x
        Mouse.y
        Window.width
        Window.height
        Keyboard.keysDown
        Mouse.isDown
        (Time.fps 60)
    )
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
                            }
                        )
            )
