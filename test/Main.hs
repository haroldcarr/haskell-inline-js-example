{-# LANGUAGE DerivingVia          #-}
{-# LANGUAGE OverloadedLists      #-}
{-# LANGUAGE OverloadedStrings    #-}
{-# LANGUAGE QuasiQuotes          #-}
{-# LANGUAGE ScopedTypeVariables  #-}
{-# LANGUAGE TemplateHaskell      #-}
{-# LANGUAGE TypeApplications     #-}
{-# LANGUAGE UndecidableInstances #-}

import           Language.JavaScript.Inline
import           Paths_inline_js_example
import           System.FilePath
import           Test.Tasty
import           Test.Tasty.HUnit           hiding (assert)

main :: IO ()
main = do
  data_dir <- getDataDir
  defaultMain $
    testGroup
      "inline-js-example"
      [
        withResource
          ( newSession
              defaultConfig
                { nodeModules = Just $ data_dir </> "jsbits" </> "node_modules"
                }
          )
          killSession
          $ \m -> testCase "left-pad" $ do
            s <- m
            (Aeson r :: Aeson String) <-
              eval
                s
                [js| require('left-pad')('foo', 5) |]
            r @?= "  foo"
      ]

