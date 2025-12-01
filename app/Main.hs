{-
-- EPITECH PROJECT, 2025
-- Main module
-- File description:
-- main of the glory glados
-}
module Main (main) where

import System.Exit (exitWith, ExitCode(ExitFailure))
import System.IO (hPutStrLn, stderr)
import Lib (SExpr(..), Ast(..), parseSExpr, parseSExprMultiple,
            parseSExprMultipleEither, sexprToAST, evalAST)

main :: IO ()
main = do
    input <- getContents
    case parseSExprMultipleEither input of
        Right sexprs -> evalSequence [] sexprs
        Left err -> hPutStrLn stderr ("*** ERROR: " ++ err) >>
                    exitWith (ExitFailure 84)

testExprMultiple :: String -> IO ()
testExprMultiple input = putStrLn ("\n--- Testing: " ++ input ++ " ---") >>
    case parseSExprMultiple input of
        Just sexprs -> evalSequence [] sexprs
        Nothing -> putStrLn "Parser error"

evalSequence :: Env -> [SExpr] -> IO ()
evalSequence _ [] = return ()
evalSequence env (s:ss) =
    case sexprToAST s of
        Just ast ->
            case evalAST env ast of
                Just (result, env') -> printResult' result >>
                                       evalSequence env' ss
                Nothing -> hPutStrLn stderr "*** ERROR: Evaluation error" >>
                           exitWith (ExitFailure 84)
        Nothing -> hPutStrLn stderr "*** ERROR: Parsing error" >>
                   exitWith (ExitFailure 84)

printResult' :: Ast -> IO ()
printResult' (AstInt n) = print n
printResult' (AstBool True) = putStrLn "#t"
printResult' (AstBool False) = putStrLn "#f"
printResult' AstVoid = return ()
printResult' (AstClosure _ _ _) = putStrLn "#<procedure>"
printResult' result = print result

type Env = [(String, Ast)]