module GameTypes (..) where

import Color
import Set


type InputHandlingId
    = Ignore
    | FollowMouse Char


type MoveId
    = Move
    | MoveTowards (Pos Emp)


type InteractionId
    = Player {}
    | Enemy { distance : Maybe Float }
    | Bouncy {}
    | Block {}
    | Dead {}
    | Zone
        { pattern : Thing -> Bool
        , done : Bool
        }


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
        , alpha : Float
    }


type alias Thing =
    Col (Cir (Mot (Pos Meta)))



--


type alias Emp =
    {}


type alias Win a =
    { a
        | windowHeight : Int
        , windowWidth : Int
    }


type alias GMod b =
    { b
        | things : List Thing
        , won : Bool
        , level : Int
        , messages : List String
    }


type alias Model =
    Win (GMod Emp)


type alias Tim a =
    { a | timePassed : Float }


type alias Key a =
    { a | keysDown : Set.Set Char }


type alias But a =
    { a | isDown : Bool }


type alias GInp a =
    Tim (Pos (Key (But a)))


type alias Input =
    Win (GInp Emp)
