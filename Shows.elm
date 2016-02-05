module Shows (..) where

import Text
import String
import Graphics.Collage exposing (Form)
import Graphics.Element exposing (Element)

import GameTypes as G


show : G.Model -> Element
show {things, windowHeight, windowWidth} =
  List.concatMap showThing things
  |> Graphics.Collage.collage windowWidth windowHeight
      

showThing : G.Thing -> List Form
showThing thing =
  [ showBody thing
  , showPath thing
  , showKey thing
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


showKey : G.Thing -> Form
showKey thing = case thing.inpId of
    (G.FollowMouse c) ->
      c
      |> String.fromChar
      |> Text.fromString
      |> Graphics.Collage.text
      |> Graphics.Collage.move (thing.x, thing.y)
    _ -> Graphics.Collage.group []
