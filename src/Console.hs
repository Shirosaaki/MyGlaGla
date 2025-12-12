{-
-- EPITECH PROJECT, 2025
-- Console
-- File description:
-- Interactive REPL and batch execution
-}
module Console (runConsole, runBatch) where

import System.Exit (exitWith, ExitCode(ExitFailure))
import System.IO (hPutStrLn, stderr)
import Control.Monad.IO.Class (liftIO)
import System.Console.Haskeline
import AST (SExpr(..), Ast(..), Value(..), Env,
            sexprToAST, evalAST)
import Parser (parseSExprMultipleEither)

-- Interactive REPL runner
runConsole :: IO ()
runConsole = runInputT defaultSettings (repl [])

type ReplM = InputT IO

repl :: Env -> ReplM ()
repl env = do
    minput <- getInputLine "> "
    case minput of
        Nothing -> outputStrLn ""  -- Ctrl-D exits
        Just line -> handleInput env line

-- | Route input based on command or content
handleInput :: Env -> String -> ReplM ()
handleInput env ":code" = captureBlock env []
handleInput env line
    | null (trim line) = repl env
    | otherwise = handleLine env line

-- | Handle a single-line entry: parse and evaluate immediately.
handleLine :: Env -> String -> ReplM ()
handleLine env line =
    case parseSExprMultipleEither line of
        Right sexprs -> evalReplSequence env sexprs
        Left _ -> outputStrLn "Parsing error" >> repl env

-- | Capture a multi-line block until ':end', then execute the whole block.
captureBlock :: Env -> [String] -> ReplM ()
captureBlock env acc = do
    mline <- getInputLine "| "
    case mline of
        Nothing -> outputStrLn ""  -- EOF exits block
        Just ":end" -> execBlock env acc
        Just line -> captureBlock env (line : acc)

execBlock :: Env -> [String] -> ReplM ()
execBlock env acc =
    let block = unlines (reverse acc)
    in if null (trim block)
       then repl env
       else case parseSExprMultipleEither block of
           Right sexprs -> evalReplSequence env sexprs
           Left _ -> outputStrLn "Parsing error" >> repl env

-- | Evaluate a list of s-expressions in the REPL context.
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

-- Batch execution for stdin pipelines
runBatch :: String -> IO ()
runBatch input =
    case parseSExprMultipleEither input of
        Right sexprs -> evalSequence [] sexprs
        Left err -> printError ("Parsing error:\n" ++ err) >>
                    exitWith (ExitFailure 84)

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
printResult' (VBool True) = outputStrLn "#t"
printResult' (VBool False) = outputStrLn "#f"
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
printResultIO (VBool True) = putStrLn "#t"
printResultIO (VBool False) = putStrLn "#f"
printResultIO (VString s) = putStrLn s
printResultIO (VChar c) = putStrLn [c]
printResultIO VVoid = return ()
printResultIO (VClosure _ _ _) = putStrLn "#<procedure>"
printResultIO (VArray _) = putStrLn "#<array>"
printResultIO (VPointer _) = putStrLn "#<pointer>"
printResultIO (VStruct name _) = putStrLn ("#<struct:" ++ name ++ ">")
