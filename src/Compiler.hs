{-
-- EPITECH PROJECT, 2025
-- Compiler module
-- File description:
-- Generates LLVM IR and optionally .o from AST
-}
module Compiler (compileModuleLLVM, compileToObject, compileToLL) where

import System.Process (createProcess, proc, std_in, StdStream(..), waitForProcess)
import System.IO (hPutStr, hClose)
import AST (Ast(..))
import qualified Data.Map as Map
import Control.Monad.State

-- Compiler state: variable environment, temp counter, generated code lines
data CompState = CompState
    { varEnv   :: Map.Map String String   -- var name -> LLVM register
    , tmpCount :: Int
    , codeLines :: [String]
    , funcs    :: [String]                -- generated function definitions
    }

type Compiler a = State CompState a

freshTmp :: Compiler String
freshTmp = do
    s <- get
    let n = tmpCount s
    put s { tmpCount = n + 1 }
    return ("%" ++ show n)

emit :: String -> Compiler ()
emit line = modify (\s -> s { codeLines = codeLines s ++ [line] })

lookupVar :: String -> Compiler String
lookupVar name = do
    env <- gets varEnv
    case Map.lookup name env of
        Just reg -> return reg
        Nothing -> error ("Undefined variable: " ++ name)

bindVar :: String -> String -> Compiler ()
bindVar name reg = modify (\s -> s { varEnv = Map.insert name reg (varEnv s) })

-- Compile entire program
compileModuleLLVM :: Ast -> String
compileModuleLLVM ast = unlines (moduleHeader ++ [funcDefs, mainFn])
  where
    (resultReg, finalState) = runState (compileAst ast) initState
    initState = CompState Map.empty 0 [] []
    funcDefs = unlines (funcs finalState)
    mainFn = buildMainFn (codeLines finalState) resultReg

moduleHeader :: [String]
moduleHeader =
    [ "; ModuleID = 'glados'"
    , "source_filename = \"glados\""
    , "target triple = \"x86_64-pc-linux-gnu\""
    , "", "declare i32 @printf(i8*, ...)"
    , "declare i32 @puts(i8*)", ""
    , "@.fmt_int = private constant [4 x i8] c\"%d\\0A\\00\""
    , "" ]

buildMainFn :: [String] -> String -> String
buildMainFn bodyLines resReg = unlines $
    ["define i32 @main() {", "entry:"] ++ bodyLines ++
    ["  ret i32 " ++ resReg, "}"]

-- Compile AST node, returns register holding result
compileAst :: Ast -> Compiler String

-- Integer literal
compileAst (AstInt n) = do
    tmp <- freshTmp
    emit ("  " ++ tmp ++ " = add i32 0, " ++ show n)
    return tmp

-- Boolean literal (1 = true, 0 = false)
compileAst (AstBool b) = do
    tmp <- freshTmp
    emit ("  " ++ tmp ++ " = add i32 0, " ++ if b then "1" else "0")
    return tmp

-- Variable reference
compileAst (AstSymbol name) = lookupVar name

-- Block / sequence
compileAst (Block []) = do
    tmp <- freshTmp
    emit ("  " ++ tmp ++ " = add i32 0, 0")
    return tmp
compileAst (Block [x]) = compileAst x
compileAst (Block (x:xs)) = do
    _ <- compileAst x
    compileAst (Block xs)

compileAst (AstList xs) = compileAst (Block xs)

-- Define: bind variable to value
compileAst (Define name _ val) = do
    reg <- compileAst val
    bindVar name reg
    tmp <- freshTmp
    emit ("  " ++ tmp ++ " = add i32 0, 0")  -- define returns void/0
    return tmp

-- If-then-else
compileAst (IfElse cond thenE elseE) = compileIfElse cond thenE elseE

-- Function calls
compileAst (Call (AstSymbol op) args) = compileCall op args
compileAst (Call fn args) = do
    _ <- compileAst fn
    _ <- mapM compileAst args
    tmp <- freshTmp
    emit ("  " ++ tmp ++ " = add i32 0, 0  ; complex call")
    return tmp

-- Lambda placeholder
compileAst (AstLambda _ _) = do
    tmp <- freshTmp
    emit ("  " ++ tmp ++ " = add i32 0, 0  ; lambda placeholder")
    return tmp

compileAst other = error ("Unsupported codegen node: " ++ show other)

-- If-else helpers
compileIfElse :: Ast -> Ast -> Ast -> Compiler String
compileIfElse cond thenE elseE = do
    condReg <- compileAst cond
    labels <- makeIfLabels
    emitCondBranch condReg labels
    (thenReg, thenEnd) <- compileBranch (thenL labels) thenE (endL labels)
    (elseReg, elseEnd) <- compileBranch (elseL labels) elseE (endL labels)
    emitPhiMerge (endL labels) thenReg thenEnd elseReg elseEnd

data IfLabels = IfLabels { thenL, elseL, endL :: String }

makeIfLabels :: Compiler IfLabels
makeIfLabels = IfLabels <$> freshLabel "then"
                        <*> freshLabel "else"
                        <*> freshLabel "endif"

emitCondBranch :: String -> IfLabels -> Compiler ()
emitCondBranch condReg labels = do
    cmpTmp <- freshTmp
    emit ("  " ++ cmpTmp ++ " = icmp ne i32 " ++ condReg ++ ", 0")
    emit ("  br i1 " ++ cmpTmp ++ brTargets labels)
  where brTargets l = ", label %" ++ thenL l ++ ", label %" ++ elseL l

compileBranch :: String -> Ast -> String -> Compiler (String, String)
compileBranch label body endLbl = do
    emit (label ++ ":")
    reg <- compileAst body
    emit ("  br label %" ++ endLbl)
    endLabel <- getCurrentLabel
    return (reg, endLabel)

emitPhiMerge :: String -> String -> String -> String -> String -> Compiler String
emitPhiMerge endLbl thenR thenEnd elseR elseEnd = do
    emit (endLbl ++ ":")
    resultTmp <- freshTmp
    emit ("  " ++ resultTmp ++ " = phi i32 " ++ phiArgs)
    return resultTmp
  where phiArgs = "[" ++ thenR ++ ", %" ++ thenEnd ++ "], " ++
                  "[" ++ elseR ++ ", %" ++ elseEnd ++ "]"

-- Helper for labels
freshLabel :: String -> Compiler String
freshLabel prefix = do
    s <- get
    let n = tmpCount s
    put s { tmpCount = n + 1 }
    return (prefix ++ show n)

getCurrentLabel :: Compiler String
getCurrentLabel = do
        code <- gets codeLines
        let labels = [takeWhile (/= ':') l | l <- code, isLabel l]
        return (if null labels then "entry" else last labels)
    where
        isLabel l = case l of
            (c:_) -> c /= ' ' && ':' `elem` l
            _ -> False

-- Compile built-in operations
compileCall :: String -> [Ast] -> Compiler String

-- Arithmetic
compileCall "+" args = do
    regs <- mapM compileAst args
    foldBinOp "add" "0" regs

compileCall "-" [a] = do
    aReg <- compileAst a
    tmp <- freshTmp
    emit ("  " ++ tmp ++ " = sub i32 0, " ++ aReg)
    return tmp
compileCall "-" (a:rest) = do
    aReg <- compileAst a
    restRegs <- mapM compileAst rest
    foldBinOpWith "sub" aReg restRegs
compileCall "-" [] = do
    tmp <- freshTmp
    emit ("  " ++ tmp ++ " = add i32 0, 0")
    return tmp

compileCall "*" args = do
    regs <- mapM compileAst args
    foldBinOp "mul" "1" regs

compileCall "div" [a, b] = do
    aReg <- compileAst a
    bReg <- compileAst b
    tmp <- freshTmp
    emit ("  " ++ tmp ++ " = sdiv i32 " ++ aReg ++ ", " ++ bReg)
    return tmp
compileCall "div" _ = error "div requires exactly 2 arguments"

compileCall "mod" [a, b] = do
    aReg <- compileAst a
    bReg <- compileAst b
    tmp <- freshTmp
    emit ("  " ++ tmp ++ " = srem i32 " ++ aReg ++ ", " ++ bReg)
    return tmp
compileCall "mod" _ = error "mod requires exactly 2 arguments"

-- Comparisons (return 1 or 0)
compileCall "<" [a, b] = compileCmp "slt" a b
compileCall ">" [a, b] = compileCmp "sgt" a b
compileCall "<=" [a, b] = compileCmp "sle" a b
compileCall ">=" [a, b] = compileCmp "sge" a b
compileCall "eq?" [a, b] = compileCmp "eq" a b
compileCall "<" _ = error "< requires exactly 2 arguments"
compileCall ">" _ = error "> requires exactly 2 arguments"
compileCall "<=" _ = error "<= requires exactly 2 arguments"
compileCall ">=" _ = error ">= requires exactly 2 arguments"
compileCall "eq?" _ = error "eq? requires exactly 2 arguments"

-- Print (for debugging)
compileCall "peric" args = mapM_ emitPrint args >> emitZero

-- Unknown function call - try to look it up as a variable
compileCall name args = do
    env <- gets varEnv
    case Map.lookup name env of
        Just _  -> callKnownVar args
        Nothing -> error ("Unknown function: " ++ name)

emitPrint :: Ast -> Compiler ()
emitPrint arg = do
    reg <- compileAst arg
    tmp <- freshTmp
    emit ("  " ++ tmp ++ " = call i32 (i8*, ...) @printf" ++ printArgs reg)
  where printArgs r = "(i8* getelementptr ([4 x i8], " ++
                      "[4 x i8]* @.fmt_int, i32 0, i32 0), i32 " ++ r ++ ")"

callKnownVar :: [Ast] -> Compiler String
callKnownVar [] = emitZero
callKnownVar args = last <$> mapM compileAst args

emitZero :: Compiler String
emitZero = do
    tmp <- freshTmp
    emit ("  " ++ tmp ++ " = add i32 0, 0")
    return tmp

-- Helper: fold binary operation
foldBinOp :: String -> String -> [String] -> Compiler String
foldBinOp _ identity [] = do
    tmp <- freshTmp
    emit ("  " ++ tmp ++ " = add i32 0, " ++ identity)
    return tmp
foldBinOp _ _ [r] = return r
foldBinOp op _ (r:rs) = foldBinOpWith op r rs

foldBinOpWith :: String -> String -> [String] -> Compiler String
foldBinOpWith _ acc [] = return acc
foldBinOpWith op acc (r:rs) = do
    tmp <- freshTmp
    emit ("  " ++ tmp ++ " = " ++ op ++ " i32 " ++ acc ++ ", " ++ r)
    foldBinOpWith op tmp rs

-- Helper: compile comparison
compileCmp :: String -> Ast -> Ast -> Compiler String
compileCmp cmpOp a b = do
    aReg <- compileAst a
    bReg <- compileAst b
    cmpTmp <- freshTmp
    emit ("  " ++ cmpTmp ++ " = icmp " ++ cmpOp ++ cmpArgs aReg bReg)
    resultTmp <- freshTmp
    emit ("  " ++ resultTmp ++ " = zext i1 " ++ cmpTmp ++ " to i32")
    return resultTmp
  where cmpArgs ar br = " i32 " ++ ar ++ ", " ++ br

-- Write LLVM IR to a file
compileToLL :: FilePath -> Ast -> IO ()
compileToLL out ast = writeFile out (compileModuleLLVM ast)

-- Produce a .o by piping IR directly to clang (no temp .ll file)
compileToObject :: FilePath -> Ast -> IO ()
compileToObject out ast = do
    (Just hin, _, _, ph) <- createProcess clangProc
    hPutStr hin (compileModuleLLVM ast) >> hClose hin
    _ <- waitForProcess ph
    return ()
  where clangProc = (proc "clang" ["-x", "ir", "-c", "-", "-o", out])
                    { std_in = CreatePipe }
