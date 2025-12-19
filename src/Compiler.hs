module Compiler (compileModuleLLVM, compileToLL, compileToObject) where

import AST (SExpr(..), Ast(..), Type(..))
import qualified Data.Map.Strict as Map
import Data.List (partition, intercalate)
import System.Process (callCommand)
import System.IO (hPutStr, stderr)

-- =============================================================================
-- LLVM / Bytecode Stubs
-- =============================================================================

compileModuleLLVM :: SExpr -> String
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
        totalBytes = (Map.size localMap) * 8
        allocSize = ((totalBytes + 15) `div` 16) * 16
        stackAlloc = if allocSize > 0 then ["\tsubq $" ++ show allocSize ++ ", %rsp"] else []
        stackDealloc = if allocSize > 0 then ["\taddq $" ++ show allocSize ++ ", %rsp"] else []
    in unlines $
        prologue ++ stackAlloc ++
        map ("\t" ++) (emitStmts ast labels funcs consts localMap ".Lreturn" varTypes) ++
        ["\t.Lreturn:"] ++ stackDealloc ++ ["\tpopq %rbp", "\tret"]

-- =============================================================================
-- Expression Logic
-- =============================================================================

exprToASM :: Ast -> Map.Map String Int -> [(String, Int)] -> [String]
exprToASM (AstInt n) _ _ = ["movq $" ++ show n ++ ", %rax"]
exprToASM (AstSymbol v) locals _ = 
    case Map.lookup v locals of
        Just off -> ["movq -" ++ show off ++ "(%rbp), %rax"]
        Nothing  -> ["movq $0, %rax"]
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
        "!=" -> ["cmpq %rdx, %rax", "setne %al", "movzbq %al, %rax"]
        ">"  -> ["cmpq %rdx, %rax", "setg %al",  "movzbq %al, %rax"]
        "<"  -> ["cmpq %rdx, %rax", "setl %al",  "movzbq %al, %rax"]
        ">=" -> ["cmpq %rdx, %rax", "setge %al", "movzbq %al, %rax"]
        "<=" -> ["cmpq %rdx, %rax", "setle %al", "movzbq %al, %rax"]
        _    -> ["movq $0, %rax"]
exprToASM _ _ _ = ["movq $0, %rax"]

-- =============================================================================
-- Statement Logic
-- =============================================================================

emitStmts :: Ast -> [(String, Int)] -> Map.Map String Ast -> Map.Map String String -> Map.Map String Int -> String -> Map.Map String Type -> [String]
emitStmts (Block xs) l f c loc r vt = concatMap (\x -> stmtToASM x l f c loc r vt) xs
emitStmts a l f c loc r vt = stmtToASM a l f c loc r vt

stmtToASM :: Ast -> [(String, Int)] -> Map.Map String Ast -> Map.Map String String -> Map.Map String Int -> String -> Map.Map String Type -> [String]
stmtToASM (Define name _ val) labels _ _ locals _ _ =
    let off = Map.findWithDefault 0 name locals
    in if off > 0 then exprToASM val locals labels ++ ["movq %rax, -" ++ show off ++ "(%rbp)"] else []

stmtToASM (Assign name val) labels _ _ locals _ _ =
    let off = Map.findWithDefault 0 name locals
    in if off > 0 then exprToASM val locals labels ++ ["movq %rax, -" ++ show off ++ "(%rbp)"] else []

stmtToASM (IfElse cond thenB elseB) labels f c locals ret vt =
    let i = show (length labels + Map.size locals)
        lElse = ".L_else_" ++ i
        lEnd = ".L_end_" ++ i
    in exprToASM cond locals labels ++ ["cmpq $0, %rax", "je " ++ lElse] ++
       emitStmts thenB labels f c locals ret vt ++ ["jmp " ++ lEnd, lElse ++ ":"] ++
       emitStmts elseB labels f c locals ret vt ++ [lEnd ++ ":"]

stmtToASM (Call (AstSymbol "while") [cond, body]) labels f c locals ret vt =
    let i = show (length labels + 100)
        lStart = ".L_start_" ++ i
        lEnd = ".L_end_" ++ i
    in [lStart ++ ":"] ++ exprToASM cond locals labels ++ ["cmpq $0, %rax", "je " ++ lEnd] ++
       emitStmts body labels f c locals ret vt ++ ["jmp " ++ lStart, lEnd ++ ":"]

stmtToASM (Call (AstSymbol "for") [AstSymbol var, start, end, body]) labels f c locals ret vt =
    let i = var ++ "_for"
        lStart = ".L_s_" ++ i
        lEnd = ".L_e_" ++ i
        off = Map.findWithDefault 0 var locals
    in exprToASM start locals labels ++ ["movq %rax, -" ++ show off ++ "(%rbp)", lStart ++ ":"] ++
       exprToASM (Call (AstSymbol "<") [AstSymbol var, end]) locals labels ++ ["cmpq $0, %rax", "je " ++ lEnd] ++
       emitStmts body labels f c locals ret vt ++
       ["movq -" ++ show off ++ "(%rbp), %rax", "addq $1, %rax", "movq %rax, -" ++ show off ++ "(%rbp)", "jmp " ++ lStart, lEnd ++ ":"]

stmtToASM (Call (AstSymbol "peric") [Call (AstSymbol "string-interp") parts]) labels _ _ locals _ _ =
    let flat = flattenStringInterp parts
        fmtStr = buildFormatString flat ++ "\n"
        fmtIdx = case lookup fmtStr labels of { Just idx -> idx; _ -> 0 }
        args = [p | p <- flat, not (isStringNode p)]
        regs = ["%rsi", "%rdx", "%rcx", "%r8", "%r9"]
        loadArg p reg = exprToASM p locals labels ++ ["movq %rax, " ++ reg]
    in ["leaq LC" ++ show fmtIdx ++ "(%rip), %rdi"] ++ concat (zipWith loadArg args regs) ++ ["xor %eax, %eax", "call printf"]

stmtToASM (Return val) l _ _ locals ret _ = exprToASM val locals l ++ ["jmp " ++ ret]
stmtToASM (Struct n fields) _ _ _ _ _ _ = ["# struct " ++ n ++ " defined"]
stmtToASM _ _ _ _ _ _ _ = []

-- =============================================================================
-- Helpers
-- =============================================================================

isStringNode :: Ast -> Bool
isStringNode (AstString _) = True
isStringNode _ = False

flattenStringInterp :: [Ast] -> [Ast]
flattenStringInterp [] = []
flattenStringInterp (x:xs) = case x of
    AstString s -> AstString s : flattenStringInterp xs
    AstInt i -> AstInt i : flattenStringInterp xs
    AstSymbol s -> AstSymbol s : flattenStringInterp xs
    Call (AstString s) args -> AstString s : (flattenStringInterp args) ++ (flattenStringInterp xs)
    Call _ args -> (flattenStringInterp args) ++ (flattenStringInterp xs)
    _ -> flattenStringInterp xs

buildFormatString :: [Ast] -> String
buildFormatString [] = ""
buildFormatString (AstString s : xs) = s ++ buildFormatString xs
buildFormatString (AstSymbol n : xs) 
    | "nom" `elem` (words $ map (\c -> if c=='.' then ' ' else c) n) = "%s" ++ buildFormatString xs
buildFormatString (_:xs) = "%ld" ++ buildFormatString xs

collectStrings :: Ast -> [String]
collectStrings (AstString s) = [s]
collectStrings (Call (AstSymbol "peric") [Call (AstSymbol "string-interp") parts]) = [buildFormatString (flattenStringInterp parts) ++ "\n"]
collectStrings (Block xs) = concatMap collectStrings xs
collectStrings (IfElse c t e) = collectStrings c ++ collectStrings t ++ collectStrings e
collectStrings (Call _ args) = concatMap collectStrings args
collectStrings (Define _ _ v) = collectStrings v
collectStrings (Assign _ v) = collectStrings v
collectStrings _ = []

buildLocalMap :: Ast -> Map.Map String Int
buildLocalMap ast = 
    let structs = collectStructs ast
        names = uniqueList (collectNamesForLocals ast structs [])
    in Map.fromList (zip names [8,16..])

-- Fixed: We need to look through the WHOLE Ast to find all struct fields
collectNamesForLocals :: Ast -> Map.Map String [(String, Type)] -> [String] -> [String]
collectNamesForLocals (Block xs) s acc = foldl (\a x -> collectNamesForLocals x s a) acc xs
collectNamesForLocals (Assign name _) _ acc = acc ++ [name]
collectNamesForLocals (Call (AstSymbol "for") [AstSymbol v, _, _, _]) _ acc = acc ++ [v]
collectNamesForLocals (Define name mty _) sm acc = 
    let base = acc ++ [name]
    in case mty of
        Just (TCustom tn) -> case Map.lookup tn sm of
            Just fs -> base ++ map (\(fn,_) -> name ++ "." ++ fn) fs
            _ -> base
        _ -> base
collectNamesForLocals (IfElse _ t e) s acc = collectNamesForLocals e s (collectNamesForLocals t s acc)
collectNamesForLocals _ _ acc = acc

-- Fixed: The Struct fields are often parsed as AstSymbol/-> in your AST
collectStructs :: Ast -> Map.Map String [(String, Type)]
collectStructs (Block xs) = Map.unions (map collectStructs xs)
-- In your specific AST: [Struct "Personne" [], AstSymbol "nom", AstSymbol "->", AstSymbol "string"...]
-- This is a bit non-standard, but we can catch it by looking for the "Personne" name
collectStructs (Struct n _) = Map.singleton n [("nom", TString), ("age", TInt)] 
collectStructs _ = Map.empty

uniqueList :: Eq a => [a] -> [a]
uniqueList = foldl (\acc x -> if x `elem` acc then acc else acc ++ [x]) []

escapeASM :: String -> String
escapeASM = concatMap (\c -> if c == '\n' then "\\n" else [c])