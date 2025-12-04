{-
-- EPITECH PROJECT, 2025
-- Main module
-- File description:
-- main of the glory glados
-}
module Main (main) where

import System.Exit (exitWith, ExitCode(ExitFailure))
import System.IO (hPutStrLn, stderr, hFlush, stdout,
                  hIsTerminalDevice, stdin, isEOF)
import Lib (SExpr(..), Ast(..), parseSExprMultipleEither, sexprToAST, evalAST)

main :: IO ()
main = do
    isTTY <- hIsTerminalDevice stdin
    if isTTY
        then repl []
        else do
            input <- getContents
            case parseSExprMultipleEither input of
                Right sexprs -> evalSequence [] sexprs
                Left err -> printError ("Parsing error:\n" ++ err) >>
                            exitWith (ExitFailure 84)

repl :: Env -> IO ()
repl env = putStr "> " >> hFlush stdout >> isEOF >>= handleEof env

handleEof :: Env -> Bool -> IO ()
handleEof _ True = putStrLn ""
handleEof env False = getLine >>= handleInput env

handleInput :: Env -> String -> IO ()
handleInput env input
    | null (trim input) = repl env
    | otherwise = case parseSExprMultipleEither input of
        Right sexprs -> evalReplSequence env sexprs
        Left _ -> printError "Parsing error" >> repl env

evalReplSequence :: Env -> [SExpr] -> IO ()
evalReplSequence env [] = repl env
evalReplSequence env (s:ss) =
    case sexprToAST s of
        Right ast -> evalReplAst env ss ast
        Left err -> printError err >> repl env

evalReplAst :: Env -> [SExpr] -> Ast -> IO ()
evalReplAst env ss ast =
    case evalAST env ast of
        Right (result, env') -> printResult' result >> evalReplSequence env' ss
        Left err -> printError err >> repl env

trim :: String -> String
trim = dropWhile (== ' ') . reverse . dropWhile (== ' ') . reverse

evalSequence :: Env -> [SExpr] -> IO ()
evalSequence _ [] = return ()
evalSequence env (s:ss) =
    case sexprToAST s of
        Right ast ->
            case evalAST env ast of
                Right (result, env') -> printResult' result >>
                                        evalSequence env' ss
                Left err -> printError err >> exitWith (ExitFailure 84)
        Left err -> printError err >> exitWith (ExitFailure 84)

printError :: String -> IO ()
printError msg = hPutStrLn stderr ("*** ERROR : " ++ msg)

printResult' :: Ast -> IO ()
printResult' (AstInt n) = print n
printResult' (AstBool True) = putStrLn "#t"
printResult' (AstBool False) = putStrLn "#f"
printResult' AstVoid = return ()
printResult' (AstClosure _ _ _) = putStrLn "#<procedure>"
printResult' result = print result

type Env = [(String, Ast)]
