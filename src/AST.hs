{-
-- EPITECH PROJECT, 2025
-- AST module
-- File description:
-- file where the AST is defined
-}
module AST (SExpr(..), Ast(..), sexprToAST, evalAST, EvalResult,
            defName, defValue) where

data SExpr = SInt Int
            | SBool Bool
            | SSymbol String
            | SList [SExpr]
            deriving Show

data Ast = Define String Ast
            | AstInt Int
            | AstSymbol String
            | AstBool Bool
            | AstList [Ast]
            | Call Ast [Ast]
            | AstLambda [String] Ast
            | AstClosure [String] Ast Env
            | AstVoid
            deriving (Show, Eq)

-- | Accessor for Define name
defName :: Ast -> String
defName (Define n _) = n
defName _ = error "defName: not a Define"

-- | Accessor for Define value
defValue :: Ast -> Ast
defValue (Define _ v) = v
defValue _ = error "defValue: not a Define"

type Env = [(String, Ast)]
type EvalResult = Either String (Ast, Env)

sexprToAST :: SExpr -> Either String Ast
sexprToAST (SSymbol s) = Right (AstSymbol s)
sexprToAST (SInt n) = Right (AstInt n)
sexprToAST (SBool b) = Right (AstBool b)
sexprToAST (SList []) = Right (AstList [])
sexprToAST (SList [SSymbol "define", SSymbol name, value]) =
    fmap (Define name) (sexprToAST value)
sexprToAST (SList [SSymbol "define", SList (SSymbol n : p), value]) =
    case mapM paramNameE p of
        Right pn ->
            case sexprToAST value of
                Right bodAst -> Right (Define n (AstLambda pn bodAst))
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
        (Right c, Right t, Right e) -> Right (Call (AstSymbol "if") [c, t, e])
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

evalAST :: Env -> Ast -> EvalResult
evalAST env (AstInt n) = Right (AstInt n, env)
evalAST env (AstBool b) = Right (AstBool b, env)
evalAST env AstVoid = Right (AstVoid, env)
evalAST env closure@(AstClosure _ _ _) = Right (closure, env)
evalAST env (AstSymbol s) =
    case lookup s env of
        Just v -> Right (v, env)
        Nothing -> Left ("variable " ++ s ++ " is not bound")
evalAST env (Define name val) =
    case val of
        AstLambda params body ->
            let updatedEnv = (name, AstClosure params body updatedEnv) : env
            in Right (AstVoid, updatedEnv)
        _ ->
            case evalAST env val of
                Right (v, env') -> Right (AstVoid, (name, v) : env')
                Left err -> Left err
evalAST env (AstLambda params body) =
    Right (AstClosure params body env, env)
evalAST env (AstList xs) = evalSeq env xs
  where
    evalSeq e [] = Right (AstList [], e)
    evalSeq e [x] = evalAST e x
    evalSeq e (x:xs') =
        case evalAST e x of
            Right (_, e') -> evalSeq e' xs'
            Left err -> Left err
evalAST env (Call fnAst args) =
    case fnAst of
        AstSymbol op -> evalOpCall env op args
        _ ->
            case evalAST env fnAst of
                Right (closure@(AstClosure _ _ _), _) ->
                    evalClosureCall env args closure
                Right (other, _) ->
                    Left ("attempt to apply non-procedure: " ++ showAst other)
                Left err -> Left err

showAst :: Ast -> String
showAst (AstInt n) = show n
showAst (AstBool True) = "#t"
showAst (AstBool False) = "#f"
showAst (AstSymbol s) = s
showAst (AstClosure _ _ _) = "#<procedure>"
showAst AstVoid = "#<void>"
showAst _ = "<unknown>"

evalClosureCall :: Env -> [Ast] -> Ast -> EvalResult
evalClosureCall env args (AstClosure params body closureEnv) =
    case evalArgs env args of
        Left err -> Left err
        Right (argVals, _) ->
            if length params /= length argVals
            then Left ("wrong number of arguments: expected " ++
                      show (length params) ++ ", got " ++ show (length argVals))
            else case evalAST (zip params argVals ++ closureEnv) body of
                Right (res, _) -> Right (res, env)
                Left err -> Left err
evalClosureCall _ _ _ = Left "internal error: not a closure"

evalBuiltinOp :: Env -> String -> [Ast] -> EvalResult
evalBuiltinOp env op args =
    case evalArgs env args of
        Right (argVals, env') ->
            case mapM getInt argVals of
                Nothing -> Left (op ++ ": wrong type argument")
                Just ns -> case evalOp op ns of
                              Right (AstInt n) -> Right (AstInt n, env')
                              Left err -> Left err
                              _ -> Left (op ++ ": unexpected result")
        Left err -> Left err

evalOpCall :: Env -> String -> [Ast] -> EvalResult
evalOpCall env "if" [cond, thenExpr, elseExpr] =
    case evalAST env cond of
        Right (AstBool True, env1) -> evalAST env1 thenExpr
        Right (AstBool False, env1) -> evalAST env1 elseExpr
        Right (_, _) -> Left "if: condition must be a boolean"
        Left err -> Left err
evalOpCall _ "if" _ = Left "if: bad syntax"
evalOpCall env "eq?" args =
    case evalArgs env args of
        Right ([a, b], env') -> Right (AstBool (a == b), env')
        Right (_, _) -> Left "eq?: expected 2 arguments"
        Left err -> Left err
evalOpCall env "<" args =
    case evalArgs env args of
        Right ([AstInt a, AstInt b], env') -> Right (AstBool (a < b), env')
        Right ([_, _], _) -> Left "<: arguments must be integers"
        Right (_, _) -> Left "<: expected 2 arguments"
        Left err -> Left err
evalOpCall env op args =
    case lookup op env of
        Just closure@(AstClosure _ _ _) -> evalClosureCall env args closure
        Just _ -> Left (op ++ " is not a procedure")
        Nothing -> evalBuiltinOp env op args

evalArgs :: Env -> [Ast] -> Either String ([Ast], Env)
evalArgs env [] = Right ([], env)
evalArgs env (x:xs) =
    case evalAST env x of
        Right (v, env1) ->
            case evalArgs env1 xs of
                Right (vs, env2) -> Right (v:vs, env2)
                Left err -> Left err
        Left err -> Left err

getInt :: Ast -> Maybe Int
getInt (AstInt n) = Just n
getInt _ = Nothing

evalOp :: String -> [Int] -> Either String Ast
evalOp "+" ns = Right (AstInt (sum ns))
evalOp "*" ns = Right (AstInt (product ns))
evalOp "-" [] = Left "-: expected at least 1 argument"
evalOp "-" (x:xs) = Right (AstInt (foldl (-) x xs))
evalOp "div" [] = Left "div: expected at least 1 argument"
evalOp "div" [_] = Left "div: expected at least 2 arguments"
evalOp "div" (x:xs)
    | any (== 0) xs = Left "div: division by zero"
    | otherwise = Right (AstInt (foldl div x xs))
evalOp "mod" [_, 0] = Left "mod: division by zero"
evalOp "mod" [x, y] = Right (AstInt (mod x y))
evalOp "mod" _ = Left "mod: expected exactly 2 arguments"
evalOp op _ = Left ("unknown procedure: " ++ op)
