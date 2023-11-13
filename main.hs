module Main where

import Data.Foldable
import Turtle
import Turtle.Prelude

main :: IO ()
main = do
  who <- hostname
  for_ (textToLine who) echo
