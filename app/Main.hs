{-
-- EPITECH PROJECT, 2025
-- Main module
-- File description:
-- main of the glory glados
-}
module Main (main) where

import System.IO (hIsTerminalDevice, stdin, getContents)
import Console (runConsole, runBatch)

main :: IO ()
main = do
    isTTY <- hIsTerminalDevice stdin
    if isTTY
        then runConsole
        else getContents >>= runBatch
