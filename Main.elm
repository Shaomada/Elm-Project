module Main (..) where

import Signal
import Graphics.Element

import GameTypes as G
import Updates as U
import Shows as S
import Levels as L
import Input as I

model : Signal G.Model
model = Signal.foldp U.update L.initial I.input

main : Signal Graphics.Element.Element
main = Signal.map S.show model
