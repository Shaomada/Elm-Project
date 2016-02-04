module GameTypes (..) where

import Color


type UpdateId
    = UpdateId Int


type alias ShowId =
    Color.Color


type alias E =
    {}


type alias Positioned a =
    { a
        | x : Float
        , y : Float
    }


type alias InMotion a =
    { a
        | speed : Float
        , angle : Float
    }

type alias MotionUpdate a =
    { a
      | diffSpeed : Float
      , diffAngle : Float
    }

type alias Circle a =
    { a | radius : Float }


type alias Timed a =
    { a | timePassed : Float }
 

type alias Windowed b =
  { b
      | windowHeight : Int
      , windowWidth : Int
  }

type alias Thing =
    Circle
        (Positioned
            (InMotion
                { uId : UpdateId
                , sId : ShowId
                }
            )
        )
type alias GameModel b =
    { b
        | player : Thing
        , things : List Thing
    }


type alias Model = Windowed ( GameModel ( E ) )

type alias GameInput a = MotionUpdate( Timed( Positioned( a ) ) )
type alias Input = Windowed ( GameInput( E ) )
