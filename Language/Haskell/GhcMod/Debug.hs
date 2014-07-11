module Language.Haskell.GhcMod.Debug (debugInfo, rootInfo) where

import Control.Applicative ((<$>))
import CoreMonad (liftIO)
import Data.List (intercalate)
import Data.Maybe (isJust, fromJust)
import Language.Haskell.GhcMod.CabalApi
import Language.Haskell.GhcMod.GHCApi
import Language.Haskell.GhcMod.GHCChoice ((||>))
import Language.Haskell.GhcMod.Convert
import Language.Haskell.GhcMod.Monad
import Language.Haskell.GhcMod.Types

----------------------------------------------------------------

-- | Obtaining debug information.
debugInfo :: GhcMod String
debugInfo = cradle >>= \c -> convert' =<< do
    CompilerOptions gopts incDir pkgs <-
        if isJust $ cradleCabalFile c then
            (fromCabalFile c ||> simpleCompilerOption)
          else
            simpleCompilerOption
    return [
        "Root directory:      " ++ cradleRootDir c
      , "Current directory:   " ++ cradleCurrentDir c
      , "Cabal file:          " ++ show (cradleCabalFile c)
      , "GHC options:         " ++ unwords gopts
      , "Include directories: " ++ unwords incDir
      , "Dependent packages:  " ++ intercalate ", " (map showPkg pkgs)
      , "System libraries:    " ++ systemLibDir
      ]
  where
    simpleCompilerOption = options >>= \op ->
        return $ CompilerOptions (ghcOpts op) [] []
    fromCabalFile c = options >>= \opts -> liftIO $ do
        pkgDesc <- parseCabalFile $ fromJust $ cradleCabalFile c
        getCompilerOptions (ghcOpts opts) c pkgDesc

----------------------------------------------------------------

-- | Obtaining root information.
rootInfo :: GhcMod String
rootInfo = convert' =<< cradleRootDir <$> cradle
