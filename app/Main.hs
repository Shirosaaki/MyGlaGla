{-
-- EPITECH PROJECT, 2025
-- Main module
-- File description:
-- main of the glory glados
-}
module Main (main) where

import System.IO (hIsTerminalDevice, stdin, hPutStrLn, stderr)
import System.Environment (getArgs)
import System.Exit (die, exitWith, ExitCode(ExitFailure))
import System.FilePath (takeExtension)
import Console (runConsole, runBatch)
import Parser (parseSExprMultipleEither, setUseLisp)
import AST (sexprToAST, Ast(..), evalAST, SExpr)
import Compiler (compileToObject, compileToLL)
import Loader (loadBytecodeFile, disassemble)
import VM (runVM)
import qualified VM
import Control.Monad (when)
import UI (printError)

main :: IO ()
main = getArgs >>= \rawArgs -> do
    let useLisp = "-l" `elem` rawArgs
        args = filter (/= "-l") rawArgs
    when useLisp (setUseLisp True)
    dispatch args

dispatch :: [String] -> IO ()
dispatch ["-S", llOut] = compileFromStdin (compileToLL llOut)
dispatch ["-c", objOut] = compileFromStdin (compileToObject objOut)
dispatch ["-d", file] = runDisassembleMode file  -- Disassemble VM bytecode
dispatch [file] 
    | takeExtension file == ".o" = runVMMode file  -- Execute VM bytecode
    | otherwise = runFileMode file  -- Execute source file
dispatch [] = runInteractive
dispatch _ = die "Usage: glados [-l] [-S out.ll | -c out.o | -d file.o | file.o | file.scm]"

runInteractive :: IO ()
runInteractive = do
    isTTY <- hIsTerminalDevice stdin
    if isTTY then runConsole else getContents >>= runBatch

compileFromStdin :: (Ast -> IO ()) -> IO ()
compileFromStdin compile = do
    input <- getContents
    case parseSExprMultipleEither input of
        Left err -> printError ("Parsing error:\n" ++ err) >> exitWith (ExitFailure 84)
        Right sexprs -> do
            -- Debug: print the parsed S-expressions before converting to AST
            putStrLn "--- SExpr (parsed) ---"
            print sexprs
            putStrLn "----------------------"
            case mapM sexprToAST sexprs of
                Left perr -> printError perr >> exitWith (ExitFailure 84)
                Right asts -> do
                    -- If program is a single top-level zero-arg function, auto-invoke it.
                    let asts' = case asts of
                                    [def@(Define name _ (AstLambda params _))] | null params ->
                                        [def, Call (AstSymbol name) []]
                                    _ -> asts
                    -- Print ASTs being sent to the compiler for inspection
                    putStrLn "--- AST (parsed) ---"
                    print asts'
                    putStrLn "--------------------"
                    compile (Block asts')

-- Execute a source file
runFileMode :: FilePath -> IO ()
runFileMode path = do
    input <- readFile path
    case parseSExprMultipleEither input of
        Right sexprs -> evalSequence [] sexprs
        Left err -> printError err >>
                    exitWith (ExitFailure 84)

-- Execute bytecode from .o file
runVMMode :: FilePath -> IO ()
runVMMode path = do
    result <- loadBytecodeFile path
    case result of
        Left err -> printError err >>
                    exitWith (ExitFailure 84)
        Right instrs -> do
            let (res, outs) = runVM instrs
            mapM_ putStrLn outs
            case res of
                Left err -> printError ("RUNTIME ERROR: " ++ err) >>
                            exitWith (ExitFailure 84)
                Right val -> printVMResult val

-- Disassemble .o file
runDisassembleMode :: FilePath -> IO ()
runDisassembleMode path = do
    result <- loadBytecodeFile path
    case result of
        Left err -> printError err >>
                    exitWith (ExitFailure 84)
        Right instrs -> putStrLn (disassemble instrs)

evalSequence :: Env -> [SExpr] -> IO ()
evalSequence _ [] = return ()
evalSequence env (s:ss) =
    case sexprToAST s of
        Right ast ->
            case evalAST env ast of
                Right (result, env') ->
                    printResult' result >> evalSequence env' ss
                Left err ->
                    printError err >> exitWith (ExitFailure 84)
        Left err ->
            printError err >> exitWith (ExitFailure 84)

printResult' :: Ast -> IO ()
printResult' (AstInt n) = print n
printResult' (AstBool True) = print 1
printResult' (AstBool False) = print 0
printResult' AstVoid = return ()
printResult' (AstClosure _ _ _) = putStrLn "#<procedure>"
printResult' result = print result

printVMResult :: VM.VMValue -> IO ()
printVMResult (VM.VMInt n) = print n
printVMResult (VM.VMBool True) = print 1
printVMResult (VM.VMBool False) = print 0
printVMResult VM.VMVoid = return ()
printVMResult (VM.VMClosure _ _ _) = putStrLn "#<procedure>"

type Env = [(String, Ast)]
