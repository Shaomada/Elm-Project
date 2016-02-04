module Updates (..) where

import GameTypes exposing (..)

update : ( Maybe Input ) -> Model -> Model
update minput model =
  case minput of
    ( Just input ) ->
      gameUpdate input
        { model
          | windowHeight = input.windowHeight
          , windowWidth = input.windowWidth
        }
    Nothing -> model

gameUpdate : GameInput a -> GameModel b -> GameModel b
gameUpdate ({ timePassed } as input ) (({ player, things }) as model) =
     let
         u
           =  updateSpeed input player
           >> updatePosition timePassed
      in
         collition
         <| { model |
              player = u player
            , things = List.map u things
            }


updateSpeed : GameInput a -> Positioned b -> Thing -> Thing
updateSpeed i player thing =
    case thing.speedId of
        FollowMouse -> follow i thing.speedCap thing
        FollowPlayer -> follow player thing.speedCap thing
        Static -> thing

follow : Positioned a -> Float -> Positioned( InMotion( b ) ) -> Positioned( InMotion( b ) )
follow {x, y} speedCap moving =
    let
        (distance, angle) = toPolar (x-moving.x, y-moving.y)
    in
        { moving
            | angle = angle
            , speed = speedCap
        }


updatePosition : Float -> InMotion (Positioned a) -> InMotion (Positioned a)
updatePosition time thing =
    let
        (speedx, speedy) = fromPolar (thing.speed, thing.angle)
    in
  { thing
      | x = thing.x + time * speedx
      , y = thing.y + time * speedy
  }


collition : GameModel a -> GameModel a
collition =
    identity
