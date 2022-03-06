{-# LANGUAGE DeriveAnyClass      #-}
{-# LANGUAGE DeriveGeneric       #-}
{-# LANGUAGE QuasiQuotes         #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Lib where

import           Data.Aeson
import           GHC.Generics
import           Language.JavaScript.Inline
import           Paths_inline_js_example
import           System.FilePath

leftPad :: IO String
leftPad  = do
  data_dir <- getDataDir
  s        <- newSession
              (defaultConfig { nodeModules = Just $ data_dir </> "jsbits" </> "node_modules" })
  (Aeson r :: Aeson String) <-
    eval
      s
      [js| require('left-pad')('foo', 5) |]
  --killSession s
  pure r
