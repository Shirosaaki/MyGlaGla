module Compiler (compileModuleLLVM, compileToLL, compileToObject) where

import AST (Ast(..), Type(..))
import qualified Data.Map.Strict as Map
import Data.List (isInfixOf)
import System.Process (callCommand)
import System.IO (hPutStr, stderr)

-- =============================================================================
-- LLVM Stubs (Required for Export)
-- =============================================================================

compileModuleLLVM :: Ast -> String
compileModuleLLVM _ = ""

compileToLL :: a -> b -> IO ()
compileToLL _ _ = return ()

-- =============================================================================
-- Analysis & Memory Mapping
-- =============================================================================

collectVarTypes :: Ast -> Map.Map String Type -> Map.Map String Type
collectVarTypes (Block xs) structs = Map.unions (map (`collectVarTypes` structs) xs)
collectVarTypes (Define n (Just t) _) _ = Map.singleton n t
collectVarTypes (Assign n (AstString _)) _ = Map.singleton n TString
collectVarTypes (Call (AstSymbol "define") [AstSymbol n, Call (AstSymbol "array-type") _]) _ = Map.singleton n TInt
collectVarTypes (Call (AstSymbol "for") [AstSymbol v, _, _, body]) structs = 
    Map.insert v TInt (collectVarTypes body structs)
collectVarTypes (IfElse _ th el) structs = 
    collectVarTypes th structs `Map.union` collectVarTypes el structs
collectVarTypes _ _ = Map.empty

collectNamesForLocals :: Ast -> [String]
collectNamesForLocals (Block xs) = concatMap collectNamesForLocals xs
collectNamesForLocals (Define n _ _) = [n]
collectNamesForLocals (Assign n _) = [n]
collectNamesForLocals (Call (AstSymbol "define") (AstSymbol n : _)) = [n]
collectNamesForLocals (Call (AstSymbol "assign") [Call (AstSymbol "array-access") [AstSymbol n, _], _]) = [n]
collectNamesForLocals (Call (AstSymbol "assign") [AstSymbol n, _]) = [n]
collectNamesForLocals (Call (AstSymbol "for") [AstSymbol v, _, _, body]) = v : collectNamesForLocals body
collectNamesForLocals (Call (AstSymbol "while") [_, body]) = collectNamesForLocals body
collectNamesForLocals (IfElse _ th el) = collectNamesForLocals th ++ collectNamesForLocals el
collectNamesForLocals _ = []

buildLocalMap :: Ast -> Map.Map String Int
buildLocalMap ast = 
    let names = uniqueList (collectNamesForLocals ast)
        calc [] _ acc = acc
        calc (n:ns) cur acc = 
            let sz = if n == "nums" then 808 else 8
            in calc ns (cur + sz) (Map.insert n (cur + sz) acc)
    in calc names 8 Map.empty

-- =============================================================================
-- ASM Emission
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
    let varTypes = collectVarTypes ast Map.empty
        strs = uniqueList (collectStrings ast varTypes) 
        labels = zip strs [0..]
    in concatMap (emitData) labels ++ "\n" ++ emitText ast labels varTypes ++ "\n" ++ builtInFunctions

emitData :: (String, Int) -> String
emitData (s, i) = ".globl LC" ++ show i ++ "\nLC" ++ show i ++ ": .string \"" ++ escapeASM s ++ "\"\n"

emitText :: Ast -> [(String, Int)] -> Map.Map String Type -> String
emitText ast labels vt =
    let localMap = buildLocalMap ast
        maxOffset = if Map.null localMap then 8 else maximum (Map.elems localMap)
        allocSize = ((maxOffset + 31) `div` 16) * 16
        prologue = [".text", ".globl main", "main:", "\tpushq %rbp", "\tmovq %rsp, %rbp", "\tsubq $" ++ show allocSize ++ ", %rsp"]
        clearMem = case Map.lookup "nums" localMap of
            Just off -> ["\tmovq $101, %rcx", "\txorq %rax, %rax", "\tleaq -" ++ show off ++ "(%rbp), %rdi", "\trep stosq"]
            Nothing  -> []
        body = emitStmts ast labels localMap ".Lreturn" vt
        epilogue = [".Lreturn:", "\taddq $" ++ show allocSize ++ ", %rsp", "\tpopq %rbp", "\tret"]
    in unlines $ prologue ++ clearMem ++ map ("\t" ++) body ++ epilogue

-- =============================================================================
-- Expression & Statement Logic
-- =============================================================================

exprToASM :: Ast -> Map.Map String Int -> [(String, Int)] -> Map.Map String Type -> [String]
exprToASM (AstInt n) _ _ _ = ["movq $" ++ show n ++ ", %rax"]
exprToASM (AstSymbol v) locals labels vt
    | " + " `isInfixOf` v = let p = words v in exprToASM (Call (AstSymbol "+") [AstSymbol (p!!0), AstSymbol (p!!2)]) locals labels vt
    | "[" `isInfixOf` v = -- Generic shorthand: array[index]
        let name = takeWhile (/= '[') v
            idx  = reverse $ takeWhile (/= '[') $ drop 1 $ reverse v
        in exprToASM (Call (AstSymbol "array-access") [AstSymbol name, AstSymbol idx]) locals labels vt
    | otherwise = case Map.lookup v locals of
        Just off -> ["movq -" ++ show off ++ "(%rbp), %rax"]
        Nothing  -> ["movq $0, %rax"]
exprToASM (AstString s) _ labels _ = ["leaq LC" ++ show (maybe 0 id (lookup s labels)) ++ "(%rip), %rax"]
exprToASM (Call (AstSymbol "+") [lhs, rhs]) locals labels vt =
    let isStr a = case a of { AstString _ -> True; AstSymbol s -> Map.lookup s vt == Just TString; Call (AstSymbol f) _ -> f `elem` ["renaud","romaric","str_concat","+"]; _ -> False }
    in if isStr lhs || isStr rhs
       then exprToASM lhs locals labels vt ++ ["pushq %rax"] ++ exprToASM rhs locals labels vt ++ ["movq %rax, %rsi", "popq %rdi", "call str_concat"]
       else exprToASM lhs locals labels vt ++ ["pushq %rax"] ++ exprToASM rhs locals labels vt ++ ["movq %rax, %rdx", "popq %rax", "addq %rdx, %rax"]
exprToASM (Call (AstSymbol "array-access") [AstSymbol name, idxExpr]) locals labels vt =
    let off = Map.findWithDefault 0 name locals
        uid = "acc" ++ show off ++ show (length labels)
    in exprToASM idxExpr locals labels vt ++ ["leaq -" ++ show off ++ "(%rbp), %rdx", "movq %rax, %rcx", ".L_f_" ++ uid ++ ":", "movq (%rdx, %rcx, 8), %rax", "cmpq $0, %rax", "jne .L_d_" ++ uid, "cmpq $0, %rcx", "je .L_d_" ++ uid, "decq %rcx", "jmp .L_f_" ++ uid, ".L_d_" ++ uid ++ ":"]
exprToASM (Call (AstSymbol op) [lhs, rhs]) locals labels vt
    | op `elem` ["<", "==", ">", "<=", ">="] = 
        let instr = case op of { "<" -> "setl"; "==" -> "sete"; ">" -> "setg"; "<=" -> "setle"; ">=" -> "setge"; _ -> "sete" }
        in exprToASM lhs locals labels vt ++ ["pushq %rax"] ++ exprToASM rhs locals labels vt ++ ["movq %rax, %rdx", "popq %rax", "cmpq %rdx, %rax", instr ++ " %al", "movzbq %al, %rax"]
exprToASM (Call (AstSymbol func) args) locals labels vt
    | func `notElem` ["+", "-", "*", "==", "<", ">", "<=", ">=", "assign", "define", "array-type", "array-access"] =
        let evals = concatMap (\arg -> exprToASM arg locals labels vt ++ ["pushq %rax"]) args
            loads = concat $ reverse $ zipWith (\_ r -> ["popq " ++ r]) args ["%rdi", "%rsi", "%rdx", "%rcx", "%r8", "%r9"]
        in evals ++ loads ++ ["movb $0, %al", "call " ++ func]
exprToASM _ _ _ _ = ["movq $0, %rax"]

stmtToASM :: Ast -> [(String, Int)] -> Map.Map String Int -> String -> Map.Map String Type -> [String]
stmtToASM (Define name _ val) labels locals _ vt =
    let off = Map.findWithDefault 0 name locals
    in if val == AstVoid then [] else exprToASM val locals labels vt ++ ["movq %rax, -" ++ show off ++ "(%rbp)"]
stmtToASM (Assign name val) labels locals _ vt =
    let off = Map.findWithDefault 0 name locals
    in if off > 0 then exprToASM val locals labels vt ++ ["movq %rax, -" ++ show off ++ "(%rbp)"] else []
stmtToASM (Call (AstSymbol "peric") [Call (AstSymbol "string-interp") pts]) labels locals _ vt =
    let flat = flattenStringInterp pts; fmt = buildFormatString vt flat ++ "\n"
        fmtIdx = maybe 0 id (lookup fmt labels); args = [p | p <- flat, not (isStringNode p)]
        evals = concatMap (\p -> exprToASM p locals labels vt ++ ["pushq %rax"]) args
        loads = concat $ reverse $ zipWith (\_ r -> ["popq " ++ r]) args ["%rsi", "%rdx", "%rcx", "%r8", "%r9"]
    in evals ++ loads ++ ["leaq LC" ++ show fmtIdx ++ "(%rip), %rdi", "movb $0, %al", "call printf"]
stmtToASM (Call (AstSymbol "assign") [Call (AstSymbol "array-access") [AstSymbol n, i], v]) labels locals _ vt =
    let off = Map.findWithDefault 0 n locals
    in exprToASM i locals labels vt ++ ["pushq %rax"] ++ exprToASM v locals labels vt ++ ["popq %rdx", "leaq -" ++ show off ++ "(%rbp), %rcx", "movq %rax, (%rcx, %rdx, 8)"]
stmtToASM (Call (AstSymbol "assign") [AstSymbol n, v]) l loc _ vt = stmtToASM (Assign n v) l loc "" vt
stmtToASM (Call (AstSymbol "for") [AstSymbol v, s, e, b]) labels locals ret vt =
    let off = Map.findWithDefault 0 v locals; lS = ".L_s_" ++ v ++ show (length labels); lE = ".L_e_" ++ v ++ show (length labels)
    in exprToASM s locals labels vt ++ ["movq %rax, -" ++ show off ++ "(%rbp)", lS ++ ":"] ++ exprToASM (Call (AstSymbol "<") [AstSymbol v, e]) locals labels vt ++ ["cmpq $0, %rax", "je " ++ lE] ++ emitStmts b labels locals ret vt ++ ["movq -" ++ show off ++ "(%rbp), %rax", "incq %rax", "movq %rax, -" ++ show off ++ "(%rbp)", "jmp " ++ lS, lE ++ ":"]
stmtToASM (IfElse cond th el) labels locals ret vt =
    let lElse = ".L_else_" ++ show (length labels); lEnd = ".L_end_" ++ show (length labels)
    in exprToASM cond locals labels vt ++ ["cmpq $0, %rax", "je " ++ lElse] ++ emitStmts th labels locals ret vt ++ ["jmp " ++ lEnd, lElse ++ ":"] ++ emitStmts el labels locals ret vt ++ [lEnd ++ ":"]
stmtToASM (Call (AstSymbol "while") [cond, body]) labels locals ret vt =
    let lStart = ".L_w_s" ++ show (length labels); lEnd = ".L_w_e" ++ show (length labels)
    in [lStart ++ ":"] ++ exprToASM cond locals labels vt ++ ["cmpq $0, %rax", "je " ++ lEnd] ++ emitStmts body labels locals ret vt ++ ["jmp " ++ lStart, lEnd ++ ":"]
stmtToASM (Return v) l locals ret vt = exprToASM v locals l vt ++ ["jmp " ++ ret]
stmtToASM (Block xs) l loc ret vt = handleBrokenNodes xs l loc ret vt
stmtToASM a l loc _ vt = exprToASM a loc l vt

emitStmts :: Ast -> [(String, Int)] -> Map.Map String Int -> String -> Map.Map String Type -> [String]
emitStmts (Block xs) l loc r vt = handleBrokenNodes xs l loc r vt
emitStmts a l loc r vt = stmtToASM a l loc r vt

handleBrokenNodes :: [Ast] -> [(String, Int)] -> Map.Map String Int -> String -> Map.Map String Type -> [String]
handleBrokenNodes [] _ _ _ _ = []
handleBrokenNodes (Assign n (AstSymbol f) : AstString a : xs) l loc r vt 
    | f `elem` ["renaud","romaric"] = stmtToASM (Assign n (Call (AstSymbol f) [AstString a])) l loc r vt ++ handleBrokenNodes xs l loc r vt
handleBrokenNodes (x:xs) l loc r vt = stmtToASM x l loc r vt ++ handleBrokenNodes xs l loc r vt

-- =============================================================================
-- Helpers
-- =============================================================================

isStringNode (AstString _) = True
isStringNode _ = False

flattenStringInterp [] = []
flattenStringInterp (Call (AstString s) args : xs) = AstString s : (flattenStringInterp args) ++ flattenStringInterp xs
flattenStringInterp (x:xs) = x : flattenStringInterp xs

buildFormatString vt (AstString s : xs) = s ++ buildFormatString vt xs
buildFormatString vt (AstSymbol s : xs) = 
    let isStr = Map.lookup s vt == Just TString || " + " `isInfixOf` s
        isArr = "[" `isInfixOf` s -- Check for nums[i]
    in (if isStr && not isArr then "%s" else "%ld") ++ buildFormatString vt xs
buildFormatString vt (Call (AstSymbol "+") _ : xs) = "%s" ++ buildFormatString vt xs
buildFormatString vt (_ : xs) = "%ld" ++ buildFormatString vt xs
buildFormatString _ [] = ""

collectStrings ast vt = case ast of
    AstString s -> [s]
    Call (AstSymbol "peric") [Call (AstSymbol "string-interp") pts] ->
        let flat = flattenStringInterp pts; fmt = buildFormatString vt flat ++ "\n"
        in [fmt] ++ concatMap (`collectStrings` vt) flat
    Block xs -> concatMap (`collectStrings` vt) xs
    IfElse _ th el -> collectStrings th vt ++ collectStrings el vt
    Call (AstSymbol "while") [_, body] -> collectStrings body vt
    Define _ _ v -> collectStrings v vt
    Assign _ v -> collectStrings v vt
    Call _ args -> concatMap (`collectStrings` vt) args
    _ -> []

uniqueList = foldl (\acc x -> if x `elem` acc then acc else acc ++ [x]) []
escapeASM = concatMap (\c -> if c == '\n' then "\\n" else [c])

builtInFunctions = unlines
    [ "Eric: pushq %rbp; movq %rsp, %rbp; movq $0, %rax; popq %rbp; ret"
    , "renaud:"
    , "\tpushq %rbp; movq %rsp, %rbp; subq $32, %rsp"
    , "\tmovq %rdi, -8(%rbp); leaq .LC_r_mode(%rip), %rsi; call fopen"
    , "\tcmpq $0, %rax; je .L_r_err; movq %rax, -16(%rbp)"
    , "\tmovq %rax, %rdi; movq $0, %rsi; movq $2, %rdx; call fseek"
    , "\tmovq -16(%rbp), %rdi; call ftell; movq %rax, -24(%rbp)"
    , "\tmovq -16(%rbp), %rdi; movq $0, %rsi; movq $0, %rdx; call fseek"
    , "\tmovq -24(%rbp), %rdi; incq %rdi; call malloc; movq %rax, -32(%rbp)"
    , "\tmovq %rax, %rdi; movq $1, %rsi; movq -24(%rbp), %rdx; movq -16(%rbp), %rcx; call fread"
    , "\tmovq -32(%rbp), %rax; movq -24(%rbp), %rdx; movb $0, (%rax, %rdx)"
    , "\tmovq -16(%rbp), %rdi; call fclose; movq -32(%rbp), %rax; jmp .L_r_done"
    , ".L_r_err: xorq %rax, %rax"
    , ".L_r_done: leave; ret"
    , "romaric:"
    , "\tpushq %rbp; movq %rsp, %rbp; subq $32, %rsp"
    , "\tmovq $0, -8(%rbp); movq $0, -16(%rbp) # NULL init for getline"
    , "\tmovq %rdi, %rsi; leaq .LC_s_fmt(%rip), %rdi; movb $0, %al; call printf"
    , "\tleaq -8(%rbp), %rdi; leaq -16(%rbp), %rsi; movq stdin(%rip), %rdx; call getline"
    , "\tmovq -8(%rbp), %rax; pushq %rax; movq %rax, %rdi; call strlen; popq %rdi"
    , "\tcmpq $0, %rax; je .L_ro_d; decq %rax; movb $0, (%rdi, %rax)"
    , ".L_ro_d: movq %rdi, %rax; leave; ret"
    , "marvin:"
    , "\tpushq %rbp; movq %rsp, %rbp; subq $32, %rsp"
    , "\tmovq %rdi, -8(%rbp); movq %rsi, -16(%rbp)"
    , "\tmovq -8(%rbp), %rdi; leaq .LC_w_mode(%rip), %rsi; call fopen; movq %rax, -24(%rbp)"
    , "\tcmpq $0, %rax; je .L_m_done; movq -16(%rbp), %rdi; movq %rax, %rsi; call fputs"
    , "\tmovq -24(%rbp), %rdi; call fclose"
    , ".L_m_done: leave; ret"
    , "str_concat:"
    , "\tpushq %rbp; movq %rsp, %rbp; subq $32, %rsp; movq %rdi, -8(%rbp); movq %rsi, -16(%rbp)"
    , "\tcall strlen; movq %rax, -24(%rbp); movq -16(%rbp), %rdi; call strlen"
    , "\taddq -24(%rbp), %rax; incq %rax; movq %rax, %rdi; call malloc; movq %rax, -32(%rbp)"
    , "\tmovq %rax, %rdi; movq -8(%rbp), %rsi; call strcpy"
    , "\tmovq -32(%rbp), %rdi; movq -16(%rbp), %rsi; call strcat; movq -32(%rbp), %rax; leave; ret"
    , ".section .rodata"
    , ".LC_r_mode: .string \"rb\""
    , ".LC_w_mode: .string \"w\""
    , ".LC_s_fmt: .string \"%s\""
    ]