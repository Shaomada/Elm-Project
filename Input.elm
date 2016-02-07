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


map8 : (a -> b -> c -> d -> e -> f -> g -> h -> i) ->
    Signal a -> Signal b -> Signal c -> Signal d -> Signal e -> Signal f ->
    Signal g -> Signal h -> Signal i
map8 = mapOneMore map7


count : Signal a -> Signal Int
count s =
  Signal.foldp (\_ n -> n+1) 0 s


input : Signal Input
input =
    (map8
        (\x y w h k d _ n ->
            { x =
                if
                    n > 0
                then
                    toFloat x - toFloat w / 2
                else
                    0
            , y =
                if
                    n > 0
                then
                    toFloat h / 2 - toFloat y
                else
                    0
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
        (count Mouse.position)
    )
        |> Time.timestamp
        |> Signal.map
            ( \(t,a) -> (Just t, a) )
        |> Signal.foldp
            (\(mt1, a) ( _, mt2, _ ) -> (mt2, mt1, a) )
            ( Nothing
            , Nothing
            , { x = 0
              , y = 0
              , keysDown = Set.empty
              , windowWidth = 0
              , windowHeight = 0
              , timePassed = 0
              , isDown = False
              }
            )
        |> Signal.map
            (\(mt2, mt1, a) ->
              case mt1 of
                  Just t1 ->
                      case mt2 of
                          Just t2 ->
                              {a | timePassed = Time.inSeconds <| t1-t2}
                          _ -> {a | x = 0, y = 0}
                  _ -> a
            )
