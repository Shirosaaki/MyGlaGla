{-
-- EPITECH PROJECT, 2025
-- AST module
-- File description:
-- file where the AST is defined
-}
module AST (SExpr(..), Ast(..), Type(..), Value(..), Env, sexprToAST, evalAST, EvalResult,
            defName, defValue) where

import qualified Data.Map as Map

data SExpr = SInt Int
            | SFloat Double
            | SBool Bool
            | SString String
            | SChar Char
            | SSymbol String
            | SList [SExpr]
            deriving Show

-- | Type system for the language
data Type = TInt
          | TFloat
          | TBool
          | TString
          | TChar
          | TVoid
          | TArray Type
          | TPointer Type
          | TStruct String [(String, Type)]  -- struct name and fields
          | TFunc [Type] Type                 -- parameter types and return type
          | TAny                             -- For type inference/flexibility
          deriving (Show, Eq, Ord)

-- | Values at runtime
data Value = VInt Int
           | VFloat Double
           | VBool Bool
           | VString String
           | VChar Char
           | VVoid
           | VArray (Map.Map Int Value)
           | VPointer (Maybe Value)
           | VStruct String (Map.Map String Value)
           | VClosure [String] Ast Env
           deriving (Show, Eq)

data Ast = Define String (Maybe Type) Ast           -- variable/function definition with optional type
         | AstInt Int
         | AstFloat Double
         | AstBool Bool
         | AstString String
         | AstChar Char
         | AstSymbol String
         | AstList [Ast]
         | Call Ast [Ast]
         | AstLambda [String] Ast
         | AstClosure [String] Ast Env
         | AstVoid
         | Assign String Ast                        -- variable assignment
         | IfElse Ast Ast Ast                        -- if-then-else
         | While Ast Ast                             -- while loop
         | For String Ast Ast                        -- for-in loop (var, collection, body)
         | Break
         | Continue
         | Return Ast
         | ArrayAccess Ast Ast                       -- array[index]
         | ArrayAssign String Ast Ast               -- array[index] = value
         | StructField Ast String                    -- struct.field
         | StructFieldAssign String String Ast      -- struct.field = value
         | Block [Ast]                               -- sequence of statements
         | TypedVar String Type Ast                  -- variable with explicit type and init value
         deriving (Show, Eq)


-- | Accessor for Define name
defName :: Ast -> String
defName (Define n _ _) = n
defName _ = error "defName: not a Define"

-- | Accessor for Define value
defValue :: Ast -> Ast
defValue (Define _ _ v) = v
defValue _ = error "defValue: not a Define"

type Env = [(String, Value)]
type EvalResult = Either String (Value, Env)

-- | Parse S-expression to AST
sexprToAST :: SExpr -> Either String Ast
sexprToAST (SSymbol s) = Right (AstSymbol s)
sexprToAST (SInt n) = Right (AstInt n)
sexprToAST (SFloat f) = Right (AstFloat f)
sexprToAST (SBool b) = Right (AstBool b)
sexprToAST (SString s) = Right (AstString s)
sexprToAST (SChar c) = Right (AstChar c)
sexprToAST (SList []) = Right (AstList [])
sexprToAST (SList [SSymbol "define", SSymbol name, value]) =
    fmap (Define name Nothing) (sexprToAST value)
sexprToAST (SList [SSymbol "define", SList (SSymbol n : p), value]) =
    case mapM paramNameE p of
        Right pn ->
            case sexprToAST value of
                Right bodAst -> Right (Define n Nothing (AstLambda pn bodAst))
                Left err -> Left err
        Left err -> Left err
sexprToAST (SList [SSymbol "define", SList [], _]) =
    Left "define: missing function name"
sexprToAST (SList [SSymbol "define", _, _]) =
    Left "define: first argument must be a symbol or function signature"
sexprToAST (SList [SSymbol "define", _]) =
    Left "define: missing value"
sexprToAST (SList [SSymbol "define"]) =
    Left "define: missing symbol and value"
sexprToAST (SList (SSymbol "define" : _)) =
    Left "define: bad syntax"
sexprToAST (SList [SSymbol "if", cond, thenExpr, elseExpr]) =
    case (sexprToAST cond, sexprToAST thenExpr, sexprToAST elseExpr) of
        (Right c, Right t, Right e) -> Right (IfElse c t e)
        (Left err, _, _) -> Left err
        (_, Left err, _) -> Left err
        (_, _, Left err) -> Left err
sexprToAST (SList [SSymbol "if", _, _]) = Left "if: missing else clause"
sexprToAST (SList [SSymbol "if", _]) = Left "if: missing then and else clauses"
sexprToAST (SList [SSymbol "if"]) = Left "if: missing condition"
sexprToAST (SList (SSymbol "if" : _)) = Left "if: bad syntax"
sexprToAST (SList [SSymbol "lambda", SList params, body]) =
    case mapM paramNameE params of
        Right pn ->
            case sexprToAST body of
                Right bodyAst -> Right (AstLambda pn bodyAst)
                Left err -> Left err
        Left err -> Left err
sexprToAST (SList [SSymbol "lambda", _, _]) =
    Left "lambda: parameters must be a list"
sexprToAST (SList [SSymbol "lambda", _]) = Left "lambda: missing body"
sexprToAST (SList [SSymbol "lambda"]) =
    Left "lambda: missing parameters and body"
sexprToAST (SList (SSymbol "lambda" : _)) = Left "lambda: bad syntax"
sexprToAST (SList (fn:args)) =
    case fn of
        SSymbol _ -> makeCall fn args
        SList (SSymbol "lambda" : _) -> makeCall fn args
        SList _  -> makeCall fn args
        _        -> makeCall fn args

paramNameE :: SExpr -> Either String String
paramNameE (SSymbol s) = Right s
paramNameE _ = Left "lambda: parameter must be a symbol"

makeCall :: SExpr -> [SExpr] -> Either String Ast
makeCall fn args =
    case sexprToAST fn of
        Left err -> Left err
        Right fnAst -> makeCallArgs fnAst args

makeCallArgs :: Ast -> [SExpr] -> Either String Ast
makeCallArgs fnAst args =
    fmap (Call fnAst) (mapM sexprToAST args)

-- | Evaluation with enhanced type support
evalAST :: Env -> Ast -> EvalResult
evalAST env (AstInt n) = Right (VInt n, env)
evalAST env (AstFloat f) = Right (VFloat f, env)
evalAST env (AstBool b) = Right (VBool b, env)
evalAST env (AstString s) = Right (VString s, env)
evalAST env (AstChar c) = Right (VChar c, env)
evalAST env AstVoid = Right (VVoid, env)
evalAST env closure@(AstClosure _ _ _) = Right (valueFromClosure closure, env)
evalAST env (AstSymbol s) =
    case lookup s env of
        Just v -> Right (v, env)
        Nothing -> Left ("variable " ++ s ++ " is not bound")
evalAST env (Define name _ty val) =
    case val of
        AstLambda params body ->
            let updatedEnv = (name, VClosure params body updatedEnv) : env
            in Right (VVoid, updatedEnv)
        _ ->
            case evalAST env val of
                Right (v, env') -> Right (VVoid, (name, v) : env')
                Left err -> Left err
evalAST env (AstLambda params body) =
    Right (VClosure params body env, env)
evalAST env (AstList xs) = evalSeq env xs
  where
    evalSeq e [] = Right (VString "list", e)  -- Empty list
    evalSeq e [x] = evalAST e x
    evalSeq e (x:xs') =
        case evalAST e x of
            Right (_, e') -> evalSeq e' xs'
            Left err -> Left err
evalAST env (IfElse cond thenExpr elseExpr) =
    case evalAST env cond of
        Right (VBool True, env1) -> evalAST env1 thenExpr
        Right (VBool False, env1) -> evalAST env1 elseExpr
        Right (_, _) -> Left "if: condition must be a boolean"
        Left err -> Left err
evalAST env (Block stmts) = evalBlock env stmts
evalAST env (Call fnAst args) = evalCall env fnAst args
evalAST _ other = Left ("Unsupported AST node: " ++ show other)

-- | Evaluate a block of statements
evalBlock :: Env -> [Ast] -> EvalResult
evalBlock env [] = Right (VVoid, env)
evalBlock env [s] = evalAST env s
evalBlock env (s:rest) =
    case evalAST env s of
        Right (_, env') -> evalBlock env' rest
        Left err -> Left err

-- | Evaluate a function call
evalCall :: Env -> Ast -> [Ast] -> EvalResult
evalCall env (AstSymbol op) args = evalOpCall env op args
evalCall env fnAst args =
    case evalAST env fnAst of
        Right (VClosure _ _ _, _) ->
            evalClosureCall env args fnAst
        Right (other, _) ->
            Left ("attempt to apply non-procedure: " ++
                  showValue other)
        Left err -> Left err

-- | Helper to convert closure AST to value
valueFromClosure :: Ast -> Value
valueFromClosure (AstClosure params body env) = VClosure params body env
valueFromClosure _ = error "valueFromClosure: not a closure"

showValue :: Value -> String
showValue (VInt n) = show n
showValue (VFloat f) = show f
showValue (VBool True) = "#t"
showValue (VBool False) = "#f"
showValue (VString s) = "\"" ++ s ++ "\""
showValue (VChar c) = "\'" ++ [c] ++ "\'"
showValue (VVoid) = "#<void>"
showValue (VClosure _ _ _) = "#<procedure>"
showValue (VArray _) = "#<array>"
showValue (VPointer _) = "#<pointer>"
showValue (VStruct n _) = "#<struct:" ++ n ++ ">"

evalClosureCall :: Env -> [Ast] -> Ast -> EvalResult
evalClosureCall env args closureAst =
    case evalAST env closureAst of
        Right (vc@(VClosure params _ _), _) ->
            evalClosureCallChecked env args closureAst params vc
        _ -> Left "Invalid closure"

evalClosureCallChecked :: Env -> [Ast] -> Ast -> [String]
                       -> Value -> EvalResult
evalClosureCallChecked env args closureAst params _ =
    case evalArgs env args of
        Left err -> Left err
        Right (argVals, _) ->
            if length params == length argVals
            then execClosure env closureAst argVals
            else Left ("wrong number of arguments: expected " ++
                      show (length params) ++ ", got " ++ show (length argVals))

execClosure :: Env -> Ast -> [Value] -> EvalResult
execClosure env closureAst argVals =
    case evalAST env closureAst of
        Right (val, _) ->
            case val of
                VClosure params body closureEnv ->
                    case evalAST (zip params argVals ++ closureEnv) body of
                        Right (res, _) -> Right (res, env)
                        Left err -> Left err
                _ -> Left "attempt to call non-procedure"
        Left err -> Left err

evalBuiltinOp :: Env -> String -> [Ast] -> EvalResult
evalBuiltinOp env op args =
    case evalArgs env args of
        Right (argVals, env') ->
            case evalOp op argVals of
                Right v -> Right (v, env')
                Left err -> Left err
        Left err -> Left err

-- | Built-in operations for the language
evalOpCall :: Env -> String -> [Ast] -> EvalResult
evalOpCall env "if" [cond, thenExpr, elseExpr] =
    case evalAST env cond of
        Right (VBool True, env1) -> evalAST env1 thenExpr
        Right (VBool False, env1) -> evalAST env1 elseExpr
        Right (_, _) -> Left "if: condition must be a boolean"
        Left err -> Left err
evalOpCall _ "if" _ = Left "if: bad syntax"
evalOpCall env "eq?" args =
    case evalArgs env args of
        Right ([a, b], env') -> Right (VBool (a == b), env')
        Right (_, _) -> Left "eq?: expected 2 arguments"
        Left err -> Left err
evalOpCall env "<" args =
    case evalArgs env args of
        Right ([VInt a, VInt b], env') -> Right (VBool (a < b), env')
        Right ([VFloat a, VFloat b], env') -> Right (VBool (a < b), env')
        Right ([_, _], _) -> Left "<: arguments must be numbers"
        Right (_, _) -> Left "<: expected 2 arguments"
        Left err -> Left err
evalOpCall env ">" args =
    case evalArgs env args of
        Right ([VInt a, VInt b], env') -> Right (VBool (a > b), env')
        Right ([VFloat a, VFloat b], env') -> Right (VBool (a > b), env')
        Right ([_, _], _) -> Left ">: arguments must be numbers"
        Right (_, _) -> Left ">: expected 2 arguments"
        Left err -> Left err
evalOpCall env "<=" args =
    case evalArgs env args of
        Right ([VInt a, VInt b], env') -> Right (VBool (a <= b), env')
        Right ([VFloat a, VFloat b], env') -> Right (VBool (a <= b), env')
        Right ([_, _], _) -> Left "<=: arguments must be numbers"
        Right (_, _) -> Left "<=: expected 2 arguments"
        Left err -> Left err
evalOpCall env ">=" args =
    case evalArgs env args of
        Right ([VInt a, VInt b], env') -> Right (VBool (a >= b), env')
        Right ([VFloat a, VFloat b], env') -> Right (VBool (a >= b), env')
        Right ([_, _], _) -> Left ">=: arguments must be numbers"
        Right (_, _) -> Left ">=: expected 2 arguments"
        Left err -> Left err
evalOpCall env "peric" args =
    case evalArgs env args of
        Right (_, env') -> Right (VVoid, env')  -- Just return void, actual print handled elsewhere
        Left err -> Left err
evalOpCall env "range" args =
    case evalArgs env args of
        Right ([VInt _, VInt _], env') ->
            Right (VString ("range"), env')  -- Simplified
        Right (_, _) -> Left "range: expected 2 integer arguments"
        Left err -> Left err
evalOpCall env op args =
    case lookup op env of
        Just (VClosure _ _ _) -> evalClosureCall env args (AstSymbol op)
        Just _ -> Left (op ++ " is not a procedure")
        Nothing -> evalBuiltinOp env op args

evalArgs :: Env -> [Ast] -> Either String ([Value], Env)
evalArgs env [] = Right ([], env)
evalArgs env (x:xs) =
    case evalAST env x of
        Right (v, env1) ->
            case evalArgs env1 xs of
                Right (vs, env2) -> Right (v:vs, env2)
                Left err -> Left err
        Left err -> Left err

-- | Arithmetic and comparison operations
evalOp :: String -> [Value] -> Either String Value
evalOp "+" [] = Right (VInt 0)
evalOp "+" vals = case mapM getNumeric vals of
    Just nums -> Right (VInt (sum nums))
    Nothing -> Left "+: arguments must be numbers"
evalOp "*" [] = Right (VInt 1)
evalOp "*" vals = case mapM getNumeric vals of
    Just nums -> Right (VInt (product nums))
    Nothing -> Left "*: arguments must be numbers"
evalOp "-" [] = Left "-: expected at least 1 argument"
evalOp "-" (VInt x:xs) = case mapM getInt xs of
    Just ns -> Right (VInt (foldl (-) x ns))
    Nothing -> Left "-: arguments must be integers"
evalOp "-" _ = Left "-: arguments must be integers"
evalOp "div" [] = Left "div: expected at least 1 argument"
evalOp "div" [_] = Left "div: expected at least 2 arguments"
evalOp "div" (VInt x:xs)
    | any isZero xs = Left "div: division by zero"
    | otherwise = case mapM getInt xs of
        Just ns -> Right (VInt (foldl div x ns))
        Nothing -> Left "div: arguments must be integers"
  where isZero (VInt y) = y == 0
        isZero _ = False
evalOp "div" _ = Left "div: arguments must be integers"
evalOp "mod" [VInt _, VInt 0] = Left "mod: division by zero"
evalOp "mod" [VInt x, VInt y] = Right (VInt (mod x y))
evalOp "mod" _ = Left "mod: expected exactly 2 integer arguments"
evalOp op _ = Left ("unknown procedure: " ++ op)

getInt :: Value -> Maybe Int
getInt (VInt n) = Just n
getInt _ = Nothing

getNumeric :: Value -> Maybe Int
getNumeric (VInt n) = Just n
getNumeric (VFloat f) = Just (floor f)
getNumeric _ = Nothing

