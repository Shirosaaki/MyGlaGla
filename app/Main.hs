{-
-- EPITECH PROJECT, 2025
-- Main module
-- File description:
-- main of the glory glados
-}
module Main (main) where

import System.Exit (exitWith, ExitCode(ExitFailure))
import System.IO (hPutStrLn, stderr, hIsTerminalDevice, stdin)
import Control.Monad.IO.Class (liftIO)
import System.Console.Haskeline
import Lib (SExpr(..), Ast(..), Type(..), Value(..), Env,
            parseSExprMultipleEither, sexprToAST, evalAST)

type ReplM = InputT IO

main :: IO ()
main = do
    isTTY <- hIsTerminalDevice stdin
    if isTTY
        then runInputT defaultSettings (repl [])
        else do
            input <- getContents
            case parseSExprMultipleEither input of
                Right sexprs -> evalSequence [] sexprs
                Left err -> printError ("Parsing error:\n" ++ err) >>
                            exitWith (ExitFailure 84)

repl :: Env -> ReplM ()
repl env = do
    minput <- promptMultiline "> " "| "
    case minput of
        Nothing -> outputStrLn ""  -- Ctrl-D exits
        Just input ->
            if null (trim input)
            then repl env
            else case parseSExprMultipleEither input of
                Right sexprs -> evalReplSequence env sexprs
                Left _ -> outputStrLn "Parsing error" >> repl env

evalReplSequence :: Env -> [SExpr] -> ReplM ()
evalReplSequence env [] = repl env
evalReplSequence env (s:ss) =
    case sexprToAST s of
        Right ast -> evalReplAst env ss ast
        Left err -> liftIO (printError err) >> repl env

evalReplAst :: Env -> [SExpr] -> Ast -> ReplM ()
evalReplAst env ss ast =
    case evalAST env ast of
        Right (result, env') -> printResult' result >> evalReplSequence env' ss
        Left err -> liftIO (printError err) >> repl env

trim :: String -> String
trim = dropWhile (== ' ') . reverse . dropWhile (== ' ') . reverse

evalSequence :: Env -> [SExpr] -> IO ()
evalSequence _ [] = return ()
evalSequence env (s:ss) =
    case sexprToAST s of
        Right ast ->
            case evalAST env ast of
                Right (result, env') -> printResultIO result >>
                                        evalSequence env' ss
                Left err -> printError err >> exitWith (ExitFailure 84)
        Left err -> printError err >> exitWith (ExitFailure 84)

printError :: String -> IO ()
printError msg = hPutStrLn stderr ("*** ERROR : " ++ msg)

printResult' :: Value -> ReplM ()
printResult' (VInt n) = outputStrLn (show n)
printResult' (VFloat f) = outputStrLn (show f)
printResult' (VBool True) = outputStrLn (show 1)
printResult' (VBool False) = outputStrLn (show 0)
printResult' (VString s) = outputStrLn s
printResult' (VChar c) = outputStrLn [c]
printResult' VVoid = return ()
printResult' (VClosure _ _ _) = outputStrLn "#<procedure>"
printResult' (VArray _) = outputStrLn "#<array>"
printResult' (VPointer _) = outputStrLn "#<pointer>"
printResult' (VStruct name _) = outputStrLn ("#<struct:" ++ name ++ ">")

printResultIO :: Value -> IO ()
printResultIO (VInt n) = print n
printResultIO (VFloat f) = print f
printResultIO (VBool True) = print 1
printResultIO (VBool False) = print 0
printResultIO (VString s) = putStrLn s
printResultIO (VChar c) = putStrLn [c]
printResultIO VVoid = return ()
printResultIO (VClosure _ _ _) = putStrLn "#<procedure>"
printResultIO (VArray _) = putStrLn "#<array>"
printResultIO (VPointer _) = putStrLn "#<pointer>"
printResultIO (VStruct name _) = putStrLn ("#<struct:" ++ name ++ ">")

-- | Multiline prompt: continue input when the user ends a line with a trailing backslash.
promptMultiline :: String -> String -> ReplM (Maybe String)
promptMultiline p cont = go True []
  where
    go first acc = do
        let pr = if first then p else cont
        mline <- getInputLine pr
        case mline of
            Nothing -> if null acc then return Nothing
                        else return (Just (unlines (reverse acc)))
            Just line ->
                if not (null line) && last line == '\\'
                    then go False ((init line) : acc)
                    else do
                        let acc' = line : acc
                        return (Just (unlines (reverse acc')))
