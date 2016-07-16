module Geometry exposing (..)


distance : { a | x : Float, y : Float } -> { b | x : Float, y : Float } -> Float
distance that this =
    (that.x - this.x)
        ^ 2
        + (that.y - this.y)
        ^ 2
        |> sqrt


touching : { a | x : Float, y : Float, radius : Float } -> { b | x : Float, y : Float, radius : Float } -> Bool
touching that this =
    distance that this <= this.radius + that.radius


isWithin : { a | x : Float, y : Float, radius : Float } -> { b | x : Float, y : Float, radius : Float } -> Bool
isWithin that this =
    distance that this < this.radius - that.radius


moveOutOff : { a | x : Float, y : Float, radius : Float } -> { b | x : Float, y : Float, radius : Float } -> { b | x : Float, y : Float, radius : Float }
moveOutOff that this =
    let
        ( distance, angle ) =
            toPolar ( this.x - that.x, this.y - that.y )

        ( x, y ) =
            fromPolar ( max distance <| that.radius + this.radius, angle )
    in
        { this
            | x = that.x + x
            , y = that.y + y
        }


getPushedBy : { a | x : Float, y : Float } -> { b | x : Float, y : Float, target : Maybe { x : Float, y : Float } } -> { b | x : Float, y : Float, target : Maybe { x : Float, y : Float } }
getPushedBy that this =
    let
        ( _, angle ) =
            toPolar ( this.x - that.x, this.y - that.y )

        ( x, y ) =
            fromPolar ( 300, angle )
    in
        { this | target = Just { x = this.x + x, y = this.y + y } }
