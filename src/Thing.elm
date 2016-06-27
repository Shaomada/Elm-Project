module Thing exposing (..)

import Geometry exposing (..)
import Maybe exposing (Maybe)
import String
import Text
import Color
import Collage


-- MODEL


type Id
    = Player { handle : Char, handleDown : Bool }
    | Enemy { distance : Maybe Float }
    | Bouncy {}
    | Block {}
    | Dead {}
    | Zone
        { pattern : Thing -> Bool
        , done : Bool
        }


type alias Model =
    { id : Id
    , x : Float
    , y : Float
    , target : Maybe { x : Float, y : Float }
    , radius : Float
    , speed : Float
    , color : Color.Color
    , alpha : Float
    }


type alias Thing =
    Model


model : Id -> { a | radius : Float, speed : Float, color : Color.Color, alpha : Float } -> { b | x : Float, y : Float } -> Thing
model id { radius, speed, color, alpha } { x, y } =
    { id = id
    , x = x
    , y = y
    , target = Nothing
    , radius = radius
    , speed = speed
    , color = color
    , alpha = alpha
    }


player : Char -> { a | x : Float, y : Float } -> Thing
player c =
    model (Player { handle = c, handleDown = False })
        { radius = 30
        , speed = 70
        , color = Color.blue
        , alpha = 0.9
        }


enemy : { a | x : Float, y : Float } -> Thing
enemy =
    model (Enemy { distance = Nothing })
        { radius = 50
        , speed = 45
        , color = Color.red
        , alpha = 0.8
        }


bouncy : { a | x : Float, y : Float } -> Thing
bouncy =
    model (Bouncy {})
        { radius = 20
        , speed = 60
        , color = Color.green
        , alpha = 0.9
        }


block : { a | x : Float, y : Float } -> Thing
block =
    model (Block {})
        { radius = 20
        , speed = 60
        , color = Color.black
        , alpha = 0.9
        }


dead : Thing -> Thing
dead thing =
    model (Dead {})
        { thing
            | color = Color.yellow
            , speed = 0
            , alpha = 0.4
        }
        thing


zone : Thing -> Float -> { a | x : Float, y : Float } -> Thing
zone thing radius =
    model (Zone { pattern = equalId thing, done = False })
        { radius = radius
        , speed = 0
        , color = thing.color
        , alpha = 0.25
        }


pos =
    { x = 0, y = 0 }


zonePlayer =
    zone <| player '\n' pos


zoneEnemy =
    zone <| enemy pos


zoneBouncy =
    zone <| bouncy pos


zoneDead =
    zone <| dead <| block pos


equalId : Thing -> Thing -> Bool
equalId a b =
    case ( a.id, b.id ) of
        ( Player _, Player _ ) ->
            True

        ( Enemy _, Enemy _ ) ->
            True

        ( Bouncy _, Bouncy _ ) ->
            True

        ( Block _, Block _ ) ->
            True

        ( Dead _, Dead _ ) ->
            True

        ( Zone _, Zone _ ) ->
            True

        _ ->
            False



-- UPDATE


type Msg
    = KeyDown Char
    | KeyUp Char
    | MouseMoved { x : Float, y : Float }
    | TimeDiff Float


update : Msg -> Thing -> Thing
update msg thing =
    case ( msg, thing.id ) of
        ( KeyDown char, Player { handle, handleDown } ) ->
            { thing
                | id =
                    Player
                        { handle = handle
                        , handleDown = handleDown || handle == char
                        }
            }

        ( KeyUp char, Player { handle, handleDown } ) ->
            { thing
                | id =
                    Player
                        { handle = handle
                        , handleDown = handleDown && handle /= char
                        }
            }

        ( MouseMoved pos, Player { handle, handleDown } ) ->
            if handleDown then
                { thing
                    | target = Just pos
                }
            else
                thing

        ( TimeDiff t, _ ) ->
            reset <| moveFor t thing

        _ ->
            thing


reset : Thing -> Thing
reset thing =
    case thing.id of
        Enemy _ ->
            { thing | id = Enemy { distance = Nothing } }

        Zone x ->
            { thing | id = Zone { x | done = False } }

        _ ->
            thing


moveFor : Float -> Thing -> Thing
moveFor time thing =
    case thing.target of
        Nothing ->
            thing

        Just { x, y } ->
            let
                ( distance, angle ) =
                    toPolar ( x - thing.x, y - thing.y )

                ( dx, dy ) =
                    fromPolar ( min distance <| thing.speed * time, angle )
            in
                { thing
                    | x = thing.x + dx
                    , y = thing.y + dy
                }


interact : Model -> Model -> Model
interact that this =
    case ( this.id, that.id ) of
        -- dependend on this
        ( Zone { pattern, done }, _ ) ->
            if isWithin that this then
                { this | id = Zone { pattern = pattern, done = done || pattern that } }
            else
                this

        -- dependend on that
        ( _, Block _ ) ->
            moveOutOff that this

        ( Player _, Bouncy _ ) ->
            this

        ( _, Bouncy _ ) ->
            moveOutOff that this

        -- special cases
        ( Enemy e, Player _ ) ->
            if
                e.distance
                    |> Maybe.map (\d -> d > distance that this)
                    |> Maybe.withDefault True
            then
                { this
                    | target =
                        Just
                            { x = that.x
                            , y = that.y
                            }
                    , id =
                        Enemy { distance = Just <| distance that this }
                }
            else
                this

        ( Player _, Enemy _ ) ->
            if touching that this then
                dead this
            else
                this

        ( Player _, Player _ ) ->
            if touching that this then
                moveOutOff that this
            else
                this

        ( Bouncy _, Player _ ) ->
            if touching that this then
                moveOutOff that <| getPushedBy that this
            else
                this

        _ ->
            this



-- VIEW


view : Int -> Thing -> Collage.Form
view layer =
    case layer of
        0 ->
            viewBoundry

        1 ->
            viewBody

        2 ->
            viewPath

        3 ->
            viewId

        _ ->
            \_ -> Collage.group []


viewBoundry : Thing -> Collage.Form
viewBoundry thing =
    case thing.id of
        Zone { done } ->
            if done then
                Collage.circle thing.radius
                    |> Collage.outlined (Collage.solid thing.color)
                    |> Collage.move ( thing.x, thing.y )
            else
                Collage.circle thing.radius
                    |> Collage.outlined (Collage.solid Color.lightGray)
                    |> Collage.move ( thing.x, thing.y )

        _ ->
            Collage.circle thing.radius
                |> Collage.outlined (Collage.solid Color.black)
                |> Collage.alpha 0.7
                |> Collage.move ( thing.x, thing.y )


viewBody : Thing -> Collage.Form
viewBody thing =
    Collage.circle thing.radius
        |> Collage.filled thing.color
        |> Collage.alpha thing.alpha
        |> Collage.move ( thing.x, thing.y )


viewPath : Thing -> Collage.Form
viewPath thing =
    thing.target
        |> Maybe.map
            (\target ->
                Collage.segment ( thing.x, thing.y ) ( target.x, target.y )
                    |> Collage.traced (Collage.dotted thing.color)
            )
        |> Maybe.withDefault (Collage.group [])


viewId : Thing -> Collage.Form
viewId thing =
    case thing.id of
        Player { handle, handleDown } ->
            handle
                |> String.fromChar
                |> Text.fromString
                |> Collage.text
                |> Collage.move ( thing.x, thing.y )

        _ ->
            Collage.group []
