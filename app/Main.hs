{-
-- EPITECH PROJECT, 2025
-- Main module
-- File description:
-- main of the glory glados
-}
module Main (main) where

import Lib (SExpr(..), Ast(..), sexprToAST, evalAST)

main :: IO ()
main =
    let sexpr = SList [SSymbol "*", SList[SSymbol "+", SInt 2, SInt 4], SInt 7]
    in printResult sexpr

printResult :: SExpr -> IO ()
printResult sexpr =
    case sexprToAST sexpr of
        Just ast ->
            print ast >> printEval ast
        Nothing -> putStrLn "Parsing error"

printEval :: Ast -> IO ()
printEval ast =
    case evalAST ast of
        Just result -> print result
        Nothing     -> putStrLn "Evaluation error"
