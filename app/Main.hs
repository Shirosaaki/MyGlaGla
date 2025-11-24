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
        cond = SList [SSymbol "<", SSymbol "foo", SInt 10]
        thExpr = SList [SSymbol "*", SSymbol "foo", SInt 3]
        elExpr = SList [SSymbol "div", SSymbol "foo", SInt 2]
        sexpr = SList [dFoo, SList [SSymbol "if", cond, thExpr, elExpr]]
        -- sexpr2 = SList [SSymbol "<", SInt 1, SList [SSymbol "mod", SInt 10, SInt 3]]
        -- sexpr = SList [ SList [SSymbol "define", SList [SSymbol ">", SSymbol "a", SSymbol "b"], SList [SSymbol "if", SList [SSymbol "eq?", SSymbol "a", SSymbol "b"], SBool False, SList [SSymbol "if", SList [SSymbol "<", SSymbol "a", SSymbol "b"], SBool False, SBool True]]], SList [SSymbol ">", SInt 10, SInt (-2)] ]
        -- sexpr4 = SList [SList [SSymbol "define", SList [SSymbol "fact", SSymbol "x"], SList [SSymbol "if", SList [SSymbol "eq?", SSymbol "x", SInt 1], SInt 1, SList [SSymbol "*", SSymbol "x", SList [SSymbol "fact", SList [SSymbol "-", SSymbol "x", SInt 1]]]]], SList [SSymbol "fact", SInt 10]]
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
        Just (AstInt n, _) -> print n
        Just (AstBool True, _) -> putStrLn "#t"
        Just (AstBool False, _) -> putStrLn "#f"
        Just (AstVoid, _) -> return ()
        Just (result, _) -> print result
        Nothing     -> putStrLn "Evaluation error"
