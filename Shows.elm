module Shows (..) where

import GameTypes as G
import Graphics.Collage exposing (Form)
import Graphics.Element exposing (Element)

show : G.Model -> Element
show {things, windowHeight, windowWidth} =
  List.concatMap showThing things
  |> Graphics.Collage.collage windowWidth windowHeight
      

showThing : G.Thing -> List Form
showThing thing =
  [ showBody thing
  , showPath thing
  ]


showBody : G.Thing -> Form
showBody thing =
  Graphics.Collage.circle thing.radius
  |> Graphics.Collage.filled thing.color
  |> Graphics.Collage.move (thing.x, thing.y)

showPath : G.Thing -> Form
showPath thing =
  case thing.movId of
    (G.MoveTowards aim) ->
      Graphics.Collage.segment (thing.x, thing.y) (aim.x, aim.y)
      |> Graphics.Collage.traced (Graphics.Collage.dotted thing.color)
    _ -> Graphics.Collage.group []
