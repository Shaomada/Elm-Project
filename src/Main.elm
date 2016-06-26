module Main exposing (..)

import Levels
import View
import Update
import Subscriptions

import Html.App

main =
  Html.App.program
    { init = Levels.init ! []
    , view = View.view
    , update = Update.update
    , subscriptions = Subscriptions.subscriptions
    }
