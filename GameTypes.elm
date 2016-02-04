module GameTypes (..) where

import Color

-- Thing

type InputHandlingId =
  Ignore
  | FollowMouse


type MoveId =
  Move
  | MoveTowards (Pos Emp)


type InteractionId =
    Player
    | Enemy
    | Bouncy


type alias Meta =
  { inpId : InputHandlingId
  , intId : InteractionId
  , movId : MoveId
  , speedCap : Float
  }


type alias Pos a =
    { a
        | x : Float
        , y : Float
    }


type alias Mot a =
    { a
        | speed : Float
        , angle : Float
    }


type alias Cir a =
    { a | radius : Float }


type alias Col a =
  { a
      | color : Color.Color
  }

    
type alias Thing = Col (Cir (Mot (Pos Meta) ) )


--


type alias Emp =
    {}
 

type alias Win a =
  { a
      | windowHeight : Int
      , windowWidth : Int
  }


type alias GMod b =
    { b | things : List Thing
    }


type alias Model = Win (GMod ( Emp ) )


-- Input


type alias Tim a =
    { a | timePassed : Float }


type alias GInp a = Tim (Pos (Mot a) )


type alias Input = Win (GInp Emp)
