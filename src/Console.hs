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
import AST (SExpr(..), Ast(..), Env,
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
evalReplSequence env (s:ss) = do
    -- Debug: show the S-expression received before converting to AST
    outputStrLn ("[debug] SExpr -> " ++ show s)
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

printError :: String -> IO ()
printError msg = hPutStrLn stderr ("*** ERROR : " ++ msg)

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
