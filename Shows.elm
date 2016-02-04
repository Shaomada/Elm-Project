module Shows (..) where

import GameTypes exposing (..)
import Graphics.Collage exposing (Form)
import Graphics.Element exposing (Element)

show : Model -> Element
show ( {player, things, windowHeight, windowWidth} as model )
  = Graphics.Collage.collage windowWidth windowHeight <|
      showThing player
      :: List.map showThing things

showThing : Thing -> Form
showThing ( {sId, x, y, radius} )
  =  Graphics.Collage.circle radius
  |> Graphics.Collage.filled sId
  |> Graphics.Collage.move (x, y)
