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
import Parser (parseSExprMultipleEither, setUseLisp, setUseWaifu) -- Ajout de setUseWaifu
import AST (sexprToAST, Ast(..), evalAST, SExpr)
import Compiler (compileToObject, compileToLL, compileToBytecodeFile)
import Loader (loadBytecodeFile, disassemble)
import ELFLoader (loadAndExecuteELF)
import VM (runVM)
import qualified VM
import Control.Monad (when)
import UI (printError)

main :: IO ()
main = getArgs >>= \rawArgs -> do
    -- Détection des drapeaux (flags)
    let useLisp = "-l" `elem` rawArgs
        useWaifu = "-w" `elem` rawArgs
        -- On nettoie les arguments pour ne garder que les commandes/fichiers
        args = filter (\a -> a /= "-l" && a /= "-w") rawArgs
    
    -- Activation des modes dans le module Parser
    when useLisp (setUseLisp True)
    when useWaifu (setUseWaifu True)
    
    dispatch args

dispatch :: [String] -> IO ()
-- Cas avec fichier source : glados -c out.o source.waifu
dispatch ["-S", llOut, inFile] = compileFromFile inFile (compileToLL llOut)
dispatch ["-c", objOut, inFile] = compileFromFile inFile (compileToObject objOut)
dispatch ["-B", byteOut, inFile] = compileFromFile inFile (compileToBytecodeFile byteOut)

-- Cas avec stdin (existant) : cat source.waifu | glados -c out.o
dispatch ["-S", llOut] = compileFromStdin (compileToLL llOut)
dispatch ["-c", objOut] = compileFromStdin (compileToObject objOut)
dispatch ["-B", byteOut] = compileFromStdin (compileToBytecodeFile byteOut)

dispatch ["-d", file] = runDisassembleMode file
dispatch [file] 
    | takeExtension file == ".o" = runVMMode file
    | otherwise = runFileMode file
dispatch [] = runInteractive
dispatch _ = die "Usage: glados [-l] [-w] [-S out.ll [file] | -c out.o [file] | -B out.byte [file] | -d file.o | file.o | file.scm]"

runInteractive :: IO ()
runInteractive = do
    isTTY <- hIsTerminalDevice stdin
    if isTTY then runConsole else getContents >>= runBatch



runFileMode :: FilePath -> IO ()
runFileMode path = do
    input <- readFile path
    case parseSExprMultipleEither input of
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
compileFromFile :: FilePath -> (Ast -> IO ()) -> IO ()
compileFromFile path compile = do
    input <- readFile path
    processAndCompile input compile

-- On factorise la logique de compilation pour qu'elle soit utilisée par stdin ET file
compileFromStdin :: (Ast -> IO ()) -> IO ()
compileFromStdin compile = do
    input <- getContents
    processAndCompile input compile

-- Logique commune de transformation SExpr -> AST -> Compilation
processAndCompile :: String -> (Ast -> IO ()) -> IO ()
processAndCompile input compile = 
    case parseSExprMultipleEither input of
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