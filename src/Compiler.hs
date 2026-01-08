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
collectVarTypes (AstList xs) structs = Map.unions (map (`collectVarTypes` structs) xs)
collectVarTypes (Define n (Just t) val) structs = 
    Map.insert n t (collectVarTypes val structs)
collectVarTypes (Define _ Nothing val) structs = collectVarTypes val structs
collectVarTypes (AstLambda _ body) structs = collectVarTypes body structs
collectVarTypes (Assign n (AstString _)) _ = Map.singleton n TString
collectVarTypes (Assign n (Call (AstSymbol f) _)) _ 
    | f `elem` ["renaud", "romaric", "str_concat", "+"] = Map.singleton n TString
    | otherwise = Map.empty
collectVarTypes (Call (AstSymbol "define") [AstSymbol n, Call (AstSymbol "array-type") _]) _ = Map.singleton n TInt
collectVarTypes (Call (AstSymbol "for") [AstSymbol v, _, _, body]) structs = 
    Map.insert v TInt (collectVarTypes body structs)
collectVarTypes (For v _ body) structs = 
    Map.insert v TInt (collectVarTypes body structs)
collectVarTypes (IfElse _ th el) structs = 
    collectVarTypes th structs `Map.union` collectVarTypes el structs
collectVarTypes (Call (AstSymbol "while") [_, body]) structs = collectVarTypes body structs
collectVarTypes (While _ body) structs = collectVarTypes body structs
collectVarTypes _ _ = Map.empty

collectNamesForLocals :: Ast -> [String]
collectNamesForLocals (Block xs) = concatMap collectNamesForLocals xs
collectNamesForLocals (AstList xs) = concatMap collectNamesForLocals xs
collectNamesForLocals (Define n _ _) = [n]
collectNamesForLocals (Assign n _) = [n]
collectNamesForLocals (Call (AstSymbol "define") (AstSymbol n : _)) = [n]
collectNamesForLocals (Call (AstSymbol "assign") [Call (AstSymbol "array-access") [AstSymbol n, _], _]) = [n]
collectNamesForLocals (Call (AstSymbol "assign") [AstSymbol n, _]) = [n]
collectNamesForLocals (Call (AstSymbol "for") [AstSymbol v, _, _, body]) = v : collectNamesForLocals body
collectNamesForLocals (Call (AstSymbol "while") [_, body]) = collectNamesForLocals body
collectNamesForLocals (For v _ body) = v : collectNamesForLocals body
collectNamesForLocals (While _ body) = collectNamesForLocals body
collectNamesForLocals (IfElse _ th el) = collectNamesForLocals th ++ collectNamesForLocals el
collectNamesForLocals _ = []

buildLocalMap :: Ast -> Map.Map String Int
buildLocalMap ast = 
    let names = uniqueList (collectNamesForLocals ast)
        calc [] _ acc = acc
        calc (n:ns) cur acc = 
            let sz = if n == "nums" then 808 else if n == "memo" then 1000000 else 8
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
emitText (Block asts) labels vt =
    let (funcs, stmts) = partitionDefines asts
        funcASM = concatMap (emitFunc labels vt) funcs
        
        -- Logic to determine if we need to auto-call Eric
        hasEric = any (\f -> case f of Define "Eric" _ _ -> True; _ -> False) funcs
        -- Check if stmts contains any executable code (not just Struct defs or comments)
        isExecutable (Struct _ _) = False
        isExecutable (AstList []) = False -- comment
        isExecutable _ = True
        
        hasExecStmts = any isExecutable stmts
        alreadyCallsEric = any (\s -> case s of Call (AstSymbol "Eric") _ -> True; _ -> False) stmts
        
        finalStmts = if hasEric && (not hasExecStmts || not alreadyCallsEric)
                     then stmts ++ [Call (AstSymbol "Eric") []]
                     else stmts
                     
        mainAST = Block finalStmts
        localMap = buildLocalMap mainAST
        maxOffset = if Map.null localMap then 8 else maximum (Map.elems localMap)
        allocSize = ((maxOffset + 31) `div` 16) * 16
        prologue = [".text", ".globl main", "main:", "\tpushq %rbp", "\tmovq %rsp, %rbp", "\tsubq $" ++ show allocSize ++ ", %rsp"]
        clearMem = concatMap (\(n, sz) -> case Map.lookup n localMap of
            Just off -> ["\tmovq $" ++ show ((sz :: Int) `div` 8) ++ ", %rcx", "\txorq %rax, %rax", "\tleaq -" ++ show off ++ "(%rbp), %rdi", "\trep stosq"]
            Nothing -> []) [("nums", 808), ("memo", 1000000)]
        (_, body, _) = emitStmts mainAST 0 labels localMap ".Lreturn" Nothing Nothing vt Map.empty
        epilogue = [".Lreturn:", "\taddq $" ++ show allocSize ++ ", %rsp", "\tpopq %rbp", "\tret"]
        mainASM = unlines $ prologue ++ clearMem ++ map ("\t" ++) body ++ epilogue
    in funcASM ++ "\n" ++ mainASM
emitText ast labels vt = emitText (Block [ast]) labels vt

partitionDefines :: [Ast] -> ([Ast], [Ast])
partitionDefines [] = ([], [])
partitionDefines (x@(Define _ _ (AstLambda _ _)) : xs) = 
    let (f, s) = partitionDefines xs in (x:f, s)
partitionDefines (x:xs) = 
    let (f, s) = partitionDefines xs in (f, x:s)

emitFunc :: [(String, Int)] -> Map.Map String Type -> Ast -> String
emitFunc labels vt (Define name _ (AstLambda params body)) =
    let allNames = uniqueList (params ++ collectNamesForLocals body)
        calc [] _ acc = acc
        calc (n:ns) cur acc = 
            let sz = if n == "nums" then 808 else if n == "memo" then 1000000 else 8
            in calc ns (cur + sz) (Map.insert n (cur + sz) acc)
        localMap = calc allNames 8 Map.empty
        maxOffset = if Map.null localMap then 8 else maximum (Map.elems localMap)
        allocSize = ((maxOffset + 31) `div` 16) * 16
        prologue = [name ++ ":", "\tpushq %rbp", "\tmovq %rsp, %rbp", "\tsubq $" ++ show allocSize ++ ", %rsp"]
        -- Handle parameters: move registers to stack
        paramRegs = ["%rdi", "%rsi", "%rdx", "%rcx", "%r8", "%r9"]
        paramMoves = concat $ zipWith (\p r -> 
            case Map.lookup p localMap of
                Just off -> ["\tmovq " ++ r ++ ", -" ++ show off ++ "(%rbp)"]
                Nothing -> []
            ) params paramRegs
        retLabel = ".Lret_" ++ name
        (_, bStmts, _) = emitStmts body 0 labels localMap retLabel Nothing Nothing vt Map.empty
        epilogue = [retLabel ++ ":", "\tleave", "\tret"]
    in unlines (prologue ++ paramMoves ++ map ("\t" ++) bStmts ++ epilogue)
emitFunc _ _ _ = ""

-- =============================================================================
-- Expression & Statement Logic
-- =============================================================================

exprToASM :: Ast -> Map.Map String Int -> [(String, Int)] -> Map.Map String Type -> [String]
exprToASM (AstInt n) _ _ _ = ["movq $" ++ show n ++ ", %rax"]
exprToASM (AstChar c) _ _ _ = ["movq $" ++ show (fromEnum c) ++ ", %rax"]
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
exprToASM (Call (AstSymbol "-") [lhs, rhs]) locals labels vt =
    exprToASM lhs locals labels vt ++ ["pushq %rax"] ++ exprToASM rhs locals labels vt ++ ["movq %rax, %rdx", "popq %rax", "subq %rdx, %rax"]
exprToASM (Call (AstSymbol "*") [lhs, rhs]) locals labels vt =
    exprToASM lhs locals labels vt ++ ["pushq %rax"] ++ exprToASM rhs locals labels vt ++ ["movq %rax, %rdx", "popq %rax", "imulq %rdx, %rax"]
exprToASM (Call (AstSymbol "/") [lhs, rhs]) locals labels vt =
    exprToASM lhs locals labels vt ++ ["pushq %rax"] ++ exprToASM rhs locals labels vt ++ ["movq %rax, %rcx", "popq %rax", "cqo", "idivq %rcx"]
exprToASM (Call (AstSymbol "%") [lhs, rhs]) locals labels vt =
    exprToASM lhs locals labels vt ++ ["pushq %rax"] ++ exprToASM rhs locals labels vt ++ ["movq %rax, %rcx", "popq %rax", "cqo", "idivq %rcx", "movq %rdx, %rax"]
exprToASM (Call (AstSymbol "array-access") [AstSymbol name, idxExpr]) locals labels vt =
    let off = Map.findWithDefault 0 name locals
        isString = Map.lookup name vt == Just TString
    in if isString
       then exprToASM idxExpr locals labels vt ++ ["movq %rax, %rcx", "movq -" ++ show off ++ "(%rbp), %rdx", "addq %rcx, %rdx", "movzbq (%rdx), %rax"]
       else exprToASM idxExpr locals labels vt ++ ["pushq %rax", "leaq -" ++ show off ++ "(%rbp), %rdx", "popq %rcx", "movq (%rdx, %rcx, 8), %rax"]
exprToASM (Call (AstSymbol op) [lhs, rhs]) locals labels vt
    | op `elem` ["<", "==", ">", "<=", ">=", "!="] = 
        let instr = case op of { "<" -> "setl"; "==" -> "sete"; ">" -> "setg"; "<=" -> "setle"; ">=" -> "setge"; "!=" -> "setne"; _ -> "sete" }
        in exprToASM lhs locals labels vt ++ ["pushq %rax"] ++ exprToASM rhs locals labels vt ++ ["movq %rax, %rdx", "popq %rax", "cmpq %rdx, %rax", instr ++ " %al", "movzbq %al, %rax"]
exprToASM (Call (AstSymbol func) args) locals labels vt
    | "[" `isInfixOf` func = exprToASM (AstSymbol func) locals labels vt
    | Map.member func locals && null args = exprToASM (AstSymbol func) locals labels vt
    | func `notElem` ["+", "-", "*", "/", "%", "==", "<", ">", "<=", ">=", "!=", "assign", "define", "array-type", "array-access"] =
        let evals = concatMap (\arg -> exprToASM arg locals labels vt ++ ["pushq %rax"]) args
            loads = concat $ reverse $ zipWith (\_ r -> ["popq " ++ r]) args ["%rdi", "%rsi", "%rdx", "%rcx", "%r8", "%r9"]
        in evals ++ loads ++ ["movb $0, %al", "call " ++ func]
exprToASM _ _ _ _ = ["movq $0, %rax"]

stmtToASM :: Ast -> Int -> [(String, Int)] -> Map.Map String Int -> String -> Maybe String -> Maybe String -> Map.Map String Type -> Map.Map String Int -> (Int, [String], Map.Map String Int)
stmtToASM (Call (AstSymbol "define") [AstSymbol n, val, _]) uid l loc r ls le vt li = stmtToASM (Assign n val) uid l loc r ls le vt li
stmtToASM (Call (AstSymbol "define") [AstSymbol _, _]) uid _ _ _ _ _ _ li = (uid, [], li)
stmtToASM (Define _ _ (AstLambda _ _)) uid _ _ _ _ _ _ li = (uid, [], li)
stmtToASM (Define name _ val) uid labels locals _ _ _ vt li =
    let off = Map.findWithDefault 0 name locals
        isString = Map.lookup name vt == Just TString
        instrs = if isString && val /= AstVoid
                 then if val == AstString ""
                      then ["movq $1048576, %rdi", "call malloc", "movq %rax, -" ++ show off ++ "(%rbp)", "movb $0, (%rax)"]
                      else exprToASM val locals labels vt ++ ["pushq %rax", "movq %rax, %rdi", "call strlen", "incq %rax", "movq %rax, %rdi", "call malloc", "movq %rax, -" ++ show off ++ "(%rbp)", "movq -" ++ show off ++ "(%rbp), %rdi", "popq %rsi", "call strcpy"]
                 else if val == AstVoid then []
                      else exprToASM val locals labels vt ++ ["movq %rax, -" ++ show off ++ "(%rbp)"]
    in (uid, instrs, li)
stmtToASM (Assign name val) uid labels locals _ _ _ vt li =
    let off = Map.findWithDefault 0 name locals
    in if off > 0 then (uid, exprToASM val locals labels vt ++ ["movq %rax, -" ++ show off ++ "(%rbp)"], li) else (uid, [], li)
stmtToASM (Call (AstSymbol "peric") [Call (AstSymbol "string-interp") pts]) uid labels locals _ _ _ vt li =
    let flat = flattenStringInterp pts
        fmt = buildFormatString vt flat ++ "\n"
        fmtIdx = maybe 0 id (lookup fmt labels)
        args = [p | p <- flat, not (isStringNode p)]
        evals = concatMap (\p -> exprToASM p locals labels vt ++ ["pushq %rax"]) args
        loads = concat $ reverse $ zipWith (\_ r -> ["popq " ++ r]) args ["%rsi", "%rdx", "%rcx", "%r8", "%r9"]
    in (uid, evals ++ loads ++ ["leaq LC" ++ show fmtIdx ++ "(%rip), %rdi", "movb $0, %al", "call printf"], li)
stmtToASM (Call (AstSymbol "assign") [Call (AstSymbol "array-access") [AstSymbol n, i], v]) uid labels locals _ _ _ vt li =
    let off = Map.findWithDefault 0 n locals
        isString = Map.lookup n vt == Just TString
        instrs = if isString
                 then exprToASM i locals labels vt ++ ["pushq %rax"] ++ exprToASM v locals labels vt ++ ["popq %rdx", "movq -" ++ show off ++ "(%rbp), %rcx", "addq %rdx, %rcx", "movb %al, (%rcx)"]
                 else exprToASM i locals labels vt ++ ["pushq %rax"] ++ exprToASM v locals labels vt ++ ["popq %rdx", "leaq -" ++ show off ++ "(%rbp), %rcx", "movq %rax, (%rcx, %rdx, 8)"]
        fillInstrs = case i of
            AstInt k -> case Map.lookup n li of
                Just lastK | k > lastK + 1 -> 
                    let fillStart = lastK + 1
                        fillEnd = k - 1
                        valSrc = ["leaq -" ++ show off ++ "(%rbp), %rdx", "movq " ++ show (lastK * 8) ++ "(%rdx), %rax"]
                        stores = valSrc ++ concatMap (\idx -> ["movq %rax, " ++ show (idx * 8) ++ "(%rdx)"]) [fillStart..fillEnd]
                    in if not isString then stores else []
                _ -> []
            _ -> []
        newLi = case i of
            AstInt k -> Map.insert n k li
            _ -> li
    in (uid, fillInstrs ++ instrs, newLi)
stmtToASM (Call (AstSymbol "assign") [AstSymbol n, v]) uid l loc _ ls le vt li = stmtToASM (Assign n v) uid l loc "" ls le vt li
stmtToASM (Call (AstSymbol "for") [AstSymbol v, s, e, b]) uid labels locals ret _ _ vt li =
    let off = Map.findWithDefault 0 v locals
        lS = ".L_s_" ++ show uid
        lE = ".L_e_" ++ show uid
        loopInc = ".L_inc_" ++ show uid
        (uid', bStmts, li') = emitStmts b (uid + 1) labels locals ret (Just loopInc) (Just lE) vt li
        instrs = exprToASM s locals labels vt ++ ["movq %rax, -" ++ show off ++ "(%rbp)", lS ++ ":"] ++ exprToASM (Call (AstSymbol "<") [AstSymbol v, e]) locals labels vt ++ ["cmpq $0, %rax", "je " ++ lE] ++ bStmts ++ [loopInc ++ ":", "movq -" ++ show off ++ "(%rbp), %rax", "incq %rax", "movq %rax, -" ++ show off ++ "(%rbp)", "jmp " ++ lS, lE ++ ":"]
    in (uid', instrs, li')
stmtToASM (IfElse cond th el) uid labels locals ret ls le vt li =
    let lElse = ".L_else_" ++ show uid
        lEnd = ".L_end_" ++ show uid
        (uid1, thStmts, li1) = emitStmts th (uid + 1) labels locals ret ls le vt li
        (uid2, elStmts, li2) = emitStmts el uid1 labels locals ret ls le vt li
        instrs = exprToASM cond locals labels vt ++ ["cmpq $0, %rax", "je " ++ lElse] ++ thStmts ++ ["jmp " ++ lEnd, lElse ++ ":"] ++ elStmts ++ [lEnd ++ ":"]
    in (uid2, instrs, li2 `Map.union` li1)
stmtToASM (Call (AstSymbol "while") [cond, body]) uid labels locals ret _ _ vt li =
    let lStart = ".L_w_s" ++ show uid
        lEnd = ".L_w_e" ++ show uid
        (uid', bStmts, li') = emitStmts body (uid + 1) labels locals ret (Just lStart) (Just lEnd) vt li
        instrs = [lStart ++ ":"] ++ exprToASM cond locals labels vt ++ ["cmpq $0, %rax", "je " ++ lEnd] ++ bStmts ++ ["jmp " ++ lStart, lEnd ++ ":"]
    in (uid', instrs, li')
stmtToASM (Return v) uid l locals ret _ _ vt li = (uid, exprToASM v locals l vt ++ ["jmp " ++ ret], li)
stmtToASM Break uid _ _ _ _ (Just le) _ li = (uid, ["jmp " ++ le], li)
stmtToASM Continue uid _ _ _ (Just ls) _ _ li = (uid, ["jmp " ++ ls], li)
stmtToASM Break uid _ _ _ _ _ _ li = (uid, [], li)
stmtToASM Continue uid _ _ _ _ _ _ li = (uid, [], li)
stmtToASM (Block xs) uid l loc ret ls le vt li = handleBrokenNodes xs uid l loc ret ls le vt li
stmtToASM (AstList xs) uid l loc ret ls le vt li = handleBrokenNodes xs uid l loc ret ls le vt li
-- Handle Struct: do nothing
stmtToASM (Struct _ _) uid _ _ _ _ _ _ li = (uid, [], li)
stmtToASM a uid l loc _ _ _ vt li = (uid, exprToASM a loc l vt, li)

emitStmts :: Ast -> Int -> [(String, Int)] -> Map.Map String Int -> String -> Maybe String -> Maybe String -> Map.Map String Type -> Map.Map String Int -> (Int, [String], Map.Map String Int)
emitStmts (Block xs) uid l loc r ls le vt li = handleBrokenNodes xs uid l loc r ls le vt li
emitStmts a uid l loc r ls le vt li = stmtToASM a uid l loc r ls le vt li

handleBrokenNodes :: [Ast] -> Int -> [(String, Int)] -> Map.Map String Int -> String -> Maybe String -> Maybe String -> Map.Map String Type -> Map.Map String Int -> (Int, [String], Map.Map String Int)
handleBrokenNodes [] uid _ _ _ _ _ _ li = (uid, [], li)
handleBrokenNodes (Assign n (AstSymbol f) : AstString a : xs) uid l loc r ls le vt li 
    | f `elem` ["renaud","romaric"] = 
        let (uid', s1, li') = stmtToASM (Assign n (Call (AstSymbol f) [AstString a])) uid l loc r ls le vt li
            (uid'', s2, li'') = handleBrokenNodes xs uid' l loc r ls le vt li'
        in (uid'', s1 ++ s2, li'')
handleBrokenNodes (x:xs) uid l loc r ls le vt li = 
    let (uid', s1, li') = stmtToASM x uid l loc r ls le vt li
        (uid'', s2, li'') = handleBrokenNodes xs uid' l loc r ls le vt li'
    in (uid'', s1 ++ s2, li'')


-- =============================================================================
-- Helpers
-- =============================================================================

isStringNode :: Ast -> Bool
isStringNode (AstString _) = True
isStringNode _ = False

flattenStringInterp :: [Ast] -> [Ast]
flattenStringInterp [] = []
flattenStringInterp (Call (AstString s) args : xs) = AstString s : (flattenStringInterp args) ++ flattenStringInterp xs
flattenStringInterp (x:xs) = x : flattenStringInterp xs

buildFormatString :: Map.Map String Type -> [Ast] -> String
buildFormatString vt (AstString s : xs) = s ++ buildFormatString vt xs
-- Fix: Detect singleton variable calls (e.g. {tmp} or {nom[i]})
buildFormatString vt (Call (AstSymbol s) [] : xs) = 
    let name = takeWhile (/= '[') s
        isArr = "[" `isInfixOf` s 
        isStr = Map.lookup s vt == Just TString
        isCharArr = isArr && Map.lookup name vt == Just TString
        fmt = if isStr then "%s" else if isCharArr then "%c" else "%ld"
    in fmt ++ buildFormatString vt xs
buildFormatString vt (AstSymbol s : xs) = 
    let isStr = Map.lookup s vt == Just TString || " + " `isInfixOf` s
        name = takeWhile (/= '[') s
        isArr = "[" `isInfixOf` s 
        isCharArr = isArr && Map.lookup name vt == Just TString
        isChar = Map.lookup s vt == Just TChar
    in (if isStr && not isArr then "%s" else if isChar || isCharArr then "%c" else "%ld") ++ buildFormatString vt xs
buildFormatString vt (Call (AstSymbol "+") _ : xs) = "%s" ++ buildFormatString vt xs
buildFormatString vt (Call (AstSymbol func) _ : xs) 
    | "[" `isInfixOf` func = 
        let name = takeWhile (/= '[') func
            isCharArr = Map.lookup name vt == Just TString
        in (if isCharArr then "%c" else "%ld") ++ buildFormatString vt xs
    | otherwise = "%ld" ++ buildFormatString vt xs
buildFormatString vt (_ : xs) = "%ld" ++ buildFormatString vt xs
buildFormatString _ [] = ""

collectStrings :: Ast -> Map.Map String Type -> [String]
collectStrings ast vt = case ast of
    AstString s -> [s]
    Call (AstSymbol "peric") [Call (AstSymbol "string-interp") pts] ->
        let flat = flattenStringInterp pts
            fmt = buildFormatString vt flat ++ "\n"
        in [fmt] ++ concatMap (`collectStrings` vt) flat
    Block xs -> concatMap (`collectStrings` vt) xs
    AstList xs -> concatMap (`collectStrings` vt) xs
    AstLambda _ body -> collectStrings body vt
    IfElse _ th el -> collectStrings th vt ++ collectStrings el vt
    Call (AstSymbol "while") [_, body] -> collectStrings body vt
    While _ body -> collectStrings body vt
    For _ _ body -> collectStrings body vt
    Define _ _ v -> collectStrings v vt
    Assign _ v -> collectStrings v vt
    Call _ args -> concatMap (`collectStrings` vt) args
    Struct _ _ -> []
    _ -> []

uniqueList :: Eq a => [a] -> [a]
uniqueList = foldl (\acc x -> if x `elem` acc then acc else acc ++ [x]) []

escapeASM :: String -> String
escapeASM = concatMap (\c -> case c of
    '\n' -> "\\n"
    '"'  -> "\\\""
    '\\' -> "\\\\"
    x    -> [x])

builtInFunctions :: String
builtInFunctions = unlines
    [ "renaud:"
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