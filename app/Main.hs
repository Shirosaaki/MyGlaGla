{-
-- EPITECH PROJECT, 2025
-- Main module
-- File description:
-- main of the glory glados
-}
module Main (main) where

import Lib (SExpr(..), Ast(..), parseSExpr, sexprToAST, evalAST)

main :: IO ()
main = do
    testExpr "(define (add a b) (+ a b)) (add 5 7)"
    testExpr "(+ 1 2)"
    
testExpr :: String -> IO ()
testExpr input = do
    putStrLn $ "\n--- Testing: " ++ input ++ " ---"
    case parseSExpr input of
        Just sexpr -> do
            putStrLn $ "Parsed: " ++ show sexpr
            printResult sexpr
        Nothing -> putStrLn "Parser error"

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