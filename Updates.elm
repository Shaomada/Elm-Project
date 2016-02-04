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


updateSpeed : GameInput a -> Thing -> InMotion b -> InMotion b
updateSpeed i player =
    identity


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
