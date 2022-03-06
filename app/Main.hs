module Main where

import qualified Lib

main :: IO ()
main  = do
  --DNS.dnsLookup "haroldcarr.com" >>= print
  Lib.leftPad >>= print
