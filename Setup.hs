#!/usr/bin/env runhaskell

import           Distribution.Simple
import           Distribution.Simple.Program

import           Distribution.Extra.Doctest

main :: IO ()
main =
    defaultMainWithHooks $
    addDoctestsUserHook "doctest" $
    simpleUserHooks {
        hookedPrograms = [ simpleProgram "shelltest" ]
    }
