module Updates (..) where

import List

import GameTypes exposing (..)

update : ( Maybe Input ) -> Model -> Model
update minput model =
  case minput of
    ( Just input ) ->
      gameUpdate (Debug.watch "input" input)
        { model
          | windowHeight = input.windowHeight
          , windowWidth = input.windowWidth
        }
    Nothing -> model


gameUpdate : GInp a -> GMod b -> GMod b
gameUpdate input model =
    { model
        | things =
            model.things
            |> List.map (handleInput input)
            |> List.map (move input)
            |> interaction
    }


handleInput : GInp a -> Thing -> Thing
handleInput input thing =
    case thing.inpId of
        FollowMouse -> { thing |
            movId = MoveTowards {x = input.x, y = input.y} }
        Ignore -> thing


move : GInp a -> Thing -> Thing
move input thing =
    case thing.movId of
        ( MoveTowards target ) -> moveTowardsFor target input.timePassed thing
        Move -> moveFor input.timePassed thing


moveTowardsFor : Pos a -> Float -> Thing -> Thing
moveTowardsFor {x, y} time thing =
    let
        (distance, angle) = toPolar (x-thing.x, y-thing.y)
    in
        moveFor time
            { thing
                | angle = angle
                , speed = min thing.speedCap <| distance / time
            }


moveFor : Float -> Mot (Pos a) -> Mot (Pos a)
moveFor time thing =
    let
        (speedx, speedy) = fromPolar (thing.speed, thing.angle)
    in
  { thing
      | x = thing.x + time * speedx
      , y = thing.y + time * speedy
  }


interaction : List Thing -> List Thing
interaction list = case list of
  [] -> []
  (thing :: things) ->
    things
    |> List.foldl
      (\ t (ts, t0) ->
        let
          (t0', t') = interact t0 t
        in
          (t' :: ts, t0')
      )
      ([], thing)
    |> (\ (ts, t) -> t :: interaction ts )


interact : Thing -> Thing -> (Thing, Thing)
interact thing1 thing2 =
  let
    thing1' = onInteraction thing2 thing1
    thing2' = onInteraction thing1 thing2
  in (thing1', thing2')


onInteraction : Thing -> Thing -> Thing
onInteraction that this =
  case this.intId of
    Enemy -> case that.intId of
      Player -> {this | movId = MoveTowards {x = that.x, y = that.y} }
      _ -> this
    _ -> this


distance : Pos a -> Pos a -> Float
distance th1 th2 =
  (th1.x-th2.x)^2 + (th1.y-th2.y)^2
  |> sqrt


minDistance : Cir a -> Cir a -> Float
minDistance th1 th2 =
  th1.radius + th2.radius


touching : Pos (Cir (a) ) -> Pos (Cir (a) ) -> Bool
touching th1 th2 =
  distance th1 th2 <= minDistance th1 th2
