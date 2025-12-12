{-
-- EPITECH PROJECT, 2025
-- Main module
-- File description:
-- main of the glory glados
-}
module Main (main) where

import System.IO (hIsTerminalDevice, stdin)
import System.Environment (getArgs)
import System.Exit (die)
import Console (runConsole, runBatch)
import Parser (parseSExprMultipleEither)
import AST (sexprToAST, Ast(..))
import Compiler (compileToObject, compileToLL)

main :: IO ()
main = getArgs >>= dispatch

dispatch :: [String] -> IO ()
dispatch ["-S", llOut] = compileFromStdin (compileToLL llOut)
dispatch ["-c", objOut] = compileFromStdin (compileToObject objOut)
dispatch [] = runInteractive
dispatch _ = die "Usage: glados [-S out.ll | -c out.o]"

runInteractive :: IO ()
runInteractive = do
    isTTY <- hIsTerminalDevice stdin
    if isTTY then runConsole else getContents >>= runBatch

compileFromStdin :: (Ast -> IO ()) -> IO ()
compileFromStdin compile = do
    input <- getContents
    case parseSExprMultipleEither input of
        Left err -> die ("Parsing error:\n" ++ err)
        Right sexprs -> case mapM sexprToAST sexprs of
            Left perr -> die perr
            Right asts -> compile (Block asts)
