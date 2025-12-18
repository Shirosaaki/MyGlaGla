{-
-- ==============================================
--                 Compiler.hs
--  main
--  Author: shirosaaki
--  Date: 2025-12-18
-- =============================================
-}
module Compiler (compileModuleLLVM, compileToLL, compileToObject) where

import AST (SExpr(..), Ast(..))
import Bytecode (Instruction(..))
import qualified Bytecode as BC
import Loader (saveBytecodeFile)
import Data.Int (Int32)
import qualified Data.Map.Strict as Map
import Data.Maybe (fromMaybe)
import Data.List (partition)
import System.Process (createProcess, proc, std_in, waitForProcess, callCommand, StdStream(CreatePipe))
import System.IO (hPutStr, hClose, stderr)
-- avoid System.Directory dependency; use shell rm via callCommand instead
import Data.Char (toLower, toUpper)

-- Entry point: compile a TheShowLang AST (as SExpr) to LLVM IR
compileModuleLLVM :: SExpr -> String
compileModuleLLVM ast = unlines $ [llvmHeader] ++ genFuncs ast ++ [genMain ast] ++ [llvmFooter]

-- Generate LLVM for all top-level functions and global strings
genFuncs :: SExpr -> [String]
genFuncs ast = genStrGlobals ast ++ genFuncs' ast

genFuncs' :: SExpr -> [String]
genFuncs' (SList xs) = concatMap genFunc xs
genFuncs' _ = []

-- Collect string constants used by `peric` calls
genStrGlobals :: SExpr -> [String]
genStrGlobals (SList xs) = concatMap genStrGlobals xs ++ concatMap extractStr xs
genStrGlobals _ = []

extractStr :: SExpr -> [String]
extractStr (SList [SSymbol "call", SSymbol "peric", SList [SString s]]) =
        ["@.str_" ++ show (abs (hash s)) ++ " = private constant [" ++ show (length s + 1) ++ " x i8] c\"" ++ escapeString s ++ "\\00\""]
extractStr _ = []

escapeString :: String -> String
escapeString = concatMap escapeChar
    where
        escapeChar '\\' = "\\5C"
        escapeChar '"'  = "\\22"
        escapeChar '\n' = "\\0A"
        escapeChar c    = [c]

llvmHeader :: String
llvmHeader = unlines
    [ "; ModuleID = 'theshowlang'"
    , "source_filename = \"theshowlang\""
    , "target triple = \"x86_64-pc-linux-gnu\""
    , "declare i32 @printf(i8*, ...)"
    , "declare i32 @puts(i8*)"
    , "@.fmt_int = private constant [4 x i8] c\"%d\\0A\\00\""
    ]

-- Helper: hash a string for unique global name
hash :: String -> Int
hash = foldr ((+) . fromEnum) 0

-- Simple function stub generator (placeholder)
genFunc :: SExpr -> [String]
genFunc (SList (SSymbol "define" : _)) = ["; function stub (not yet implemented)"]
genFunc _ = []

-- Minimal main implementation so the LLVM module is valid
genMain :: SExpr -> String
genMain _ = unlines
    [ "define i32 @main() {"
    , "  ret i32 0"
    , "}"
    ]

llvmFooter :: String
llvmFooter = ""

-- Write LLVM IR to a file (minimal implementation)
compileToLL :: FilePath -> Ast -> IO ()
compileToLL out _ = writeFile out (compileModuleLLVM (SList []))

-- Produce a .o by compiling AST to VM bytecode and writing the file
compileToObject :: FilePath -> Ast -> IO ()
compileToObject out ast = do
    let asm = emitASM ast
        asmFile = "/tmp/glados_emit.s"
        locals = buildLocalMap ast
    -- Debug: print local map to stderr so we can confirm offsets
    hPutStr stderr ("[debug] locals: " ++ show (Map.toList locals) ++ "\n")
    -- Write assembly to a temp file (debug-friendly), assemble, then remove it
    writeFile asmFile asm
    _ <- callCommand ("as -o " ++ out ++ " " ++ asmFile)
    -- keep asm file for inspection (debugging)
    -- _ <- callCommand ("rm -f " ++ asmFile)
    return ()



-- Two-pass compilation: collect top-level defines, compile functions, then compile main
compileProgram :: Ast -> [Instruction]
compileProgram (Block xs) =
    let (defAsts, others) = partition isDefine xs
        isDefine (Define _ _ _) = True
        isDefine _ = False
        defs = map (\f -> case f of Define name _ val -> (name, val); _ -> error "impossible") defAsts

        -- Build function address map and concatenated function instruction list
        (addrMap', funcInstrs) = buildFuncMap defs

        mainInstrs = concatMap (compileAstToBytecodeWith addrMap') others
    in funcInstrs ++ mainInstrs ++ [HALT]
compileProgram a = compileAstToBytecode a ++ [HALT]

buildFuncMap :: [(String, Ast)] -> (Map.Map String Int32, [Instruction])
buildFuncMap defs = go defs Map.empty [] 0
  where
    go [] m acc _ = (m, acc)
    go ((name, val):rest) m acc offset =
        let instrs = compileFuncBody val
            m' = Map.insert name (fromIntegral offset :: Int32) m
            offset' = offset + length instrs
            acc' = acc ++ instrs
        in go rest m' acc' offset'

compileFuncBody :: Ast -> [Instruction]
compileFuncBody (AstLambda params body) = compileAstToBytecode body ++ [RET]
compileFuncBody body = compileAstToBytecode body ++ [RET]


-- Compile AST to bytecode instructions (simple, incremental)
compileAstToBytecode :: Ast -> [Instruction]
compileAstToBytecode (AstInt n) = [PUSH (fromIntegral n :: Int32)]
compileAstToBytecode (AstBool True) = [PUSH_TRUE]
compileAstToBytecode (AstBool False) = [PUSH_FALSE]
compileAstToBytecode (AstSymbol name) = [LOAD_GLOBAL name]
compileAstToBytecode (AstString s) = [LOAD_CONST s]
compileAstToBytecode (Block xs) = compileBlock xs
compileAstToBytecode (Define name _ maybeBody) =
    case maybeBody of
        body -> compileAstToBytecode body ++ [STORE_GLOBAL name]
compileAstToBytecode (Assign name val) = compileAstToBytecode val ++ [STORE_GLOBAL name]
compileAstToBytecode (Call fn args) = compileCallBytecode Map.empty fn args
compileAstToBytecode _ = [PUSH 0]

compileBlock :: [Ast] -> [Instruction]
compileBlock [] = []
compileBlock [x] = compileAstToBytecode x
compileBlock (x:xs) = compileAstToBytecode x ++ [POP] ++ compileBlock xs

compileCallBytecode :: Map.Map String Int32 -> Ast -> [Ast] -> [Instruction]
compileCallBytecode _ (AstSymbol "peric") (arg:_) = compileAstToBytecode arg ++ [PRINT]
compileCallBytecode addrMap (AstSymbol name) args
    | name `elem` ["+", "add"] = compileFold args ADD
    | name `elem` ["-","sub"] = compileFold args SUB
    | name `elem` ["*","mul"] = compileFold args MUL
    | name `elem` ["/"] = compileFold args DIV
    | name `elem` ["%"] = compileFold args BC.MOD
    | name `elem` ["<"] = compileFold args BC.LT
    | name `elem` ["=="] = compileFold args BC.EQ
    | otherwise =
                    let compiledArgs = concatMap (compileAstToBytecodeWith addrMap) args
                        lowerMap = Map.fromList [ (map toLower k, v) | (k,v) <- Map.toList addrMap ]
                    in case Map.lookup name addrMap of
                        Just addr -> compiledArgs ++ [CALL addr]
                        Nothing -> case Map.lookup (map toLower name) lowerMap of
                            Just a -> compiledArgs ++ [CALL a]
                            Nothing -> compiledArgs ++ [PUSH 0]
compileCallBytecode addrMap fn args = concatMap (compileAstToBytecodeWith addrMap) args ++ [PUSH 0]

compileAstToBytecodeWith :: Map.Map String Int32 -> Ast -> [Instruction]
compileAstToBytecodeWith addrMap a =
    case a of
        AstInt n -> [PUSH (fromIntegral n :: Int32)]
        AstBool True -> [PUSH_TRUE]
        AstBool False -> [PUSH_FALSE]
        AstSymbol name -> [LOAD_GLOBAL name]
        AstString s -> [LOAD_CONST s]
        Block xs -> concatMap (compileAstToBytecodeWith addrMap) xs
        Define name _ val -> [] -- top-level handled separately
        Assign name val -> compileAstToBytecodeWith addrMap val ++ [STORE_GLOBAL name]
        Call fn args -> compileCallBytecode addrMap fn args
        _ -> [PUSH 0]

compileFold :: [Ast] -> Instruction -> [Instruction]
compileFold [] _ = [PUSH 0]
compileFold [x] op = compileAstToBytecode x
compileFold (x:xs) op = concatMap compileAstToBytecode (x:xs) ++ replicate (length xs) op


-- Emit x86_64 assembly (AT&T syntax) for simple TheShow programs.
emitASM :: Ast -> String
emitASM ast =
    let -- include printf format strings so we can call printf for parts
        strs = collectStrings ast ++ ["%s", "%d"]
        labels = zip strs [0..]
        rodata = concatMap emitData labels
        funcs = collectFuncs ast
        consts = collectConsts ast
        text = emitText ast labels funcs consts
    in rodata ++ "\n" ++ text

emitData :: (String, Int) -> String
emitData (s, i) = ".section .rodata\n.globl LC" ++ show i ++ "\nLC" ++ show i ++ ":\n\t.string \"" ++ escapeASM s ++ "\"\n"

emitText :: Ast -> [(String, Int)] -> Map.Map String Ast -> Map.Map String String -> String
emitText ast labels funcs consts =
    let locals = buildLocalMap ast
        totalBytes = (Map.size locals) * 8
        -- align stack allocation to 16 bytes for call ABI
        totalBytesAligned = if totalBytes == 0 then 0 else ((totalBytes + 15) `div` 16) * 16
        prologue = [".text", ".globl main", ".type main,@function", "main:", "\tpushq %rbp", "\tmovq %rsp, %rbp"]
        stackAlloc = if totalBytesAligned > 0 then ["\tsubq $" ++ show totalBytesAligned ++ ", %rsp"] else []
        stackDealloc = if totalBytesAligned > 0 then ["\taddq $" ++ show totalBytesAligned ++ ", %rsp"] else []
    in unlines $ prologue ++ stackAlloc ++ map ("\t" ++) (emitStmts ast labels funcs consts locals) ++ ["\t.Lreturn:"] ++ stackDealloc ++ ["\tpopq %rbp", "\tret"]

emitStmts :: Ast -> [(String, Int)] -> Map.Map String Ast -> Map.Map String String -> Map.Map String Int -> [String]
emitStmts (Block xs) labels funcs consts locals = concatMap (\x -> stmtToASM x labels funcs consts locals) xs
emitStmts a labels funcs consts locals = stmtToASM a labels funcs consts locals

stmtToASM :: Ast -> [(String, Int)] -> Map.Map String Ast -> Map.Map String String -> Map.Map String Int -> [String]
stmtToASM (Call (AstSymbol "peric") (AstString s : _)) labels _ _ _ =
    let idx = lookupLabel s labels
    in ["leaq LC" ++ show idx ++ "(%rip), %rdi", "call puts"]
stmtToASM (Call (AstSymbol "peric") (Call (AstSymbol "string-interp") parts : _)) labels _ consts locals =
    let -- try to convert every part to a compile-time string using consts
        tryConv (AstString s) = Just s
        tryConv (AstInt n) = Just (show n)
        tryConv (AstFloat f) = Just (show f)
        tryConv (AstBool True) = Just "#t"
        tryConv (AstBool False) = Just "#f"
        tryConv (AstSymbol name) = Map.lookup name consts
        tryConv _ = Nothing
        mStrings = sequence (map tryConv parts)
    in case mStrings of
        Just ss -> let s = concat ss
                       idx = lookupLabel s labels
                   in ["leaq LC" ++ show idx ++ "(%rip), %rdi", "call puts"]
        Nothing ->
            -- build a single printf with format and arguments
            let fmtPart p = case p of
                    AstString s -> s
                    AstInt _ -> "%d"
                    AstFloat _ -> "%d"
                    AstBool _ -> "%s"
                    AstSymbol _ -> "%d"
                    _ -> ""
                fmt = concatMap fmtPart parts ++ "\n"
                fmtIdx = lookupLabel fmt labels
                -- collect arguments registers: rsi, rdx, rcx, r8, r9
                regs = ["%rsi","%rdx","%rcx","%r8","%r9"]
                isArg p = case p of {AstInt _ -> True; AstFloat _ -> True; AstSymbol _ -> True; _ -> False}
                argParts = filter isArg parts
                buildArg p reg = case p of
                    AstInt n -> ["movq $" ++ show n ++ ", " ++ reg]
                    AstFloat f -> ["movq $" ++ show (floor f) ++ ", " ++ reg]
                    AstSymbol name -> case Map.lookup name locals of
                        Just off -> ["movq -" ++ show off ++ "(%rbp), " ++ reg]
                        Nothing -> ["movq $0, " ++ reg]
                    _ -> []
                argInstrs = concat (zipWith buildArg argParts regs)
            in ["leaq LC" ++ show fmtIdx ++ "(%rip), %rdi"] ++ argInstrs ++ ["call printf"]
stmtToASM (Call (AstSymbol "assign") [AstSymbol name, expr]) labels funcs consts locals =
    stmtToASM (Assign name expr) labels funcs consts locals
stmtToASM (Call (AstSymbol "define") [AstSymbol name, val, _]) labels funcs consts locals = stmtToASM (Assign name val) labels funcs consts locals
stmtToASM (Call (AstSymbol "define") [AstSymbol name, _]) labels funcs consts locals =
    let off = Map.findWithDefault 8 name locals
    in ["movq $0, -" ++ show off ++ "(%rbp)"]
stmtToASM (Call (AstSymbol name) args) labels funcs consts locals =
    case Map.lookup name funcs of
        Just (AstLambda _ body) -> emitStmts body labels funcs consts locals
        _ -> []  -- unknown runtime call -> emit no-op (avoid external undefined refs)
stmtToASM (Return a) labels funcs consts locals = compileExpr a ++ ["jmp .Lreturn"]
  where
    compileExpr e = case e of
            AstInt n -> ["movq $" ++ show n ++ ", %rax"]
            AstString s -> let si = lookupLabel s labels in ["leaq LC" ++ show si ++ "(%rip), %rax"]
            AstSymbol v -> case Map.lookup v locals of
                Just off -> ["movq -" ++ show off ++ "(%rbp), %rax"]
                Nothing -> ["movq $0, %rax"]
            Call (AstSymbol "+") [a',b'] -> compileExpr a' ++ ["pushq %rax"] ++ compileExpr b' ++ ["popq %rcx", "addq %rcx, %rax"]
            Call (AstSymbol "-") [a',b'] -> compileExpr a' ++ ["pushq %rax"] ++ compileExpr b' ++ ["popq %rcx", "subq %rax, %rcx", "movq %rcx, %rax"]
            _ -> ["movq $0, %rax"]
stmtToASM (Assign name val) labels funcs consts locals =
    let compileExpr e = case e of
                AstInt n -> ["movq $" ++ show n ++ ", %rax"]
                AstString s -> let si = lookupLabel s labels in ["leaq LC" ++ show si ++ "(%rip), %rax"]
                AstSymbol v -> case Map.lookup v locals of
                    Just off -> ["movq -" ++ show off ++ "(%rbp), %rax"]
                    Nothing -> ["movq $0, %rax"]
                Call (AstSymbol "+") [a,b] -> compileExpr a ++ ["pushq %rax"] ++ compileExpr b ++ ["popq %rcx", "addq %rcx, %rax"]
                Call (AstSymbol "-") [a,b] -> compileExpr a ++ ["pushq %rax"] ++ compileExpr b ++ ["popq %rcx", "subq %rax, %rcx", "movq %rcx, %rax"]
                _ -> ["movq $0, %rax"]
        asm = compileExpr val
        off = Map.findWithDefault 8 name locals
    in asm ++ ["movq %rax, -" ++ show off ++ "(%rbp)"]
stmtToASM _ _ _ _ _ = []

lookupLabel :: String -> [(String, Int)] -> Int
lookupLabel s labels = case lookup s labels of
    Just i -> i
    Nothing -> 0

collectStrings :: Ast -> [String]
collectStrings (Block xs) = concatMap collectStrings xs
collectStrings (Call (AstSymbol "peric") (AstString s : _)) = [s]
collectStrings (Call (AstSymbol "peric") (Call (AstSymbol "string-interp") parts : _)) =
    let fmtPart p = case p of
            AstString s -> s
            AstInt _ -> "%d"
            AstFloat _ -> "%d"
            AstBool _ -> "%s"
            AstSymbol _ -> "%d"
            _ -> ""
        fmt = concatMap fmtPart parts ++ "\n"
        partsStrs = concatMap collectStrings parts
    in fmt : partsStrs
collectStrings (Call _ args) = concatMap collectStrings args
collectStrings (AstString s) = [s]
collectStrings (Define _ _ v) = collectStrings v
collectStrings (AstLambda _ body) = collectStrings body
collectStrings (Return a) = collectStrings a
collectStrings (Assign _ a) = collectStrings a
collectStrings (ArrayAssign _ _ a) = collectStrings a
collectStrings _ = []

collectFuncs :: Ast -> Map.Map String Ast
collectFuncs (Block xs) = foldl collect Map.empty xs
  where
    collect m (Define name _ (AstLambda params body)) = Map.insert name (AstLambda params body) m
    collect m _ = m
collectFuncs _ = Map.empty

-- Collect compile-time constant definitions (simple ints/strings/bools/floats)
collectConsts :: Ast -> Map.Map String String
collectConsts (Block xs) = foldl (\r a -> Map.union r (collectConsts a)) Map.empty xs
collectConsts (Define name _ val) =
        case val of
                AstInt n -> Map.singleton name (show n)
                AstString s -> Map.singleton name s
                AstFloat f -> Map.singleton name (show f)
                AstBool True -> Map.singleton name "#t"
                AstBool False -> Map.singleton name "#f"
                _ -> collectConsts val
collectConsts (Call _ args) = foldl (\r a -> Map.union r (collectConsts a)) Map.empty args
collectConsts (AstLambda _ body) = collectConsts body
collectConsts (Return a) = collectConsts a
collectConsts (Assign _ a) = collectConsts a
collectConsts (ArrayAssign _ _ a) = collectConsts a
collectConsts _ = Map.empty

-- Build a simple map of local variable names to stack offsets (8,16,...)
buildLocalMap :: Ast -> Map.Map String Int
buildLocalMap ast = let names = collectNamesForLocals ast []
                        uniq = uniqueList names
                        offsets = map (*8) [1..]
                    in Map.fromList (zip uniq offsets)

collectNamesForLocals :: Ast -> [String] -> [String]
collectNamesForLocals (Block xs) acc = foldl (\a x -> collectNamesForLocals x a) acc xs
collectNamesForLocals (Define _ _ val) acc = collectNamesForLocals val acc
collectNamesForLocals (Assign name _) acc = acc ++ [name]
collectNamesForLocals (AstLambda _ body) acc = collectNamesForLocals body acc
collectNamesForLocals (Call (AstSymbol "define") (AstSymbol name : _)) acc = acc ++ [name]
collectNamesForLocals (Call (AstSymbol "assign") (AstSymbol name : _)) acc = acc ++ [name]
collectNamesForLocals (Call _ args) acc = foldl (\a x -> collectNamesForLocals x a) acc args
collectNamesForLocals (Return a) acc = collectNamesForLocals a acc
collectNamesForLocals _ acc = acc

uniqueList :: [String] -> [String]
uniqueList = foldl (\seen x -> if x `elem` seen then seen else seen ++ [x]) []

escapeASM :: String -> String
escapeASM = concatMap esc
  where
    esc '\\' = "\\\\"
    esc '"' = "\\\""
    esc '\n' = "\\n"
    esc c = [c]
 
