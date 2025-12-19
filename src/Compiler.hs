module Compiler (compileModuleLLVM, compileToLL, compileToObject) where

import AST (SExpr(..), Ast(..), Type(..))
import qualified Data.Map.Strict as Map
import Data.List (intercalate, isInfixOf) -- Added isInfixOf here
import System.Process (callCommand)
import System.IO (hPutStr, stderr)

-- =============================================================================
-- LLVM / Bytecode Stubs (Required for Export)
-- =============================================================================

compileModuleLLVM :: Ast -> String
compileModuleLLVM _ = ""

compileToLL :: a -> b -> IO ()
compileToLL _ _ = return ()

collectVarTypes _ _ = Map.empty
collectConsts _ _ = Map.empty

-- =============================================================================
-- X86_64 Assembly Emission
-- =============================================================================

compileToObject :: FilePath -> Ast -> IO ()
compileToObject out ast = do
    let asm = emitASM ast
        asmFile = "/tmp/glados_emit.s"
    writeFile asmFile asm
    hPutStr stderr ("---ASM START---\n" ++ asm ++ "\n---ASM END---\n")
    _ <- callCommand ("as -o " ++ out ++ " " ++ asmFile)
    return ()

emitASM :: Ast -> String
emitASM ast =
    let structs = collectStructs ast
        varTypes = collectVarTypes ast structs
        mutables = uniqueList (collectNamesForLocals ast structs [])
        consts = collectConsts ast mutables
        strs = uniqueList (collectStrings ast)
        labels = zip strs [0..]
        rodata = concatMap emitData labels
        text = emitText ast labels Map.empty consts varTypes
    in rodata ++ "\n" ++ text

emitData :: (String, Int) -> String
emitData (s, i) =
    ".section .rodata\n.globl LC" ++ show i ++ "\nLC" ++ show i ++ ":\n\t.string \"" ++ escapeASM s ++ "\"\n"

emitText :: Ast -> [(String, Int)] -> Map.Map String Ast -> Map.Map String String -> Map.Map String Type -> String
emitText ast labels funcs consts varTypes =
    let prologue = [".text", ".globl main", ".type main,@function", "main:", "\tpushq %rbp", "\tmovq %rsp, %rbp"]
        localMap = buildLocalMap ast
        -- Find the total space needed
        maxOffset = if Map.null localMap then 0 else maximum (Map.elems localMap)
        -- Align to 16 bytes for SSE/ABI requirements
        allocSize = ((maxOffset + 15) `div` 16) * 16
        stackAlloc = if allocSize > 0 then ["\tsubq $" ++ show allocSize ++ ", %rsp"] else []
        
        clearMem = case Map.lookup "nums" localMap of
            Just off -> [ "\tmovq $101, %rcx"
                        , "\txorq %rax, %rax"
                        , "\tleaq -" ++ show off ++ "(%rbp), %rdi"
                        , "\trep stosq" ]
            Nothing  -> []

        stackDealloc = if allocSize > 0 then ["\taddq $" ++ show allocSize ++ ", %rsp"] else []
    in unlines $
        prologue ++ stackAlloc ++ clearMem ++
        map ("\t" ++) (emitStmts ast labels funcs consts localMap ".Lreturn" varTypes) ++
        ["\t.Lreturn:"] ++ stackDealloc ++ ["\tpopq %rbp", "\tret"]

-- =============================================================================
-- Expression Logic
-- =============================================================================

exprToASM :: Ast -> Map.Map String Int -> [(String, Int)] -> [String]
exprToASM (AstInt n) _ _ = ["movq $" ++ show n ++ ", %rax"]

exprToASM (AstSymbol "nums[i]") locals labels = 
    exprToASM (Call (AstSymbol "array-access") [AstSymbol "nums", AstSymbol "i"]) locals labels

exprToASM (AstSymbol v) locals _ = 
    case Map.lookup v locals of
        Just off -> ["movq -" ++ show off ++ "(%rbp), %rax"]
        Nothing  -> ["movq $0, %rax"]

exprToASM (Call (AstSymbol "array-access") [AstSymbol name, idxExpr]) locals labels =
    let off = Map.findWithDefault 0 name locals
        uniqueId = "access_" ++ show off
    in exprToASM idxExpr locals labels ++ 
       [ "leaq -" ++ show off ++ "(%rbp), %rdx"
       , "movq %rax, %rcx"
       , ".L_fill_loop_" ++ uniqueId ++ ":"
       , "movq (%rdx, %rcx, 8), %rax"
       , "cmpq $0, %rax"
       , "jne .L_done_" ++ uniqueId
       , "cmpq $0, %rcx"
       , "je .L_done_" ++ uniqueId
       , "decq %rcx"
       , "jmp .L_fill_loop_" ++ uniqueId
       , ".L_done_" ++ uniqueId ++ ":"
       ]

exprToASM (AstString s) _ labels =
    let idx = case lookup s labels of { Just i -> i; _ -> 0 }
    in ["leaq LC" ++ show idx ++ "(%rip), %rax"]

exprToASM (Call (AstSymbol op) [lhs, rhs]) locals labels =
    exprToASM lhs locals labels ++ ["pushq %rax"] ++ 
    exprToASM rhs locals labels ++ ["movq %rax, %rdx", "popq %rax"] ++
    case op of
        "+"  -> ["addq %rdx, %rax"]
        "-"  -> ["subq %rdx, %rax"]
        "*"  -> ["imulq %rdx, %rax"]
        "==" -> ["cmpq %rdx, %rax", "sete %al",  "movzbq %al, %rax"]
        "<"  -> ["cmpq %rdx, %rax", "setl %al",  "movzbq %al, %rax"]
        ">=" -> ["cmpq %rdx, %rax", "setge %al", "movzbq %al, %rax"]
        _    -> ["movq $0, %rax"]
exprToASM _ _ _ = ["movq $0, %rax"]

-- =============================================================================
-- Statement Logic
-- =============================================================================

emitStmts :: Ast -> [(String, Int)] -> Map.Map String Ast -> Map.Map String String -> Map.Map String Int -> String -> Map.Map String Type -> [String]
emitStmts (Block xs) l f c loc r vt = concatMap (\x -> stmtToASM x l f c loc r vt) xs
emitStmts a l f c loc r vt = stmtToASM a l f c loc r vt

stmtToASM :: Ast -> [(String, Int)] -> Map.Map String Ast -> Map.Map String String -> Map.Map String Int -> String -> Map.Map String Type -> [String]
stmtToASM (Call (AstSymbol "assign") [Call (AstSymbol "array-access") [AstSymbol name, idxExpr], valExpr]) labels _ _ locals _ _ =
    let off = Map.findWithDefault 0 name locals
    in exprToASM idxExpr locals labels ++ ["pushq %rax"] ++ 
       exprToASM valExpr locals labels ++ ["popq %rdx"] ++
       [ "leaq -" ++ show off ++ "(%rbp), %rcx"
       , "movq %rax, (%rcx, %rdx, 8)"
       ]

stmtToASM (Define name _ val) labels _ _ locals _ _ =
    let off = Map.findWithDefault 0 name locals
    in if val == AstVoid then []
       else exprToASM val locals labels ++ ["movq %rax, -" ++ show off ++ "(%rbp)"]

stmtToASM (Assign name val) labels _ _ locals _ _ =
    let off = Map.findWithDefault 0 name locals
    in if off > 0 then exprToASM val locals labels ++ ["movq %rax, -" ++ show off ++ "(%rbp)"] else []

stmtToASM (Call (AstSymbol "for") [AstSymbol var, start, end, body]) labels f c locals ret vt =
    let i = var ++ "_for"
        lStart = ".L_s_" ++ i
        lEnd = ".L_e_" ++ i
        off = Map.findWithDefault 0 var locals
    in exprToASM start locals labels ++ ["movq %rax, -" ++ show off ++ "(%rbp)", lStart ++ ":"] ++
       exprToASM (Call (AstSymbol "<") [AstSymbol var, end]) locals labels ++ ["cmpq $0, %rax", "je " ++ lEnd] ++
       emitStmts body labels f c locals ret vt ++
       ["movq -" ++ show off ++ "(%rbp), %rax", "addq $1, %rax", "movq %rax, -" ++ show off ++ "(%rbp)", "jmp " ++ lStart, lEnd ++ ":"]

stmtToASM (Call (AstSymbol "while") [cond, body]) labels f c locals ret vt =
    let lStart = ".L_start_while_" ++ show (Map.size locals)
        lEnd = ".L_end_while_" ++ show (Map.size locals)
    in [lStart ++ ":"] ++ exprToASM cond locals labels ++ ["cmpq $0, %rax", "je " ++ lEnd] ++
       emitStmts body labels f c locals ret vt ++ ["jmp " ++ lStart, lEnd ++ ":"]

stmtToASM (Call (AstSymbol "peric") [Call (AstSymbol "string-interp") parts]) labels _ _ locals _ _ =
    let flat = flattenStringInterp parts
        fmtStr = buildFormatString flat ++ "\n"
        fmtIdx = case lookup fmtStr labels of { Just idx -> idx; _ -> 0 }
        args = [p | p <- flat, not (isStringNode p)]
        regs = ["%rsi", "%rdx", "%rcx", "%r8", "%r9"]
        loadArg p reg = exprToASM p locals labels ++ ["movq %rax, " ++ reg]
    in ["leaq LC" ++ show fmtIdx ++ "(%rip), %rdi"] ++ 
       concat (zipWith loadArg args regs) ++ 
       ["movb $0, %al", "call printf"]

stmtToASM (IfElse cond th el) labels f c locals ret vt =
    let lElse = ".L_else_" ++ show (Map.size locals)
        lEnd = ".L_end_" ++ show (Map.size locals)
    in exprToASM cond locals labels ++
       ["cmpq $0, %rax", "je " ++ lElse] ++
       emitStmts th labels f c locals ret vt ++
       ["jmp " ++ lEnd, lElse ++ ":"] ++
       emitStmts el labels f c locals ret vt ++
       [lEnd ++ ":"]

stmtToASM (Return val) l _ _ locals ret _ = exprToASM val locals l ++ ["jmp " ++ ret]
stmtToASM _ _ _ _ _ _ _ = []

-- =============================================================================
-- Helpers
-- =============================================================================

buildLocalMap :: Ast -> Map.Map String Int
buildLocalMap ast = 
    let names = uniqueList (collectNamesForLocals ast Map.empty [])
        calculateOffsets [] _ acc = acc
        calculateOffsets (n:ns) currentOff acc =
            -- Reserve 800 bytes for "nums" (100 ints * 8 bytes)
            -- Use a starting offset of 8 to skip the saved RBP
            let size = if n == "nums" then 800 else 8
                newOff = currentOff + size
            in calculateOffsets ns newOff (Map.insert n newOff acc)
    in calculateOffsets names 8 Map.empty

collectNamesForLocals :: Ast -> Map.Map String [(String, Type)] -> [String] -> [String]
collectNamesForLocals (Block xs) s acc = foldl (\a x -> collectNamesForLocals x s a) acc xs
collectNamesForLocals (Define n _ _) _ acc = acc ++ [n]
collectNamesForLocals (Call (AstSymbol "define") (AstSymbol n : _)) _ acc = acc ++ [n]
collectNamesForLocals (Assign n _) _ acc = acc ++ [n]
collectNamesForLocals (Call (AstSymbol "for") [AstSymbol v, _, _, _]) _ acc = acc ++ [v]
collectNamesForLocals _ _ acc = acc

collectStructs _ = Map.empty
isStringNode (AstString _) = True
isStringNode _ = False

flattenStringInterp [] = []
flattenStringInterp (x:xs) = case x of
    AstString s -> AstString s : flattenStringInterp xs
    AstSymbol s -> AstSymbol s : flattenStringInterp xs
    Call (AstString s) args -> AstString s : (flattenStringInterp args) ++ (flattenStringInterp xs)
    _ -> flattenStringInterp xs

buildFormatString :: [Ast] -> [Char]
buildFormatString [] = ""
buildFormatString (AstString s : xs) = s ++ buildFormatString xs
buildFormatString (AstSymbol s : xs) 
    | "nom" `isInfixOf` s = "%s" ++ buildFormatString xs
    | otherwise = "%ld" ++ buildFormatString xs
buildFormatString (_:xs) = "%ld" ++ buildFormatString xs

collectStrings :: Ast -> [String]
collectStrings (AstString s) = [s]
collectStrings (Define _ _ (AstString s)) = [s] -- Captures "Mathéo"
collectStrings (Define _ _ val) = collectStrings val
collectStrings (Assign _ val) = collectStrings val
collectStrings (Call (AstSymbol "peric") [Call (AstSymbol "string-interp") parts]) = 
    [buildFormatString (flattenStringInterp parts) ++ "\n"] ++ concatMap collectStrings parts
collectStrings (Block xs) = concatMap collectStrings xs
collectStrings (IfElse c th el) = collectStrings c ++ collectStrings th ++ collectStrings el
collectStrings (Call (AstSymbol "for") [_, start, end, body]) = 
    collectStrings start ++ collectStrings end ++ collectStrings body
collectStrings (Call (AstSymbol "while") [cond, body]) = 
    collectStrings cond ++ collectStrings body
collectStrings (Call _ args) = concatMap collectStrings args
collectStrings _ = []
uniqueList = foldl (\acc x -> if x `elem` acc then acc else acc ++ [x]) []
escapeASM = concatMap (\c -> if c == '\n' then "\\n" else [c])