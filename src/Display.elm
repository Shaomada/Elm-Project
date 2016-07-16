module Display exposing (..)

import Window
import Mouse
import AnimationFrame
import Time
import List
import Collage
import Element
import Random
import Shared exposing (only, andThen)


type alias Model =
    { size : { width : Int, height : Int }
    , mousePosition : { x : Float, y : Float }
    , viewPosition : { x : Float, y : Float }
    }


init : Model
init =
    { size = { width = 1200, height = 800 }
    , mousePosition = { x = 0, y = 0 }
    , viewPosition = { x = 0, y = 0 }
    }



-- UPDATE


type Msg
    = WindowResize { width : Int, height : Int }
    | RawMouseMoved { x : Int, y : Int }
    | TimePassed Float
    | ResetViewPosition { x : Float, y : Float }


update : Msg -> Model -> ( Model, Shared.Msg )
update msg display =
    let
        display' =
            update' msg display
    in
        let
            display' =
                update' msg display

            sharedMsg =
                Shared.MouseMoved
                    { x = display'.mousePosition.x + display'.viewPosition.x
                    , y = display'.mousePosition.y + display'.viewPosition.y
                    , xRaw = display'.mousePosition.x
                    , yRaw = display'.mousePosition.y
                    }
        in
            display' `andThen` sharedMsg


update' : Msg -> Model -> Model
update' msg display =
    case msg of
        WindowResize size ->
            { display | size = size }

        RawMouseMoved { x, y } ->
            { display
                | mousePosition =
                    { x = toFloat x - (toFloat display.size.width) / 2
                    , y = (toFloat display.size.height) / 2 - toFloat y
                    }
            }

        ResetViewPosition pos ->
            { display | viewPosition = pos }

        TimePassed t ->
            { display
                | viewPosition =
                    { x =
                        display.viewPosition.x
                            + 3
                            * t
                            * (max 0 <| display.mousePosition.x + 50 - 0.5 * toFloat display.size.width)
                            - 3
                            * t
                            * (max 0 <| 50 - display.mousePosition.x - 0.5 * toFloat display.size.width)
                    , y =
                        display.viewPosition.y
                            + 3
                            * t
                            * (max 0 <| display.mousePosition.y + 50 - 0.5 * toFloat display.size.height)
                            - 3
                            * t
                            * (max 0 <| 50 - display.mousePosition.y - 0.5 * toFloat display.size.height)
                    }
            }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions display =
    Sub.batch
        [ Window.resizes WindowResize
        , AnimationFrame.diffs <| TimePassed << Time.inSeconds
        , Mouse.moves RawMouseMoved
        ]



-- VIEW


view : Model -> ( List Collage.Form, List Collage.Form ) -> Element.Element
view display ( dynamic, static ) =
    dynamic
        |> List.map (Collage.move ( -display.viewPosition.x, -display.viewPosition.y ))
        |> List.append static
        |> Collage.collage display.size.width display.size.height
