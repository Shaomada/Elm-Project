module Shows (..) where

import GameTypes as G
import Graphics.Collage exposing (Form)
import Graphics.Element exposing (Element)

show : G.Model -> Element
show ( {player, things, windowHeight, windowWidth} as model )
  = Graphics.Collage.collage windowWidth windowHeight <|
      showThing player
      :: List.map showThing things

showThing : G.Thing -> Form
showThing ( {showId, x, y, radius} )
  =  Graphics.Collage.circle radius
  |> Graphics.Collage.filled showId
  |> Graphics.Collage.move (x, y)
