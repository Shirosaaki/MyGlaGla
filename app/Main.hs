{-
-- EPITECH PROJECT, 2025
-- Main module
-- File description:
-- main of the glory glados
-}
module Main (main) where

import System.IO (hIsTerminalDevice, stdin)
import System.Environment (getArgs)
import System.Exit (die, exitWith, ExitCode(ExitFailure, ExitSuccess))
import System.FilePath (takeExtension)
import Console (runConsole, runBatch)
import Parser (Dialect(..), dialectForFile, parseSExprMultipleEither)
import AST (sexprToAST, Ast(..), evalAST, SExpr)
import Compiler (compileToObject, compileToLL, compileToBytecodeFile, compileSourceFile, CompileMode(..))
import Loader (loadBytecodeFile, disassemble)
import ELFLoader (loadAndExecuteELF)
import VM (runVM)
import qualified VM
import Data.Maybe (fromMaybe)
import UI (printError)

main :: IO ()
main = getArgs >>= \rawArgs -> do
    -- Explicit flags override the extension-based detection.
    let flagDialect
          | "-l" `elem` rawArgs = Just Lisp
          | "-w" `elem` rawArgs = Just Waifu
          | "-t" `elem` rawArgs = Just TheShow
          | otherwise           = Nothing
        args = filter (`notElem` ["-l", "-w", "-t"]) rawArgs
    dispatch flagDialect args

-- | Dialect for a given source file: flag first, then file extension
-- (.waifu, .tslang, .scm, ...), then TheShow as default.
dialectFor :: Maybe Dialect -> FilePath -> Dialect
dialectFor flagDialect file =
    fromMaybe (fromMaybe TheShow (dialectForFile file)) flagDialect

dispatch :: Maybe Dialect -> [String] -> IO ()
-- Multi-file: glados -c out.o out2.o main.waifu lib.waifu
dispatch fd ("-c" : rest) | length rest >= 2 && even (length rest) =
    let n = length rest `div` 2
        (objOuts, srcFiles) = splitAt n rest
    in case (objOuts, srcFiles) of
         ([objOut], [srcFile]) ->
             compileSourceFile (dialectFor fd srcFile) objOut srcFile MainModule
             >> putStrLn "Compilation completed successfully."
         _ -> compileMultiple fd (zip objOuts srcFiles)
-- Cas avec fichier source : glados -c out.o source.waifu
dispatch fd ["-S", llOut, inFile] = compileFromFile (dialectFor fd inFile) inFile (compileToLL llOut)
dispatch fd ["-c", objOut, inFile] = compileSourceFile (dialectFor fd inFile) objOut inFile MainModule
                              >> putStrLn "Compilation completed successfully."
dispatch fd ["-B", byteOut, inFile] = compileFromFile (dialectFor fd inFile) inFile (compileToBytecodeFile byteOut)

-- Cas avec stdin : cat source.waifu | glados -c out.o
dispatch fd ["-S", llOut] = compileFromStdin (stdinDialect fd) (compileToLL llOut)
dispatch fd ["-c", objOut] = compileFromStdin (stdinDialect fd) (compileToObject objOut)
dispatch fd ["-B", byteOut] = compileFromStdin (stdinDialect fd) (compileToBytecodeFile byteOut)

dispatch _ ["-d", file] = runDisassembleMode file
dispatch fd [file]
    | takeExtension file == ".o" = runVMMode file
    | otherwise = runFileMode (dialectFor fd file) file
dispatch fd [] = runInteractive (stdinDialect fd)
dispatch _ _ = die "Usage: glados [-l] [-w] [-t] [-S out.ll [file] | -c out.o [out2.o ...] [file] [file2 ...] | -B out.byte [file] | -d file.o | file.o | file.scm]"

stdinDialect :: Maybe Dialect -> Dialect
stdinDialect = fromMaybe TheShow

compileMultiple :: Maybe Dialect -> [(FilePath, FilePath)] -> IO ()
compileMultiple _ [] = return ()
compileMultiple fd pairs = go pairs (0 :: Int) >> putStrLn "Compilation completed successfully."
  where
    go [] _ = return ()
    go ((objOut, srcFile) : rest) i = do
      let mode = if i == 0 then MainModule else LibraryModule
      compileSourceFile (dialectFor fd srcFile) objOut srcFile mode
      go rest (i + 1)

runInteractive :: Dialect -> IO ()
runInteractive dialect = do
    isTTY <- hIsTerminalDevice stdin
    if isTTY then runConsole dialect else getContents >>= runBatch dialect



runFileMode :: Dialect -> FilePath -> IO ()
runFileMode dialect path = do
    input <- readFile path
    case parseSExprMultipleEither dialect input of
        Right sexprs -> evalSequence [] sexprs
        Left err -> printError err >>
                    exitWith (ExitFailure 84)

runVMMode :: FilePath -> IO ()
runVMMode path = do
    result <- loadAndExecuteELF path
    case result of
        Right exitCode -> do
            exitWith (if exitCode == 0 then ExitSuccess else ExitFailure exitCode)
        Left elfErr -> do
            result' <- loadBytecodeFile path
            case result' of
                Left byteErr -> do
                    if "ELF" `elem` words elfErr || "magic" `elem` words byteErr
                        then printError elfErr >> exitWith (ExitFailure 84)
                        else printError byteErr >> exitWith (ExitFailure 84)
                Right instrs -> do
                    let (res, outs) = runVM instrs
                    mapM_ putStrLn outs
                    case res of
                        Left err -> printError ("RUNTIME ERROR: " ++ err) >>
                                    exitWith (ExitFailure 84)
                        Right val -> printVMResult val

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
printResult' (AstBool True) = putStrLn "1"
printResult' (AstBool False) = putStrLn "0"
printResult' AstVoid = return ()
printResult' (AstClosure _ _ _) = putStrLn "#<procedure>"
printResult' result = print result

printVMResult :: VM.VMValue -> IO ()
printVMResult (VM.VMInt n) = print n
printVMResult (VM.VMBool True) = putStrLn "1"
printVMResult (VM.VMBool False) = putStrLn "0"
printVMResult (VM.VMString s) = putStrLn s
printVMResult (VM.VMClosure {}) = putStrLn "#<closure>"
printVMResult VM.VMVoid = return ()

-- Nouvelle fonction pour compiler depuis un fichier
compileFromFile :: Dialect -> FilePath -> (Ast -> IO ()) -> IO ()
compileFromFile dialect path compile = do
    input <- readFile path
    processAndCompile dialect input compile

-- On factorise la logique de compilation pour qu'elle soit utilisée par stdin ET file
compileFromStdin :: Dialect -> (Ast -> IO ()) -> IO ()
compileFromStdin dialect compile = do
    input <- getContents
    processAndCompile dialect input compile

-- Logique commune de transformation SExpr -> AST -> Compilation
processAndCompile :: Dialect -> String -> (Ast -> IO ()) -> IO ()
processAndCompile dialect input compile = 
    case parseSExprMultipleEither dialect input of
        Left err -> printError ("Parsing error:\n" ++ err) >> exitWith (ExitFailure 84)
        Right sexprs -> do
            case mapM sexprToAST sexprs of
                Left perr -> printError perr >> exitWith (ExitFailure 84)
                Right asts -> do
                    let asts' = case asts of
                                    [def@(Define name _ (AstLambda params _))] | null params ->
                                        [def, Call (AstSymbol name) []]
                                    _ -> asts
                    compile (Block asts')
                    putStrLn "Compilation completed successfully."

type Env = [(String, Ast)]