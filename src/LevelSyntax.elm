module LevelSyntax exposing (..)

import Thing
import Color


type alias Model =
    { numberPlayers : Int
    , things : List Thing.Model
    , text : List String
    }


empty : Model
empty =
    { numberPlayers = 0
    , things = []
    , text = []
    }


type alias Command =
    Model -> Model



-- adds a player at x y


player : Float -> Float -> Command
player x y model =
    { model
        | numberPlayers = model.numberPlayers + 1
        , things =
            model.things
                |> (::)
                    { id =
                        Thing.Player
                            { handle =
                                case model.numberPlayers of
                                    0 ->
                                        '1'

                                    1 ->
                                        '2'

                                    2 ->
                                        '3'

                                    3 ->
                                        '4'

                                    4 ->
                                        '5'

                                    5 ->
                                        '6'

                                    6 ->
                                        '7'

                                    7 ->
                                        '8'

                                    8 ->
                                        '9'

                                    9 ->
                                        '0'

                                    _ ->
                                        '?'
                            , handleDown = False
                            }
                    , x = x
                    , y = y
                    , target = Nothing
                    , radius = 30
                    , speed = 70
                    , color = Color.blue
                    , alpha = 0.9
                    }
    }



-- adds an enemy at x y


enemy : Float -> Float -> Command
enemy x y model =
    { model
        | things =
            model.things
                |> (::)
                    { id = Thing.Enemy { distance = Nothing }
                    , x = x
                    , y = y
                    , target = Nothing
                    , radius = 50
                    , speed = 45
                    , color = Color.red
                    , alpha = 0.8
                    }
    }



-- adds a Bouncy at x y


bouncy : Float -> Float -> Command
bouncy x y model =
    { model
        | things =
            model.things
                |> (::)
                    { id = Thing.Bouncy {}
                    , x = x
                    , y = y
                    , target = Nothing
                    , radius = 20
                    , speed = 60
                    , color = Color.green
                    , alpha = 0.9
                    }
    }



-- adds a Block at x y


block : Float -> Float -> Command
block x y model =
    { model
        | things =
            model.things
                |> (::)
                    { id = Thing.Block {}
                    , x = x
                    , y = y
                    , target = Nothing
                    , radius = 20
                    , speed = 0
                    , color = Color.black
                    , alpha = 0.9
                    }
    }



-- makes a zone checking for type of head of things or for nothing if empty


zone : Float -> Float -> Command
zone x y model =
    case model.things of
        [] ->
            { model
                | things =
                    model.things
                        |> (::)
                            { id =
                                Thing.Zone
                                    { pattern = Thing.impossible
                                    , done = False
                                    }
                            , x = x
                            , y = y
                            , target = Nothing
                            , radius = 0
                            , speed = 0
                            , color = Color.white
                            , alpha = 0
                            }
            }

        thing :: things ->
            { model
                | things =
                    things
                        |> (::) thing
                        |> (::)
                            { thing
                                | id =
                                    Thing.Zone
                                        { pattern = Thing.compareTypeTo thing
                                        , done = False
                                        }
                                , x = x
                                , y = y
                                , radius = thing.radius + 10
                                , target = Nothing
                                , speed = 0
                                , alpha = 0.4
                            }
            }



-- transforms head of things into a zone checking for it's former type, slightly increasing radius


asZone : Command
asZone model =
    case model.things of
        [] ->
            model

        thing :: things ->
            { model
                | things =
                    things
                        |> (::)
                            { thing
                                | id =
                                    Thing.Zone
                                        { pattern = Thing.compareTypeTo thing
                                        , done = False
                                        }
                                , radius = thing.radius + 10
                                , target = Nothing
                                , speed = 0
                                , alpha = 0.4
                            }
            }



-- adds dead version of head of things


dead : Float -> Float -> Command
dead x y model =
    case model.things of
        [] ->
            model

        thing :: things ->
            { model | things = Thing.die { thing | x = x, y = y } :: thing :: things }



-- transforms head of things into a dead


asDead : Command
asDead model =
    case model.things of
        [] ->
            model

        thing :: things ->
            { model | things = Thing.die thing :: things }



-- changes target of head of things


target : Float -> Float -> Command
target x y model =
    case model.things of
        [] ->
            model

        thing :: things ->
            { model | things = (::) { thing | target = Just { x = x, y = y } } things }


radius : Float -> Command
radius r model =
    case model.things of
        [] ->
            model

        thing :: things ->
            { model | things = (::) { thing | radius = r } things }


speed : Float -> Command
speed s model =
    case model.things of
        [] ->
            model

        thing :: things ->
            { model | things = (::) { thing | speed = s } things }


color : Color.Color -> Command
color c model =
    case model.things of
        [] ->
            model

        thing :: things ->
            { model | things = (::) { thing | color = c } things }


alpha : Float -> Command
alpha r model =
    case model.things of
        [] ->
            model

        thing :: things ->
            { model | things = (::) { thing | radius = r } things }


text : String -> Command
text string model =
    { model | text = string :: model.text }
