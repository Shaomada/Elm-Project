module Shows (..) where

import Text
import String
import Graphics.Collage exposing (Form)
import Graphics.Element exposing (Element)
import GameTypes as G
import Color


show : G.Model -> Element
show { things, windowHeight, windowWidth, won, messages } =
    [ List.map showBoundry things
    , List.map showBody things
    , List.map showPath things
    , List.map showKey things
    , victory won messages
    ]
        |> List.concat
        |> Graphics.Collage.collage windowWidth windowHeight


victory : Bool -> List String -> List Form
victory won messages =
    if
        won
    then
        [ "Victory"
            |> Text.fromString
            |> Text.style
                { typeface = []
                , height = Just 100
                , color = Color.lightPurple
                , bold = True
                , italic = False
                , line = Nothing
                }
            |> Graphics.Collage.text
            |> Graphics.Collage.alpha 0.8
        , "Press n to proceed to the next Level"
            |> Text.fromString
            |> Text.style
                { typeface = []
                , height = Just 30
                , color = Color.lightPurple
                , bold = False
                , italic = False
                , line = Nothing
                }
            |> Graphics.Collage.text
            |> Graphics.Collage.alpha 0.8
            |> Graphics.Collage.move ( 0, -100 )
        ]
    else
        messages
            |> List.indexedMap
                (\line message ->
                    message
                        |> Text.fromString
                        |> Text.style
                            { typeface = []
                            , height = Just 30
                            , color = Color.lightPurple
                            , bold = False
                            , italic = False
                            , line = Nothing
                            }
                        |> Graphics.Collage.text
                        |> Graphics.Collage.alpha 0.8
                        |> Graphics.Collage.move ( 0, -40 * toFloat (3 + line) )
                )


showBoundry : G.Thing -> Form
showBoundry thing =
    case thing.intId of
        G.Zone { done } ->
            if
                done
            then
                Graphics.Collage.circle thing.radius
                    |> Graphics.Collage.outlined
                        (Graphics.Collage.solid thing.color)
                    |> Graphics.Collage.move ( thing.x, thing.y )
            else
                Graphics.Collage.circle thing.radius
                    |> Graphics.Collage.outlined
                        (Graphics.Collage.solid Color.lightGray)
                    |> Graphics.Collage.move ( thing.x, thing.y )

        _ ->
            Graphics.Collage.circle thing.radius
                |> Graphics.Collage.outlined
                    (Graphics.Collage.solid Color.black)
                |> Graphics.Collage.alpha 0.7
                |> Graphics.Collage.move ( thing.x, thing.y )


showBody : G.Thing -> Form
showBody thing =
    Graphics.Collage.circle thing.radius
        |> Graphics.Collage.filled thing.color
        |> Graphics.Collage.alpha thing.alpha
        |> Graphics.Collage.move ( thing.x, thing.y )


showPath : G.Thing -> Form
showPath thing =
    case thing.movId of
        G.MoveTowards aim ->
            Graphics.Collage.segment ( thing.x, thing.y ) ( aim.x, aim.y )
                |> Graphics.Collage.traced (Graphics.Collage.dotted thing.color)

        _ ->
            Graphics.Collage.group []


showKey : G.Thing -> Form
showKey thing =
    case thing.inpId of
        G.FollowMouse c ->
            c
                |> String.fromChar
                |> Text.fromString
                |> Graphics.Collage.text
                |> Graphics.Collage.move ( thing.x, thing.y )

        _ ->
            Graphics.Collage.group []
