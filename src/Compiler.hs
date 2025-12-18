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
import System.IO.Unsafe (unsafePerformIO)
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
    hPutStr stderr ("---ASM START---\n" ++ asm ++ "\n---ASM END---\n")
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



-- small helper used by for/while/return etc.
compileExprFor :: Map.Map String Int -> Ast -> [String]
compileExprFor locs e = case e of
    AstInt n    -> ["movq $" ++ show n ++ ", %rax"]
    AstSymbol v -> case Map.lookup v locs of
                      Just off -> ["movq -" ++ show off ++ "(%rbp), %rax"]
                      Nothing  -> ["movq $0, %rax"]
    _           -> ["movq $0, %rax"]


-- Emit x86_64 assembly (AT&T syntax) for simple TheShow programs.
emitASM :: Ast -> String
emitASM ast =
    let -- compute names that are assigned to (mutables) and avoid treating
        -- them as compile-time constants
        mutables = uniqueList (collectNamesForLocals ast [])
        consts = collectConsts ast mutables
        strs = collectStrings consts ast ++ ["%s", "%d"]
        labels = zip strs [0..]
        rodata = concatMap emitData labels
        funcs = collectFuncs ast
        text = emitText ast labels funcs consts
    in rodata ++ "\n" ++ text


emitData :: (String, Int) -> String
emitData (s, i) = ".section .rodata\n.globl LC" ++ show i ++ "\nLC" ++ show i ++ ":\n\t.string \"" ++ escapeASM s ++ "\"\n"


emitText :: Ast -> [(String, Int)] -> Map.Map String Ast -> Map.Map String String -> String
emitText ast labels funcs consts =
    let prologue = [".text", ".globl main", ".type main,@function", "main:", "\tpushq %rbp", "\tmovq %rsp, %rbp"]
        -- build function-level locals and allocate stack space up front
        localMap = buildLocalMap ast
        totalBytes = (Map.size localMap) * 8
        totalBytesAligned = if totalBytes == 0 then 0 else ((totalBytes + 15) `div` 16) * 16
        stackAlloc = if totalBytesAligned > 0 then ["\tsubq $" ++ show totalBytesAligned ++ ", %rsp"] else []
        stackDealloc = if totalBytesAligned > 0 then ["\taddq $" ++ show totalBytesAligned ++ ", %rsp"] else []
        retLabel = ".Lreturn"
    in unlines $ prologue ++ stackAlloc ++ map ("\t" ++) (emitStmts ast labels funcs consts localMap retLabel) ++ ["\t" ++ retLabel ++ ":"] ++ stackDealloc ++ ["\tpopq %rbp", "\tret"]


emitStmts :: Ast -> [(String, Int)] -> Map.Map String Ast -> Map.Map String String -> Map.Map String Int -> String -> [String]
emitStmts (Block xs) labels funcs consts locals retLabel = concatMap (\x -> stmtToASM x labels funcs consts locals retLabel) xs
emitStmts a labels funcs consts locals retLabel = stmtToASM a labels funcs consts locals retLabel


stmtToASM :: Ast -> [(String, Int)] -> Map.Map String Ast -> Map.Map String String -> Map.Map String Int -> String -> [String]
stmtToASM (IfElse cond thenBlock elseBlock) labels funcs consts locals retLabel =
    let lbl = abs (hash (show cond ++ show thenBlock ++ show elseBlock)) `mod` 100000
        lElse = ".Lelse_" ++ show lbl
        lEnd = ".Lendif_" ++ show lbl
        condAsm = case cond of
            Call (AstSymbol op) [AstSymbol v, AstInt n] ->
                case Map.lookup v locals of
                    Just off -> let load = ["movq -" ++ show off ++ "(%rbp), %rax"]
                                    cmp = ["cmpq $" ++ show n ++ ", %rax"]
                                    jfalse = case op of
                                                "==" -> "jne " ++ lElse
                                                "<"  -> "jge " ++ lElse
                                                ">"  -> "jle " ++ lElse
                                                "<=" -> "jg " ++ lElse
                                                ">=" -> "jl " ++ lElse
                                                _     -> "je " ++ lElse
                                in load ++ cmp ++ [jfalse]
                    Nothing -> ["movq $0, %rax", "cmpq $" ++ show n ++ ", %rax", "je " ++ lElse]
            _ -> compileExprFor locals cond ++ ["cmpq $0, %rax", "je " ++ lElse]
        thenAsm = concatMap (\s -> stmtToASM s labels funcs consts locals retLabel) (case thenBlock of Block xs -> xs; _ -> [thenBlock])
        elseAsm = concatMap (\s -> stmtToASM s labels funcs consts locals retLabel) (case elseBlock of Block xs -> xs; _ -> [elseBlock])
    in condAsm ++ thenAsm ++ ["jmp " ++ lEnd] ++ [lElse ++ ":"] ++ elseAsm ++ [lEnd ++ ":"]

stmtToASM (Call (AstSymbol "peric") (AstString s : _)) labels _ _ _ _ =
    let idx = lookupLabel s labels
    in ["leaq LC" ++ show idx ++ "(%rip), %rdi", "call puts"]
stmtToASM (Call (AstSymbol "peric") (Call (AstSymbol "string-interp") parts : _)) labels _ consts locals _ =
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
stmtToASM (Call (AstSymbol "assign") [AstSymbol name, expr]) labels funcs consts locals retLabel =
    stmtToASM (Assign name expr) labels funcs consts locals retLabel
stmtToASM (Call (AstSymbol "define") [AstSymbol name, val, _]) labels funcs consts locals retLabel = stmtToASM (Assign name val) labels funcs consts locals retLabel
stmtToASM (Call (AstSymbol "define") [AstSymbol name, _]) labels funcs consts locals retLabel =
    let off = Map.findWithDefault 8 name locals
    in ["movq $0, -" ++ show off ++ "(%rbp)"]
stmtToASM (Call (AstSymbol name) args) labels funcs consts locals retLabel =
    case (name, args) of
        ("for", [AstSymbol var, start, end, Block body]) ->
            let lbl = abs (hash (var ++ show start ++ show end)) `mod` 100000
                lStart = ".Lfor_start_" ++ show lbl
                lEnd = ".Lfor_end_" ++ show lbl
                -- compute locals for loop body merging with parent locals and allocate stack
                baseLocalMap = Map.union locals (buildLocalMap (Block body))
                -- reserve a slot for the loop variable (after other locals)
                loopSlot = (Map.size baseLocalMap + 1) * 8
                localMap = Map.insert var loopSlot baseLocalMap
                totalBytes = (Map.size localMap) * 8
                totalBytesAligned = if totalBytes == 0 then 0 else ((totalBytes + 15) `div` 16) * 16
                alloc = if totalBytesAligned > 0 then ["subq $" ++ show totalBytesAligned ++ ", %rsp"] else []
                dealloc = if totalBytesAligned > 0 then ["addq $" ++ show totalBytesAligned ++ ", %rsp"] else []
                -- initialize loop counter in %rcx and store into loop slot
                init = compileExprFor localMap start ++ ["movq %rax, %rcx", "movq %rcx, -" ++ show loopSlot ++ "(%rbp)"]
                -- condition: if i >= end -> break
                cmpAsm = compileExprFor localMap end
                      ++ ["movq %rax, %rdx"                          -- end
                          ,"movq -" ++ show loopSlot ++ "(%rbp), %rcx" -- reload i
                          ,"cmpq %rdx, %rcx"
                          ,"jge " ++ lEnd]

                -- emit full body using localMap so defines/assigns work
                innerRet = ".Lret_loop_" ++ show lbl
                skip = ".Lskip_ret_" ++ show lbl
                bodyAsm = concatMap (\s -> stmtToASM s labels funcs consts localMap innerRet) body

                -- increment and store back to loop slot
                incr = ["movq -" ++ show loopSlot ++ "(%rbp), %rcx", "addq $1, %rcx", "movq %rcx, -" ++ show loopSlot ++ "(%rbp)"]
            in alloc ++ init ++ [lStart ++ ":"] ++ cmpAsm ++ bodyAsm ++ incr ++ ["jmp " ++ lStart, lEnd ++ ":"] ++ dealloc ++ ["jmp " ++ skip] ++ ["\t" ++ innerRet ++ ":", "jmp " ++ retLabel] ++ [skip ++ ":"]

        ("while", [condExpr@(Call (AstSymbol "<") [AstSymbol v, AstInt n]), Block body]) ->
            let lbl    = abs (hash (show condExpr)) `mod` 100000
                lStart = ".Lwhile_start_" ++ show lbl
                lEnd   = ".Lwhile_end_"   ++ show lbl

                -- condition: relire v depuis locals, comparer à n
                condAsm =
                  case Map.lookup v locals of
                    Just off ->
                      [ lStart ++ ":"
                      , "movq -" ++ show off ++ "(%rbp), %rax"
                      , "cmpq $" ++ show n ++ ", %rax"
                      , "jge " ++ lEnd
                      ]
                    Nothing ->
                      [ lStart ++ ":"
                      , "movq $0, %rax"
                      , "cmpq $" ++ show n ++ ", %rax"
                      , "jge " ++ lEnd
                      ]

                bodyAsm = concatMap (\s -> stmtToASM s labels funcs consts locals retLabel) body
            in condAsm ++ bodyAsm ++ ["jmp " ++ lStart, lEnd ++ ":"]

        -- autres appels (dont lambdas) inchangés
        _ -> case Map.lookup name funcs of
                Just (AstLambda _ body) ->
                    let localMap = buildLocalMap body
                        totalBytes = (Map.size localMap) * 8
                        totalBytesAligned = if totalBytes == 0 then 0 else ((totalBytes + 15) `div` 16) * 16
                        alloc = if totalBytesAligned > 0 then ["subq $" ++ show totalBytesAligned ++ ", %rsp"] else []
                        retL = ".Lret_" ++ show (abs (hash (show body)) `mod` 100000)
                    in alloc ++ emitStmts body labels funcs consts localMap retL ++ ["\t" ++ retL ++ ":"]
                _ -> []
  where
    compileExpr v = case v of
        AstInt n -> ["movq $" ++ show n ++ ", %rax"]
        AstSymbol s -> case Map.lookup s locals of
            Just off -> ["movq -" ++ show off ++ "(%rbp), %rax"]
            Nothing -> ["movq $0, %rax"]
        _ -> ["movq $0, %rax"]
stmtToASM (Return a) labels funcs consts locals retLabel = compileExpr a ++ cleanup ++ ["jmp " ++ retLabel]
  where
    -- compute cleanup for current locals (deallocate aligned stack bytes)
    -- NOTE: the top-level function epilogue performs final deallocation, so
    -- avoid duplicating the deallocation when jumping to the global ".Lreturn" label.
    totalBytes = (Map.size locals) * 8
    totalBytesAligned = if totalBytes == 0 then 0 else ((totalBytes + 15) `div` 16) * 16
    cleanup = if retLabel == ".Lreturn" then [] else if totalBytesAligned > 0 then ["addq $" ++ show totalBytesAligned ++ ", %rsp"] else []
    compileExpr e = case e of
            AstInt n -> ["movq $" ++ show n ++ ", %rax"]
            AstString s -> let si = lookupLabel s labels in ["leaq LC" ++ show si ++ "(%rip), %rax"]
            AstSymbol v -> case Map.lookup v locals of
                Just off -> ["movq -" ++ show off ++ "(%rbp), %rax"]
                Nothing -> ["movq $0, %rax"]
            Call (AstSymbol "+") [a',b'] -> compileExpr a' ++ ["pushq %rax"] ++ compileExpr b' ++ ["popq %rcx", "addq %rcx, %rax"]
            Call (AstSymbol "-") [a',b'] -> compileExpr a' ++ ["pushq %rax"] ++ compileExpr b' ++ ["popq %rcx", "subq %rax, %rcx", "movq %rcx, %rax"]
            _ -> ["movq $0, %rax"]
stmtToASM (Define name _ val) labels funcs consts locals retLabel = stmtToASM (Assign name val) labels funcs consts locals retLabel
stmtToASM (Assign name val) labels funcs consts locals retLabel =
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
stmtToASM _ _ _ _ _ _ = []


lookupLabel :: String -> [(String, Int)] -> Int
lookupLabel s labels = case lookup s labels of
    Just i -> i
    Nothing -> 0


collectStrings :: Map.Map String String -> Ast -> [String]
collectStrings consts (Block xs) = concatMap (collectStrings consts) xs
collectStrings _ (Call (AstSymbol "peric") (AstString s : _)) = [s]
collectStrings consts (Call (AstSymbol "peric") (Call (AstSymbol "string-interp") parts : _)) =
    let -- Attempt to fully evaluate the interpolated parts at compile-time
        tryConv p = case p of
            AstString s -> Just s
            AstInt n -> Just (show n)
            AstFloat f -> Just (show f)
            AstBool True -> Just "#t"
            AstBool False -> Just "#f"
            AstSymbol name -> Map.lookup name consts
            _ -> Nothing
        mStrings = sequence (map tryConv parts)
    in case mStrings of
        -- fully constant interpolation: add exact string so it's emitted in rodata
        Just ss -> [concat ss]
        -- otherwise keep format and any nested strings
        Nothing -> let fmtPart p = case p of
                                AstString s -> s
                                AstInt _ -> "%d"
                                AstFloat _ -> "%d"
                                AstBool _ -> "%s"
                                AstSymbol _ -> "%d"
                                _ -> ""
                       fmt = concatMap fmtPart parts ++ "\n"
                       partsStrs = concatMap (collectStrings consts) parts
                   in fmt : partsStrs
collectStrings consts (Call _ args) = concatMap (collectStrings consts) args
collectStrings _ (AstString s) = [s]
collectStrings consts (IfElse cond thenBlock elseBlock) = collectStrings consts cond ++ collectStrings consts thenBlock ++ collectStrings consts elseBlock
collectStrings consts (AstLambda _ body) = collectStrings consts body
collectStrings consts (Return a) = collectStrings consts a
collectStrings consts (Assign _ a) = collectStrings consts a
collectStrings consts (ArrayAssign _ _ a) = collectStrings consts a
collectStrings _ _ = []


collectFuncs :: Ast -> Map.Map String Ast
collectFuncs (Block xs) = foldl collect Map.empty xs
  where
    collect m (Define name _ (AstLambda params body)) = Map.insert name (AstLambda params body) m
    collect m _ = m
collectFuncs _ = Map.empty


-- Collect compile-time constant definitions (simple ints/strings/bools/floats)
-- Collect compile-time constant definitions (simple ints/strings/bools/floats)
-- `mutables` is the list of variable names that are assigned to; we must
-- *not* treat those as constants for string interpolation.
collectConsts :: Ast -> [String] -> Map.Map String String
collectConsts (Block xs) mutables = foldl (\r a -> Map.union r (collectConsts a mutables)) Map.empty xs
collectConsts (Define name _ val) mutables =
    if name `elem` mutables then Map.empty else
    case val of
        AstInt n -> Map.singleton name (show n)
        AstString s -> Map.singleton name s
        AstFloat f -> Map.singleton name (show f)
        AstBool True -> Map.singleton name "#t"
        AstBool False -> Map.singleton name "#f"
        _ -> collectConsts val mutables
collectConsts (Call _ args) mutables = foldl (\r a -> Map.union r (collectConsts a mutables)) Map.empty args
collectConsts (AstLambda _ body) mutables = collectConsts body mutables
collectConsts (Return a) mutables = collectConsts a mutables
collectConsts (Assign _ a) mutables = collectConsts a mutables
collectConsts (ArrayAssign _ _ a) mutables = collectConsts a mutables
collectConsts _ _ = Map.empty


-- Build a simple map of local variable names to stack offsets (8,16,...)
buildLocalMap :: Ast -> Map.Map String Int
buildLocalMap ast = 
  let names = collectNamesForLocals ast []
      uniq = uniqueList names
      offsets = map (*8) [1..]
      _ = unsafePerformIO (hPutStr stderr ("[debug] buildLocalMap names=" ++ show names ++ " uniq=" ++ show uniq ++ "\n"))
  in Map.fromList (zip uniq offsets)


-- Collect local variable names by scanning for define/assign patterns anywhere
collectNamesForLocals :: Ast -> [String] -> [String]
collectNamesForLocals ast acc = case ast of
  Block xs -> foldl (\a x -> collectNamesForLocals x a) acc xs
  Assign name _ -> acc ++ [name]
  Call (AstSymbol "define") (AstSymbol name : _ ) -> acc ++ [name]
  Call (AstSymbol "assign") (AstSymbol name : _ ) -> acc ++ [name]
  Define name _ val -> case val of
    AstLambda _ _ -> collectNamesForLocals val acc -- function define, don't add as local
    _ -> acc ++ [name]
  AstLambda _ body -> collectNamesForLocals body acc
  Call _ args -> foldl (\a x -> collectNamesForLocals x a) acc args
  Return a -> collectNamesForLocals a acc
  _ -> acc


uniqueList :: [String] -> [String]
uniqueList = foldl (\seen x -> if x `elem` seen then seen else seen ++ [x]) []


escapeASM :: String -> String
escapeASM = concatMap esc
  where
    esc '\\' = "\\\\"
    esc '"' = "\\\""
    esc '\n' = "\\n"
    esc c = [c]
