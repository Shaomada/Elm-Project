module Shows (..) where

import GameTypes as G
import Graphics.Collage exposing (Form)
import Graphics.Element exposing (Element)

show : G.Model -> Element
show {things, windowHeight, windowWidth} =
  List.map showThing things
  |> Graphics.Collage.collage windowWidth windowHeight
      

showThing : G.Thing -> Form
showThing {color, x, y, radius} = 
  Graphics.Collage.circle radius
  |> Graphics.Collage.filled color
  |> Graphics.Collage.move (x, y)
