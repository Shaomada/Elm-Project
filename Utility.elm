module Utility where

import Maybe exposing (Maybe)
import Signal exposing (Signal)

mapBoth : (a -> b) -> Signal (Maybe a) -> Signal (Maybe b)
mapBoth = Signal.map << Maybe.map
