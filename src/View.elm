module View exposing (..)

import Model exposing (..)
import Thing exposing (..)
import Msg exposing (Msg)

import Html exposing (Html)
import Text
import String
import Collage exposing (Form)
import Element exposing (Element)
import Color

view : Model -> Html Msg
view model = Element.toHtml <| view' model

view' : Model -> Element
view' { things, size, viewPosition, state, text } =
    [ List.map viewBoundry things
    , List.map viewBody things
    , List.map viewPath things
    , List.map viewKey things
    , message state text
    ]
        |> List.concat
        |> List.map (Collage.move (-viewPosition.x, -viewPosition.y))
        |> Collage.collage size.width size.height


message : Gamestate -> List String -> List Form
message state text = case state of
    Won ->
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
            |> Collage.text
            |> Collage.alpha 0.8
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
            |> Collage.text
            |> Collage.alpha 0.8
            |> Collage.move ( 0, -100 )
        ]
    Running ->
        text
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
                        |> Collage.text
                        |> Collage.alpha 0.8
                        |> Collage.move ( 0, -40 * toFloat (3 + line) )
                )
    Paused ->
        "Paused"
        |> Text.fromString
        |> Text.style
            { typeface = []
            , height = Just 30
            , color = Color.lightPurple
            , bold = False
            , italic = False
            , line = Nothing
            }
        |> Collage.text
        |> Collage.alpha 0.8
        |> Collage.move ( 0, -100 )
        |> \ a -> [a]


viewBoundry : Thing -> Form
viewBoundry thing =
    case thing.id of
        Zone { done } ->
            if
                done
            then
                Collage.circle thing.radius
                    |> Collage.outlined
                        (Collage.solid thing.color)
                    |> Collage.move ( thing.x, thing.y )
            else
                Collage.circle thing.radius
                    |> Collage.outlined
                        (Collage.solid Color.lightGray)
                    |> Collage.move ( thing.x, thing.y )

        _ ->
            Collage.circle thing.radius
                |> Collage.outlined
                    (Collage.solid Color.black)
                |> Collage.alpha 0.7
                |> Collage.move ( thing.x, thing.y )


viewBody : Thing -> Form
viewBody thing =
    Collage.circle thing.radius
        |> Collage.filled thing.color
        |> Collage.alpha thing.alpha
        |> Collage.move ( thing.x, thing.y )


viewPath : Thing -> Form
viewPath thing =
    thing.target
    |> Maybe.map
        ( \target ->
            Collage.segment ( thing.x, thing.y ) ( target.x, target.y )
                |> Collage.traced (Collage.dotted thing.color)
        )
    |> Maybe.withDefault
        (Collage.group [])


viewKey : Thing -> Form
viewKey thing =
    case thing.id of
        Player {handle, handleDown} ->
            handle
                |> String.fromChar
                |> Text.fromString
                |> Collage.text
                |> Collage.move ( thing.x, thing.y )

        _ ->
            Collage.group []
