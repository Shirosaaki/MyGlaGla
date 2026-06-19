module Compiler (compileModuleLLVM, compileToLL, compileToObject, compileToBytecodeFile) where

import AST (Ast(..), Type(..))
import qualified Data.Map.Strict as Map
import Data.List (isInfixOf)
import qualified Data.Set as Set
import System.Process (callCommand)
import System.IO ()
import Control.Exception (catch, SomeException(..), displayException)
import System.Exit (exitFailure)
import qualified Control.Exception as E
import UI (printError)
import System.IO.Unsafe (unsafePerformIO)
import Bytecode (Instruction(..))
import qualified Bytecode as BC
import Loader (saveBytecodeFile)
import Data.Word (Word64)
import Foreign.Ptr (castPtr)
import Foreign.Marshal.Array (allocaArray)
import Foreign.Storable (poke, peek)

-- =============================================================================
-- Configuration
-- =============================================================================

builtIns :: [String]
builtIns = ["renaud", "romaric", "marvin", "str_concat", "+", "-", "*", "/", "%", "==", "<", ">", "<=", ">=", "!=", "&&", "||", "assign", "define", "array-type", "array-access", "array-decl", "string-interp", "for", "field-load", "field-store"]

floatToBits :: Double -> IO Word64
floatToBits d = allocaArray 1 $ \ptr -> do
    poke (castPtr ptr) d
    peek ptr

-- =============================================================================
-- LLVM / Assembly Output
-- =============================================================================

compileModuleLLVM :: Ast -> String
compileModuleLLVM ast = emitASM ast

compileToLL :: FilePath -> Ast -> IO ()
compileToLL outputPath ast = do
    let asmCode = emitASM ast
    writeFile outputPath asmCode
    putStrLn $ "Assembly code written to: " ++ outputPath

-- =============================================================================
-- Analysis & Memory Mapping
-- =============================================================================

collectVarTypes :: Ast -> Map.Map String Type -> Map.Map String Type
collectVarTypes (ClassDef _ fields mCtor methods) structs =
    Map.unions $
        map (\(_,v,_) -> collectVarTypes v structs) fields
        ++ (case mCtor of { Nothing -> []; Just (_,_,b) -> [collectVarTypes b structs] })
        ++ map (\(_,_,b) -> collectVarTypes b structs) methods
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
collectVarTypes (Call (AstSymbol "define") [AstSymbol n, Call (AstSymbol "array-type") _]) _ = 
    Map.singleton n (TCustom "int[]")
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

collectFunctionNames :: Ast -> [String]
collectFunctionNames (Block xs) = concatMap collectFunctionNames xs
collectFunctionNames (AstList xs) = concatMap collectFunctionNames xs
collectFunctionNames (Define n _ (AstLambda _ _)) = [n]
collectFunctionNames (ClassDef cn _ _ methods) =
    (cn ++ "_new") : map (\(n,_,_) -> cn ++ "_" ++ n) methods
collectFunctionNames _ = []

buildLocalMap :: Ast -> Map.Map String Type -> Map.Map String Int
buildLocalMap ast vt = 
    let names = uniqueList (collectNamesForLocals ast)
        calc [] _ acc = acc
        calc (n:ns) cur acc = 
            let isArray = Map.lookup n vt == Just (TCustom "int[]")
                sz = if n == "memo" then 1000000 
                     else if isArray then 4096 
                     else 8
            in calc ns (cur + sz) (Map.insert n (cur + sz) acc)
    in calc names 8 Map.empty

-- =============================================================================
-- ASM Emission
-- =============================================================================

compileToObject :: FilePath -> Ast -> IO ()
compileToObject out ast = catch (do
    let asm = emitASM ast
        asmFile = "/tmp/glados_emit.s"
    _ <- E.evaluate (length asm)
    writeFile asmFile asm
    _ <- callCommand ("as -o " ++ out ++ " " ++ asmFile)
    return ()) handler
  where
    handler :: SomeException -> IO ()
    handler e = do
        putStrLn $ "Compilation Error: " ++ displayException e
        exitFailure

emitASM :: Ast -> String
emitASM ast =
    let ast' = ast
        varTypes = collectVarTypes ast' Map.empty
        funcNames = collectFunctionNames ast'
        strs = uniqueList (collectStrings ast' varTypes)
        labels = zip strs [0..]
    in concatMap (emitData) labels ++ "\n" ++ emitText ast' labels varTypes funcNames ++ "\n" ++ builtInFunctions

emitData :: (String, Int) -> String
emitData (s, i) = ".globl LC" ++ show i ++ "\nLC" ++ show i ++ ": .string \"" ++ escapeASM s ++ "\"\n"

emitText :: Ast -> [(String, Int)] -> Map.Map String Type -> [String] -> String
emitText (Block asts) labels globalVt funcNames =
    let (funcs, stmts) = partitionDefines asts
        funcASM = concatMap (emitFunc labels globalVt funcNames) funcs
        
        hasEric = any (\f -> case f of Define "Eric" _ _ -> True; _ -> False) funcs
        isExecutable (Struct _ _) = False
        isExecutable (AstList []) = False
        isExecutable _ = True
        
        hasExecStmts = any isExecutable stmts
        alreadyCallsEric = any (\s -> case s of Call (AstSymbol "Eric") _ -> True; _ -> False) stmts
        
        finalStmts = if hasEric && (not hasExecStmts || not alreadyCallsEric)
                     then stmts ++ [Call (AstSymbol "Eric") []]
                     else stmts
                     
        mainAST = Block finalStmts
        localVt = collectVarTypes mainAST globalVt
        localMap = buildLocalMap mainAST localVt
        
        maxOffset = if Map.null localMap then 8 else maximum (Map.elems localMap)
        allocSize = ((maxOffset + 31) `div` 16) * 16
        prologue = [".text", ".globl main", "main:", "\tpushq %rbp", "\tmovq %rsp, %rbp", "\tsubq $" ++ show allocSize ++ ", %rsp"]
        
        clearMem = concatMap (\(n, off) -> 
            let isArray = Map.lookup n localVt == Just (TCustom "int[]")
                sz = if n == "memo" then (1000000 :: Integer)
                     else if isArray then 4096 
                     else 0
            in if sz > 0
               then ["\tmovq $" ++ show (sz `div` 8) ++ ", %rcx", "\txorq %rax, %rax", "\tleaq -" ++ show off ++ "(%rbp), %rdi", "\trep stosq"]
               else []
            ) (Map.toList localMap)
            
        (_, body, _) = emitStmts mainAST 0 labels localMap ".Lreturn" Nothing Nothing localVt Map.empty funcNames
        epilogue = [".Lreturn:", "\taddq $" ++ show allocSize ++ ", %rsp", "\tpopq %rbp", "\tret"]
        mainASM = unlines $ prologue ++ clearMem ++ map ("\t" ++) body ++ epilogue
    in funcASM ++ "\n" ++ mainASM
emitText ast labels vt funcNames = emitText (Block [ast]) labels vt funcNames

partitionDefines :: [Ast] -> ([Ast], [Ast])
partitionDefines (x@(ClassDef _ _ _ _) : xs) =
    let (f, s) = partitionDefines xs in (x:f, s)
partitionDefines [] = ([], [])
partitionDefines (x@(Define _ _ (AstLambda _ _)) : xs) = 
    let (f, s) = partitionDefines xs in (x:f, s)
partitionDefines (x:xs) = 
    let (f, s) = partitionDefines xs in (f, x:s)

emitFunc :: [(String, Int)] -> Map.Map String Type -> [String] -> Ast -> String
emitFunc labels vt funcNames cd@(ClassDef _ _ _ _) =
    emitClass labels vt funcNames cd
emitFunc labels globalVt funcNames (Define name _ (AstLambda params body)) =
    let localVt = collectVarTypes body globalVt
        allNames = uniqueList (params ++ collectNamesForLocals body)
        
        calc [] _ acc = acc
        calc (n:ns) cur acc = 
            let isArray = Map.lookup n localVt == Just (TCustom "int[]")
                sz = if n == "memo" then 1000000 
                     else if isArray then 4096 
                     else 8
            in calc ns (cur + sz) (Map.insert n (cur + sz) acc)
            
        finalMap = calc allNames 8 Map.empty
        maxOffset = if Map.null finalMap then 8 else maximum (Map.elems finalMap)
        allocSize = ((maxOffset + 31) `div` 16) * 16
        prologue = [name ++ ":", "\tpushq %rbp", "\tmovq %rsp, %rbp", "\tsubq $" ++ show allocSize ++ ", %rsp"]
        
        clearMem = concatMap (\(n, off) -> 
            let isArray = Map.lookup n localVt == Just (TCustom "int[]")
                sz = if n == "memo" then (1000000 :: Integer)
                     else if isArray then 4096 
                     else 0
            in if sz > 0
               then ["\tmovq $" ++ show (sz `div` 8) ++ ", %rcx", "\txorq %rax, %rax", "\tleaq -" ++ show off ++ "(%rbp), %rdi", "\trep stosq"]
               else []
            ) (Map.toList finalMap)

        paramRegs = ["%rdi", "%rsi", "%rdx", "%rcx", "%r8", "%r9"]
        paramMoves = concat $ zipWith (\p r -> 
            case Map.lookup p finalMap of
                Just off -> ["\tmovq " ++ r ++ ", -" ++ show off ++ "(%rbp)"]
                Nothing -> []
            ) params paramRegs
            
        retLabel = ".Lret_" ++ name
        (_, bStmts, _) = emitStmts body 0 labels finalMap retLabel Nothing Nothing localVt Map.empty funcNames
        epilogue = [retLabel ++ ":", "\tleave", "\tret"]
    in unlines (prologue ++ clearMem ++ paramMoves ++ map ("\t" ++) bStmts ++ epilogue)
emitFunc _ _ _ _ = ""

-- =============================================================================
-- Expression & Statement Logic
-- =============================================================================

exprToASM :: Ast -> Map.Map String Int -> [(String, Int)] -> Map.Map String Type -> [String] -> [String]
exprToASM (Call (AstSymbol "field-load") [AstInt off]) _ _ _ _ =
    ["movq " ++ show off ++ "(%r15), %rax"]

exprToASM (Call (AstSymbol "field-store") [AstInt off, val]) locals labels vt fns =
    let instrs = exprToASM val locals labels vt fns
    in instrs ++ ["movq %rax, " ++ show off ++ "(%r15)"]

exprToASM (AstInt n) _ _ _ _ = ["movq $" ++ show n ++ ", %rax"]
exprToASM (AstChar c) _ _ _ _ = ["movq $" ++ show (fromEnum c) ++ ", %rax"]
exprToASM (AstFloat f) _ _ _ _ = 
    let bits = unsafePerformIO $ floatToBits f
    in ["movq $" ++ show bits ++ ", %rax"]

exprToASM (AstSymbol v) locals labels vt fns
    | " + " `isInfixOf` v = let p = words v in exprToASM (Call (AstSymbol "+") [AstSymbol (p!!0), AstSymbol (p!!2)]) locals labels vt fns
    | "[" `isInfixOf` v && last v == ']' = 
        let revV = reverse v
            dist = length $ takeWhile (/= '[') revV
            splitPos = length v - 1 - dist
            (base, rest) = splitAt splitPos v
            idxStr = init (drop 1 rest)
            isAllDigits s = not (null s) && all (\c -> c >= '0' && c <= '9') s
            idxAst = if isAllDigits idxStr then AstInt (read idxStr) else AstSymbol idxStr
        in exprToASM (Call (AstSymbol "array-access") [AstSymbol base, idxAst]) locals labels vt fns
    | otherwise = case Map.lookup v locals of
        Just off -> 
            case Map.lookup v vt of
                Just (TCustom "int[]") -> ["leaq -" ++ show off ++ "(%rbp), %rax"]
                _ -> ["movq -" ++ show off ++ "(%rbp), %rax"]
        Nothing  -> unsafePerformIO $ do
            printError ("Compilation Error: Undefined variable '" ++ v ++ "'")
            exitFailure

exprToASM (AstString s) _ labels _ _ = ["leaq LC" ++ show (maybe 0 id (lookup s labels)) ++ "(%rip), %rax"]

exprToASM (Call (AstSymbol "+") [lhs, rhs]) locals labels vt fns =
    let isStr a = case a of { AstString _ -> True; AstSymbol s -> Map.lookup s vt == Just TString; Call (AstSymbol f) _ -> f `elem` ["renaud","romaric","str_concat","+"]; _ -> False }
    in if isStr lhs || isStr rhs
       then exprToASM lhs locals labels vt fns ++ ["pushq %rax"] ++ exprToASM rhs locals labels vt fns ++ ["movq %rax, %rsi", "popq %rdi", "call str_concat"]
       else exprToASM lhs locals labels vt fns ++ ["pushq %rax"] ++ exprToASM rhs locals labels vt fns ++ ["movq %rax, %rdx", "popq %rax", "addq %rdx, %rax"]

exprToASM (Call (AstSymbol "-") [lhs, rhs]) locals labels vt fns =
    exprToASM lhs locals labels vt fns ++ ["pushq %rax"] ++ exprToASM rhs locals labels vt fns ++ ["movq %rax, %rdx", "popq %rax", "subq %rdx, %rax"]
exprToASM (Call (AstSymbol "*") [lhs, rhs]) locals labels vt fns =
    exprToASM lhs locals labels vt fns ++ ["pushq %rax"] ++ exprToASM rhs locals labels vt fns ++ ["movq %rax, %rdx", "popq %rax", "imulq %rdx, %rax"]
exprToASM (Call (AstSymbol "/") [lhs, rhs]) locals labels vt fns =
    exprToASM lhs locals labels vt fns ++ ["pushq %rax"] ++ exprToASM rhs locals labels vt fns ++ ["movq %rax, %rcx", "popq %rax", "cqo", "idivq %rcx"]
exprToASM (Call (AstSymbol "%") [lhs, rhs]) locals labels vt fns =
    exprToASM lhs locals labels vt fns ++ ["pushq %rax"] ++ exprToASM rhs locals labels vt fns ++ ["movq %rax, %rcx", "popq %rax", "cqo", "idivq %rcx", "movq %rdx, %rax"]

exprToASM (Call (AstSymbol "array-access") [baseExpr, idxExpr]) locals labels vt fns =
    case baseExpr of
        AstSymbol name | not ("[" `isInfixOf` name) ->
            let off = case Map.lookup name locals of
                        Just o -> o
                        Nothing -> unsafePerformIO $ do
                            printError ("Compilation Error: Undefined array '" ++ name ++ "'")
                            exitFailure
                isString = Map.lookup name vt == Just TString
                isArray = Map.lookup name vt == Just (TCustom "int[]")
            in if isString
               then exprToASM idxExpr locals labels vt fns ++ ["movq %rax, %rcx", "movq -" ++ show off ++ "(%rbp), %rdx", "addq %rcx, %rdx", "movzbq (%rdx), %rax"]
               else exprToASM idxExpr locals labels vt fns ++ ["pushq %rax"] ++ 
                    (if isArray then ["leaq -" ++ show off ++ "(%rbp), %rdx"] else ["movq -" ++ show off ++ "(%rbp), %rdx"]) ++
                    ["popq %rcx"] ++
                    ["movq (%rdx, %rcx, 8), %rax"]
        _ ->
            exprToASM baseExpr locals labels vt fns ++ 
            ["cmpq $0, %rax", "je 1f", "pushq %rax"] ++ 
            exprToASM idxExpr locals labels vt fns ++ 
            ["movq %rax, %rcx", "popq %rdx", "movq (%rdx, %rcx, 8), %rax", "jmp 2f", "1:", "movq $0, %rax", "2:"]

exprToASM (Call (AstSymbol "&&") [lhs, rhs]) locals labels vt fns =
    exprToASM lhs locals labels vt fns ++ ["pushq %rax"] ++
    exprToASM rhs locals labels vt fns ++ ["movq %rax, %rdx", "popq %rax", "andq %rdx, %rax"]

exprToASM (Call (AstSymbol "||") [lhs, rhs]) locals labels vt fns =
    exprToASM lhs locals labels vt fns ++ ["pushq %rax"] ++
    exprToASM rhs locals labels vt fns ++ ["movq %rax, %rdx", "popq %rax", "orq %rdx, %rax"]

exprToASM (Call (AstSymbol op) [lhs, rhs]) locals labels vt fns
    | op `elem` ["<", "==", ">", "<=", ">=", "!="] = 
        let isF a = case a of { AstFloat _ -> True; AstSymbol s -> Map.lookup s vt == Just TFloat; _ -> False }
            instrInt = case op of { "<" -> "setl"; "==" -> "sete"; ">" -> "setg"; "<=" -> "setle"; ">=" -> "setge"; "!=" -> "setne"; _ -> "sete" }
            instrFloat = case op of { "<" -> "setb"; "==" -> "sete"; ">" -> "seta"; "<=" -> "setbe"; ">=" -> "setae"; "!=" -> "setne"; _ -> "sete" }
        in if isF lhs || isF rhs
           then exprToASM lhs locals labels vt fns ++ ["pushq %rax"] ++ 
                exprToASM rhs locals labels vt fns ++ 
                [ "movq %rax, %xmm1", "popq %rdx", "movq %rdx, %xmm0" ] ++
                (if not (isF lhs) then ["cvtsi2sd %rdx, %xmm0"] else []) ++
                (if not (isF rhs) then ["cvtsi2sd %rax, %xmm1"] else []) ++
                [ "comisd %xmm1, %xmm0", instrFloat ++ " %al", "movzbq %al, %rax" ]
           else exprToASM lhs locals labels vt fns ++ ["pushq %rax"] ++ 
                exprToASM rhs locals labels vt fns ++ 
                ["movq %rax, %rdx", "popq %rax", "cmpq %rdx, %rax", instrInt ++ " %al", "movzbq %al, %rax"]

exprToASM (Call (AstSymbol func) args) locals labels vt fns
    | "[" `isInfixOf` func = exprToASM (AstSymbol func) locals labels vt fns
    | func == "array-type" = ["xorq %rax, %rax"]
    | Map.member func locals && null args = exprToASM (AstSymbol func) locals labels vt fns
    | func `notElem` builtIns =
        if func `notElem` fns
        then unsafePerformIO $ do
            printError ("Compilation Error: Undefined function '" ++ func ++ "'")
            exitFailure
        else
            let evals = concatMap (\arg -> exprToASM arg locals labels vt fns ++ ["pushq %rax"]) args
                loads = concat $ reverse $ zipWith (\_ r -> ["popq " ++ r]) args ["%rdi", "%rsi", "%rdx", "%rcx", "%r8", "%r9"]
            in evals ++ loads ++ ["movb $0, %al", "call " ++ func]
    | otherwise =
        let evals = concatMap (\arg -> exprToASM arg locals labels vt fns ++ ["pushq %rax"]) args
            loads = concat $ reverse $ zipWith (\_ r -> ["popq " ++ r]) args ["%rdi", "%rsi", "%rdx", "%rcx", "%r8", "%r9"]
        in evals ++ loads ++ ["movb $0, %al", "call " ++ func]

exprToASM _ _ _ _ _ = ["movq $0, %rax"]

stmtToASM :: Ast -> Int -> [(String, Int)] -> Map.Map String Int -> String -> Maybe String -> Maybe String -> Map.Map String Type -> Map.Map String Int -> [String] -> (Int, [String], Map.Map String Int)
stmtToASM (ClassDef _ _ _ _) uid _ _ _ _ _ _ li _ = (uid, [], li)

stmtToASM (Call (AstSymbol "field-store") [AstInt off, val]) uid labels locals _ _ _ vt li fns =
    let instrs = exprToASM val locals labels vt fns
              ++ ["movq %rax, " ++ show off ++ "(%r15)"]
    in (uid, instrs, li)

stmtToASM (Call (AstSymbol "define") [AstSymbol n, val, _]) uid l loc r ls le vt li fns = stmtToASM (Assign n val) uid l loc r ls le vt li fns
stmtToASM (Call (AstSymbol "define") [AstSymbol _, _]) uid _ _ _ _ _ _ li _ = (uid, [], li)
stmtToASM (Define _ _ (AstLambda _ _)) uid _ _ _ _ _ _ li _ = (uid, [], li)
stmtToASM (Define name _ val) uid labels locals _ _ _ vt li fns =
    let off = Map.findWithDefault 0 name locals
        isString = Map.lookup name vt == Just TString
        instrs = if isString && val /= AstVoid
                 then if val == AstString ""
                      then ["movq $1048576, %rdi", "call malloc", "movq %rax, -" ++ show off ++ "(%rbp)", "movb $0, (%rax)"]
                      else exprToASM val locals labels vt fns ++ ["pushq %rax", "movq %rax, %rdi", "call strlen", "incq %rax", "movq %rax, %rdi", "call malloc", "movq %rax, -" ++ show off ++ "(%rbp)", "movq -" ++ show off ++ "(%rbp), %rdi", "popq %rsi", "call strcpy"]
                 else if val == AstVoid then []
                      else exprToASM val locals labels vt fns ++ ["movq %rax, -" ++ show off ++ "(%rbp)"]
    in (uid, instrs, li)

stmtToASM (Assign name val) uid labels locals _ _ _ vt li fns =
    let off = case Map.lookup name locals of
                Just o -> o
                Nothing -> unsafePerformIO $ do
                    printError ("Compilation Error: Assignment to undefined variable '" ++ name ++ "'")
                    exitFailure
    in (uid, exprToASM val locals labels vt fns ++ ["movq %rax, -" ++ show off ++ "(%rbp)"], li)

stmtToASM (Call (AstSymbol "peric") [Call (AstSymbol "string-interp") pts]) uid labels locals _ _ _ vt li fns =
    let flat = flattenStringInterp pts
        fmt = buildFormatString vt flat ++ "\n"
        fmtIdx = maybe 0 id (lookup fmt labels)
        args = [p | p <- flat, not (isStringNode p)]
        evalArg = if null args then ["xorq %rax, %rax"] else exprToASM (head args) locals labels vt fns
        isFloat = case args of
            (AstSymbol s : _) -> Map.lookup s vt == Just TFloat
            (AstFloat _ : _)  -> True
            _                 -> False
        callPrintf = 
            [ "andq $-16, %rsp", "leaq LC" ++ show fmtIdx ++ "(%rip), %rdi" ]
            ++ (if isFloat then ["movq %rax, %xmm0", "movb $1, %al"] else ["movq %rax, %rsi", "movb $0, %al"])
            ++ ["call printf"]
    in (uid, evalArg ++ callPrintf, li)

stmtToASM (Call (AstSymbol "assign") [Call (AstSymbol "array-access") [baseExpr, i], v]) uid labels locals _ _ _ vt li fns
    | not (isSimpleSymbol baseExpr) =
    let key = getLiKey baseExpr
        fillInstrs = case (key, i) of
            (Just k, AstInt idx) -> case Map.lookup k li of
                Just lastK | idx > lastK + 1 -> 
                    let fillStart = lastK + 1
                        fillEnd = idx - 1
                        baseAsm = exprToASM baseExpr locals labels vt fns 
                        fillCode = baseAsm ++ ["pushq %rax", "movq " ++ show (lastK * 8) ++ "(%rax), %rax", "popq %rdx"] ++
                                   concatMap (\currIdx -> ["movq %rax, " ++ show (currIdx * 8) ++ "(%rdx)"]) [fillStart..fillEnd]
                    in fillCode
                _ -> []
            _ -> []
        newLi = case (key, i) of { (Just k, AstInt idx) -> Map.insert k idx li; _ -> li }
        instrs = exprToASM baseExpr locals labels vt fns ++ ["pushq %rax"] ++
                 exprToASM i locals labels vt fns ++ ["pushq %rax"] ++
                 exprToASM v locals labels vt fns ++ ["pushq %rax", "popq %rdx", "popq %r8", "popq %rcx", "movq %rdx, (%rcx, %r8, 8)"]
    in (uid, fillInstrs ++ instrs, newLi)
  where isSimpleSymbol (AstSymbol _) = True; isSimpleSymbol _ = False

stmtToASM (Call (AstSymbol "assign") [AstSymbol n, i, v]) uid labels locals _ _ _ vt li fns =
    let off = case Map.lookup n locals of { Just o -> o; Nothing -> 0 }
        instrs = exprToASM i locals labels vt fns ++ ["pushq %rax"] ++ 
                 exprToASM v locals labels vt fns ++ ["pushq %rax", "leaq -" ++ show off ++ "(%rbp), %rcx", "popq %rdx", "popq %r8", "movq %rdx, (%rcx, %r8, 8)"]
    in (uid, instrs, li)

stmtToASM (Call (AstSymbol "assign") [AstSymbol n, v]) uid l loc _ ls le vt li fns = stmtToASM (Assign n v) uid l loc "" ls le vt li fns
stmtToASM (AstSymbol "break") uid labels locals ret ls le vt li fns = stmtToASM Break uid labels locals ret ls le vt li fns
stmtToASM (AstSymbol "continue") uid labels locals ret ls le vt li fns = stmtToASM Continue uid labels locals ret ls le vt li fns

stmtToASM (Call (AstSymbol "for") [AstSymbol v, s, e, b]) uid labels locals ret _ _ vt li fns =
    let off = Map.findWithDefault 0 v locals
        lS = ".L_s_" ++ show uid
        lE = ".L_e_" ++ show uid
        loopInc = ".L_inc_" ++ show uid
        (uid', bStmts, li') = emitStmts b (uid + 1) labels locals ret (Just loopInc) (Just lE) vt li fns
        instrs = exprToASM s locals labels vt fns ++ ["movq %rax, -" ++ show off ++ "(%rbp)", lS ++ ":"] ++ 
                 exprToASM (Call (AstSymbol "<") [AstSymbol v, e]) locals labels vt fns ++ ["cmpq $0, %rax", "je " ++ lE] ++ 
                 bStmts ++ [loopInc ++ ":", "movq -" ++ show off ++ "(%rbp), %rax", "incq %rax", "movq %rax, -" ++ show off ++ "(%rbp)", "jmp " ++ lS, lE ++ ":"]
    in (uid', instrs, li')

stmtToASM (IfElse cond th el) uid labels locals ret ls le vt li fns =
    let lElse = ".L_else_" ++ show uid
        lEnd = ".L_end_" ++ show uid
        (uid1, thStmts, li1) = emitStmts th (uid + 1) labels locals ret ls le vt li fns
        (uid2, elStmts, li2) = emitStmts el uid1 labels locals ret ls le vt li fns
        instrs = exprToASM cond locals labels vt fns ++ ["cmpq $0, %rax", "je " ++ lElse] ++ 
                 thStmts ++ ["jmp " ++ lEnd, lElse ++ ":"] ++ elStmts ++ [lEnd ++ ":"]
    in (uid2, instrs, li2 `Map.union` li1)

stmtToASM (Call (AstSymbol "while") [cond, body]) uid labels locals ret _ _ vt li fns =
    let lStart = ".L_w_s" ++ show uid
        lEnd = ".L_w_e" ++ show uid
        (uid', bStmts, li') = emitStmts body (uid + 1) labels locals ret (Just lStart) (Just lEnd) vt li fns
        instrs = [lStart ++ ":"] ++ exprToASM cond locals labels vt fns ++ ["cmpq $0, %rax", "je " ++ lEnd] ++ 
                 bStmts ++ ["jmp " ++ lStart, lEnd ++ ":"]
    in (uid', instrs, li')

stmtToASM (Return v) uid l locals ret _ _ vt li fns = (uid, exprToASM v locals l vt fns ++ ["jmp " ++ ret], li)
stmtToASM Break uid _ _ _ _ (Just le) _ li _ = (uid, ["jmp " ++ le], li)
stmtToASM Continue uid _ _ _ (Just ls) _ _ li _ = (uid, ["jmp " ++ ls], li)
stmtToASM Break uid _ _ _ _ _ _ li _ = (uid, [], li)
stmtToASM Continue uid _ _ _ _ _ _ li _ = (uid, [], li)
stmtToASM (Block xs) uid l loc ret ls le vt li fns = handleBrokenNodes xs uid l loc ret ls le vt li fns
stmtToASM (AstList xs) uid l loc ret ls le vt li fns = handleBrokenNodes xs uid l loc ret ls le vt li fns
stmtToASM (Struct _ _) uid _ _ _ _ _ _ li _ = (uid, [], li)

stmtToASM (Call (AstSymbol "array-decl") [baseExpr, idxExpr, _]) uid labels locals _ _ _ vt li fns =
    let baseAsm = exprToASM baseExpr locals labels vt fns
        idxAsm  = exprToASM idxExpr locals labels vt fns
        alloc   = ["movq $512, %rdi", "movq $8, %rsi", "call calloc"]
        store   = ["movq %rax, (%rcx, %rdx, 8)"]
        instrs  = baseAsm ++ ["pushq %rax"] ++ idxAsm ++ ["movq %rax, %rdx", "popq %rcx", "pushq %rcx", "pushq %rdx"] ++ 
                  alloc ++ ["popq %rdx", "popq %rcx", store !! 0]
    in (uid, instrs, li)

stmtToASM a uid l loc _ _ _ vt li fns = (uid, exprToASM a loc l vt fns, li)

-- =============================================================================
-- Helpers
-- =============================================================================

emitStmts :: Ast -> Int -> [(String, Int)] -> Map.Map String Int -> String -> Maybe String -> Maybe String -> Map.Map String Type -> Map.Map String Int -> [String] -> (Int, [String], Map.Map String Int)
emitStmts (Block xs) uid l loc r ls le vt li fns = handleBrokenNodes xs uid l loc r ls le vt li fns
emitStmts a uid l loc r ls le vt li fns = stmtToASM a uid l loc r ls le vt li fns

handleBrokenNodes :: [Ast] -> Int -> [(String, Int)] -> Map.Map String Int -> String -> Maybe String -> Maybe String -> Map.Map String Type -> Map.Map String Int -> [String] -> (Int, [String], Map.Map String Int)
handleBrokenNodes [] uid _ _ _ _ _ _ li _ = (uid, [], li)
handleBrokenNodes (Assign n (AstSymbol f) : AstString a : xs) uid l loc r ls le vt li fns 
    | f `elem` ["renaud","romaric"] = 
        let (uid', s1, li') = stmtToASM (Assign n (Call (AstSymbol f) [AstString a])) uid l loc r ls le vt li fns
            (uid'', s2, li'') = handleBrokenNodes xs uid' l loc r ls le vt li' fns
        in (uid'', s1 ++ s2, li'')
handleBrokenNodes (x:xs) uid l loc r ls le vt li fns = 
    let (uid', s1, li') = stmtToASM x uid l loc r ls le vt li fns
        (uid'', s2, li'') = handleBrokenNodes xs uid' l loc r ls le vt li' fns
    in (uid'', s1 ++ s2, li'')

isStringNode :: Ast -> Bool
isStringNode (AstString _) = True
isStringNode _ = False

flattenStringInterp :: [Ast] -> [Ast]
flattenStringInterp [] = []
flattenStringInterp (Call (AstString s) args : xs) = AstString s : (flattenStringInterp args) ++ flattenStringInterp xs
flattenStringInterp (x:xs) = x : flattenStringInterp xs

buildFormatString :: Map.Map String Type -> [Ast] -> String
buildFormatString vt (AstString s : xs) = s ++ buildFormatString vt xs
buildFormatString vt (Call (AstSymbol s) [] : xs) = 
    let name = takeWhile (/= '[') s
        isArr = "[" `isInfixOf` s 
        isStr = Map.lookup s vt == Just TString
        isCharArr = isArr && Map.lookup name vt == Just TString
        fmt = if isStr then "%s" else if isCharArr then "%c" else "%ld"
    in fmt ++ buildFormatString vt xs
buildFormatString vt (AstSymbol s : xs) = 
    let isStr = Map.lookup s vt == Just TString || " + " `isInfixOf` s
        isFloat = Map.lookup s vt == Just TFloat
        fmt = if isStr then "%s" else if isFloat then "%.2f" else "%ld"
    in fmt ++ buildFormatString vt xs
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
collectStrings (ClassDef _ fields mCtor methods) vt =
    concatMap (\(_,v,_) -> collectStrings v vt) fields
    ++ (case mCtor of { Nothing -> []; Just (_,_,b) -> collectStrings b vt })
    ++ concatMap (\(_,_,b) -> collectStrings b vt) methods
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

getLiKey :: Ast -> Maybe String
getLiKey (AstSymbol s) = Just s
getLiKey (Call (AstSymbol "array-access") [b, AstInt k]) = 
    case getLiKey b of { Just s -> Just (s ++ "[" ++ show k ++ "]"); Nothing -> Nothing }
getLiKey _ = Nothing

uniqueList :: Eq a => [a] -> [a]
uniqueList = foldl (\acc x -> if x `elem` acc then acc else acc ++ [x]) []

escapeASM :: String -> String
escapeASM = concatMap (\c -> case c of
    '\n' -> "\\n"
    '"'  -> "\\\""
    '\\' -> "\\\\"
    x    -> [x])

-- =============================================================================
-- CLASSES OOP
-- =============================================================================

fieldOffsetOf :: [(String, Ast, Type)] -> String -> Int
fieldOffsetOf fields name =
    let indexed = zip [0..] (map (\(n,_,_) -> n) fields)
    in case lookup name (map (\(i,n) -> (n,i)) indexed) of
        Just i  -> i * 8
        Nothing -> 0

classStructSize :: [(String, Ast, Type)] -> Int
classStructSize fields = length fields * 8

emitClass :: [(String, Int)] -> Map.Map String Type -> [String] -> Ast -> String
emitClass labels vt funcNames (ClassDef cn fields mCtor methods) =
    emitClassNew labels vt funcNames cn fields mCtor
    ++ concatMap (emitClassMethod labels vt funcNames cn fields) methods
emitClass _ _ _ _ = ""

emitClassNew :: [(String, Int)] -> Map.Map String Type -> [String]
             -> String -> [(String, Ast, Type)]
             -> Maybe (String, [String], Ast) -> String
emitClassNew labels vt funcNames cn fields mCtor =
    let funcName  = cn ++ "_new"
        sz        = classStructSize fields
        params    = case mCtor of { Just (_, ps, _) -> ps; Nothing -> [] }
        nParams   = length params
        allocSize = ((nParams * 8 + 16 + 31) `div` 16) * 16 + 16
        paramRegs = ["%rdi", "%rsi", "%rdx", "%rcx", "%r8", "%r9"]
        prologue  = [ funcName ++ ":", "\tpushq %rbp", "\tmovq %rsp, %rbp", "\tsubq $" ++ show allocSize ++ ", %rsp" ]
        saveParams = concat $ zipWith (\i r -> ["\tmovq " ++ r ++ ", -" ++ show ((i+1)*8) ++ "(%rbp)"]) [0..] (take nParams paramRegs)
        doMalloc  = [ "\tmovq $" ++ show sz ++ ", %rdi", "\tcall malloc", "\tmovq %rax, %r15" ]
        initFields = concatMap (\(i, (_, defVal, _)) -> 
            exprToASM defVal Map.empty labels vt funcNames ++ ["\tmovq %rax, " ++ show (i*8) ++ "(%r15)"]) (zip [0..] fields)
        paramMap  = Map.fromList $ zip params (map (\i -> (i+1)*8) [0..])
        retLabel  = ".Lret_" ++ funcName
        ctorStmts = case mCtor of
            Nothing -> []
            Just (_, _, body) ->
                let (_, stmts, _) = emitStmts (lowerClassBody fields body) 0 labels paramMap retLabel Nothing Nothing vt Map.empty funcNames
                in stmts
        epilogue  = [ retLabel ++ ":", "\tmovq %r15, %rax", "\tleave", "\tret" ]
    in unlines $ prologue ++ saveParams ++ doMalloc ++ initFields ++ ctorStmts ++ epilogue

emitClassMethod :: [(String, Int)] -> Map.Map String Type -> [String]
                -> String -> [(String, Ast, Type)]
                -> (String, [String], Ast) -> String
emitClassMethod labels vt funcNames cn fields (mName, params, body) =
    let funcName  = cn ++ "_" ++ mName
        nExtra    = length params
        allocSize = ((nExtra * 8 + 16 + 31) `div` 16) * 16 + 16
        extraRegs = ["%rsi", "%rdx", "%rcx", "%r8", "%r9"]
        prologue  = [ funcName ++ ":", "\tpushq %rbp", "\tmovq %rsp, %rbp", "\tsubq $" ++ show allocSize ++ ", %rsp", "\tmovq %rdi, %r15" ]
        saveExtra = concat $ zipWith (\i r -> ["\tmovq " ++ r ++ ", -" ++ show ((i+1)*8) ++ "(%rbp)"]) [0..] (take nExtra extraRegs)
        paramMap  = Map.fromList $ zip params (map (\i -> (i+1)*8) [0..])
        retLabel  = ".Lret_" ++ funcName
        (_, bodyStmts, _) = emitStmts (lowerClassBody fields body) 0 labels paramMap retLabel Nothing Nothing vt Map.empty funcNames
        epilogue  = [retLabel ++ ":", "\tleave", "\tret"]
    in unlines $ prologue ++ saveExtra ++ bodyStmts ++ epilogue

lowerClassBody :: [(String, Ast, Type)] -> Ast -> Ast
lowerClassBody fields = go
  where
    fieldNames = [n | (n,_,_) <- fields]
    offsetOf n = fieldOffsetOf fields n
    go (AstSymbol n) | n `elem` fieldNames = Call (AstSymbol "field-load") [AstInt (offsetOf n)]
    go (Assign n val) | n `elem` fieldNames = Call (AstSymbol "field-store") [AstInt (offsetOf n), go val]
    go (Block xs)     = Block (map go xs)
    go (IfElse c t e) = IfElse (go c) (go t) (go e)
    go (Call f args)  = Call (go f) (map go args)
    go (Return v)     = Return (go v)
    go (While c b)    = While (go c) (go b)
    go (For v s b)    = For v (go s) (go b)
    go other          = other

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

-- =============================================================================
-- Bytecode Compilation (VM)
-- =============================================================================

compileToBytecodeFile :: FilePath -> Ast -> IO ()
compileToBytecodeFile path ast = do
    let instrs = astToInstructions ast ++ [HALT]
    saveBytecodeFile path instrs

astToInstructions :: Ast -> [Instruction]
astToInstructions (AstInt n) = [PUSH (fromIntegral n)]
astToInstructions (AstBool True) = [PUSH_TRUE]
astToInstructions (AstBool False) = [PUSH_FALSE]
astToInstructions (Call (AstSymbol "+") [a, b]) = astToInstructions a ++ astToInstructions b ++ [ADD]
astToInstructions (Call (AstSymbol "-") [a, b]) = astToInstructions a ++ astToInstructions b ++ [SUB]
astToInstructions (Call (AstSymbol "*") [a, b]) = astToInstructions a ++ astToInstructions b ++ [MUL]
astToInstructions (Call (AstSymbol "/") [a, b]) = astToInstructions a ++ astToInstructions b ++ [DIV]
astToInstructions (Call (AstSymbol "<") [a, b]) = astToInstructions a ++ astToInstructions b ++ [BC.LT]
astToInstructions (Call (AstSymbol "==") [a, b]) = astToInstructions a ++ astToInstructions b ++ [BC.EQ]
astToInstructions (Block exprs) = concatMap astToInstructions exprs
astToInstructions _ = []