{-
-- EPITECH PROJECT, 2025
-- Console
-- File description:
-- Interactive REPL and batch execution
-}
module Console (runConsole, runBatch) where

import System.Exit (exitWith, ExitCode(ExitFailure))
import System.IO ()
import Control.Monad.IO.Class (liftIO)
import System.Console.Haskeline
import AST (SExpr(..), Ast(..), Env,
            sexprToAST, evalAST)
import Parser (Dialect, parseSExprMultipleEither)
import UI (printError)

-- Interactive REPL runner
runConsole :: Dialect -> IO ()
runConsole dialect = runInputT defaultSettings (repl dialect [])

type ReplM = InputT IO

repl :: Dialect -> Env -> ReplM ()
repl dialect env = do
    minput <- getInputLine "> "
    case minput of
        Nothing -> outputStrLn ""  -- Ctrl-D exits
        Just line -> handleInput dialect env line

-- | Route input based on command or content
handleInput :: Dialect -> Env -> String -> ReplM ()
handleInput dialect env ":code" = captureBlock dialect env []
handleInput dialect env line
    | null (trim line) = repl dialect env
    | otherwise = handleLine dialect env line

-- | Handle a single-line entry: parse and evaluate immediately.
handleLine :: Dialect -> Env -> String -> ReplM ()
handleLine dialect env line =
    case parseSExprMultipleEither dialect line of
        Right sexprs -> evalReplSequence dialect env sexprs
        Left err -> liftIO (printError ("Parsing error: " ++ err)) >> repl dialect env

-- | Capture a multi-line block until ':end', then execute the whole block.
captureBlock :: Dialect -> Env -> [String] -> ReplM ()
captureBlock dialect env acc = do
    mline <- getInputLine "| "
    case mline of
        Nothing -> outputStrLn ""  -- EOF exits block
        Just ":end" -> execBlock dialect env acc
        Just line -> captureBlock dialect env (line : acc)

execBlock :: Dialect -> Env -> [String] -> ReplM ()
execBlock dialect env acc =
    let block = unlines (reverse acc)
    in if null (trim block)
       then repl dialect env
       else case parseSExprMultipleEither dialect block of
           Right sexprs -> evalReplSequence dialect env sexprs
           Left err -> liftIO (printError ("Parsing error: " ++ err)) >> repl dialect env

-- | Evaluate a list of s-expressions in the REPL context.
evalReplSequence :: Dialect -> Env -> [SExpr] -> ReplM ()
evalReplSequence dialect env [] = repl dialect env
evalReplSequence dialect env (s:ss) = do
    -- Debug: show the S-expression received before converting to AST
    outputStrLn ("[debug] SExpr -> " ++ show s)
    case sexprToAST s of
        Right ast -> evalReplAst dialect env ss ast
        Left err -> liftIO (printError err) >> repl dialect env

evalReplAst :: Dialect -> Env -> [SExpr] -> Ast -> ReplM ()
evalReplAst dialect env ss ast =
    case evalAST env ast of
        Right (result, env') -> printResult' result >> evalReplSequence dialect env' ss
        Left err -> liftIO (printError err) >> repl dialect env

trim :: String -> String
trim = dropWhile (== ' ') . reverse . dropWhile (== ' ') . reverse

-- Batch execution for stdin pipelines
runBatch :: Dialect -> String -> IO ()
runBatch dialect input =
    case parseSExprMultipleEither dialect input of
        Right sexprs -> evalSequence [] sexprs
        Left err -> printError ("Parsing error:\n" ++ err) >>
                    exitWith (ExitFailure 84)

evalSequence :: Env -> [SExpr] -> IO ()
evalSequence _ [] = return ()
evalSequence env (s:ss) = do
    -- Debug: print S-expression before converting to AST (batch mode)
    putStrLn ("[debug] SExpr -> " ++ show s)
    case sexprToAST s of
        Right ast ->
            case evalAST env ast of
                Right (result, env') -> printResultIO result >>
                                        evalSequence env' ss
                Left err -> printError err >> exitWith (ExitFailure 84)
        Left err -> printError err >> exitWith (ExitFailure 84)


printResult' :: Ast -> ReplM ()
printResult' (AstInt n) = outputStrLn (show n)
printResult' (AstFloat f) = outputStrLn (show f)
printResult' (AstBool True) = outputStrLn "#t"
printResult' (AstBool False) = outputStrLn "#f"
printResult' (AstString s) = outputStrLn s
printResult' (AstChar c) = outputStrLn [c]
printResult' AstVoid = return ()
printResult' (AstClosure _ _ _) = outputStrLn "#<procedure>"
printResult' (AstList _) = outputStrLn "#<list>"
printResult' (AstSymbol s) = outputStrLn s
printResult' other = outputStrLn (show other)

printResultIO :: Ast -> IO ()
printResultIO (AstInt n) = print n
printResultIO (AstFloat f) = print f
printResultIO (AstBool True) = putStrLn "#t"
printResultIO (AstBool False) = putStrLn "#f"
printResultIO (AstString s) = putStrLn s
printResultIO (AstChar c) = putStrLn [c]
printResultIO AstVoid = return ()
printResultIO (AstClosure _ _ _) = putStrLn "#<procedure>"
printResultIO (AstList _) = putStrLn "#<list>"
printResultIO (AstSymbol s) = putStrLn s
printResultIO other = putStrLn (show other)
