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
    let dFoo = SList [SSymbol "define", SSymbol "foo", SInt 9]
        cond      = SList [SSymbol "<", SSymbol "foo", SInt 10]
        thExpr  = SList [SSymbol "*", SSymbol "foo", SInt 3]
        elExpr  = SList [SSymbol "div", SSymbol "foo", SInt 2]
        sexpr     = SList [dFoo, SList [SSymbol "if", cond, thExpr, elExpr]]
    in printResult sexpr

printResult :: SExpr -> IO ()
printResult sexpr =
    case sexprToAST sexpr of
        Just ast ->
            print ast >> printEval ast
        Nothing -> putStrLn "Parsing error"

printEval :: Ast -> IO ()
printEval ast =
    case evalAST [] ast of
        Just (result, _) -> print result
        Nothing     -> putStrLn "Evaluation error"
