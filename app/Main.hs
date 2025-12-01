{-
-- EPITECH PROJECT, 2025
-- Main module
-- File description:
-- main of the glory glados
-}
module Main (main) where

import Lib (SExpr(..), Ast(..), parseSExpr, parseSExprMultiple, sexprToAST, evalAST)

main :: IO ()
main = do
    testExprMultiple "(define (add a b) (+ a b)) (add 5 7)"
    testExpr "(+ 1 2)"

testExprMultiple :: String -> IO ()
testExprMultiple input = do
    putStrLn $ "\n--- Testing: " ++ input ++ " ---"
    case parseSExprMultiple input of
        Just sexprs -> evalSequence [] sexprs
        Nothing -> putStrLn "Parser error"

evalSequence :: Env -> [SExpr] -> IO ()
evalSequence _ [] = return ()
evalSequence env (s:ss) =
    case sexprToAST s of
        Just ast ->
            case evalAST env ast of
                Just (result, env') -> do
                    printResult' result
                    evalSequence env' ss
                Nothing -> putStrLn "Evaluation error"
        Nothing -> putStrLn "Parsing error"

printResult' :: Ast -> IO ()
printResult' (AstInt n) = print n
printResult' (AstBool True) = putStrLn "#t"
printResult' (AstBool False) = putStrLn "#f"
printResult' AstVoid = return ()
printResult' result = print result

testExpr :: String -> IO ()
testExpr input = do
    putStrLn $ "\n--- Testing: " ++ input ++ " ---"
    case parseSExpr input of
        Just sexpr -> printResult sexpr
        Nothing -> putStrLn "Parser error"

printResult :: SExpr -> IO ()
printResult sexpr =
    case sexprToAST sexpr of
        Just ast -> case evalAST [] ast of
                Just (result, _) -> printResult' result
                Nothing -> putStrLn "Evaluation error"
        Nothing -> putStrLn "Parsing error"

type Env = [(String, Ast)]