module Menue exposing (..)

import Shared
import Keyboard
import Char
import Collage
import Text
import Color


-- MODEL --


type alias Model =
    ()


init : Model
init =
    ()



-- UPDATE --


type Msg
    = KeyDown Char


update : Msg -> Model -> ( Model, Shared.Msg )
update (KeyDown c) model =
    case c of
        'E' ->
            ( model, Shared.OpenEditor )

        'G' ->
            ( model, Shared.Play )

        _ ->
            ( model, Shared.EndUpdate )



-- SUBSCRIPTIONS --


subscriptions : Model -> Sub Msg
subscriptions model =
    Keyboard.downs <| KeyDown << Char.fromCode



-- VIEW --


view : Model -> ( List Collage.Form, List Collage.Form )
view model =
    ( []
    , [ "Press e to open the Editor"
            |> Text.fromString
            |> Text.style
                { typeface = []
                , height = Just 30
                , color = Color.lightPurple
                , bold = True
                , italic = False
                , line = Nothing
                }
            |> Collage.text
            |> Collage.alpha 0.8
      , "Press g to play the Game"
            |> Text.fromString
            |> Text.style
                { typeface = []
                , height = Just 30
                , color = Color.lightPurple
                , bold = True
                , italic = False
                , line = Nothing
                }
            |> Collage.text
            |> Collage.alpha 0.8
            |> Collage.move ( 0, -100 )
      ]
    )
