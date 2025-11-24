{-
-- EPITECH PROJECT, 2025
-- AST module
-- File description:
-- file where the AST is defined
-}
module AST (SExpr(..), Ast(..), sexprToAST, evalAST) where

data SExpr = SInt Int
            | SBool Bool
            | SSymbol String
            | SList [SExpr]
            deriving Show

data Ast = Define { defName :: String, defValue :: Ast }
            | AstInt Int
            | AstSymbol String
            | AstBool Bool
            | AstList [Ast]
            | Call Ast [Ast]
            | AstLambda [String] Ast
            | AstClosure [String] Ast Env
            | AstVoid  -- represents an undefined/void value (for define statements)
            deriving (Show, Eq)

type Env = [(String, Ast)]

sexprToAST :: SExpr -> Maybe Ast
sexprToAST (SSymbol s) = Just (AstSymbol s)
sexprToAST (SInt n) = Just (AstInt n)
sexprToAST (SBool b) = Just (AstBool b)
sexprToAST (SList []) = Just (AstList [])
sexprToAST (SList [SSymbol "define", SSymbol name, value]) =
    fmap (Define name) (sexprToAST value)
sexprToAST (SList [SSymbol "define", SList (SSymbol name : params), value]) =
    case mapM paramName params of
        Just paramNames ->
            case sexprToAST value of
                Just bodAst -> Just (Define name (AstLambda paramNames bodAst))
                Nothing -> Nothing
        Nothing -> Nothing
sexprToAST (SList (SSymbol "define" : _)) = Nothing
sexprToAST (SList [SSymbol "if", cond, thenExpr, elseExpr]) =
    case (sexprToAST cond, sexprToAST thenExpr, sexprToAST elseExpr) of
        (Just c, Just t, Just e) -> Just (Call (AstSymbol "if") [c, t, e])
        _ -> Nothing
sexprToAST (SList (SSymbol "if" : _)) = Nothing
sexprToAST (SList (fn:args)) =
    case fn of
        SSymbol _ -> makeCall fn args
        SList _  -> AstList <$> mapM sexprToAST (fn:args)
        _        -> makeCall fn args
sexprToAST (SList [SSymbol "lambda", SList params, body]) =
    case mapM paramName params of
        Just paramNames ->
            case sexprToAST body of
                Just bodyAst -> Just (AstLambda paramNames bodyAst)
                Nothing -> Nothing
        Nothing -> Nothing

paramName :: SExpr -> Maybe String
paramName (SSymbol s) = Just s
paramName _ = Nothing

makeCall :: SExpr -> [SExpr] -> Maybe Ast
makeCall fn args =
    case sexprToAST fn of
        Nothing -> Nothing
        Just fnAst -> makeCallArgs fnAst args

makeCallArgs :: Ast -> [SExpr] -> Maybe Ast
makeCallArgs fnAst args =
    fmap (Call fnAst) (mapM sexprToAST args)
evalAST :: Env -> Ast -> Maybe (Ast, Env)
evalAST env (AstInt n) = Just (AstInt n, env)
evalAST env (AstBool b) = Just (AstBool b, env)
evalAST env (AstSymbol s) =
    case lookup s env of
        Just v -> Just (v, env)
        Nothing -> Nothing
evalAST env (Define name val) =
    case val of
        AstLambda params body ->
            let updatedEnv = (name, AstClosure params body updatedEnv) : env
            in Just (AstVoid, updatedEnv)
        _ ->
            case evalAST env val of
                Just (v, env') -> Just (AstVoid, (name, v) : env')
                Nothing -> Nothing
evalAST env (AstLambda params body) =
    Just (AstClosure params body env, env)
evalAST env (AstList xs) = evalSeq env xs
  where
    evalSeq e [] = Just (AstList [], e)
    evalSeq e [x] = evalAST e x
    evalSeq e (x:xs') =
        case evalAST e x of
            Just (_, e') -> evalSeq e' xs'
            Nothing -> Nothing
evalAST env (Call (AstSymbol op) args) = evalOpCall env op args
evalAST _ (Call _ _) = Nothing

evalClosureCall :: Env -> [Ast] -> Ast -> Maybe (Ast, Env)
evalClosureCall env args (AstClosure params body closureEnv) =
    do
        (argVals, env') <- evalArgs env args
        if length params /= length argVals then Nothing else
            case evalAST (zip params argVals ++ closureEnv) body of
                Just (res, _) -> Just (res, env')
                Nothing -> Nothing
evalClosureCall _ _ _ = Nothing

evalBuiltinOp :: Env -> String -> [Ast] -> Maybe (Ast, Env)
evalBuiltinOp env op args =
    case evalArgs env args of
        Just (argVals, env') ->
            case mapM getInt argVals of
                Nothing -> Nothing
                Just ns -> case evalOp op ns of
                              Just (AstInt n) -> Just (AstInt n, env')
                              _ -> Nothing
        Nothing -> Nothing

evalOpCall :: Env -> String -> [Ast] -> Maybe (Ast, Env)
evalOpCall env "if" [cond, thenExpr, elseExpr] =
    case evalAST env cond of
        Just (AstBool True, env1) -> evalAST env1 thenExpr
        Just (AstBool False, env1) -> evalAST env1 elseExpr
        _ -> Nothing
evalOpCall _ "if" _ = Nothing
evalOpCall env "eq?" args =
    case evalArgs env args of
        Just ( [a, b], env') -> Just (AstBool (a == b), env')
        _ -> Nothing
evalOpCall env "<" args =
    case evalArgs env args of
        Just ([AstInt a, AstInt b], env') -> Just (AstBool (a < b), env')
        _ -> Nothing
evalOpCall env op args =
    case lookup op env of
        Just closure@(AstClosure _ _ _) -> evalClosureCall env args closure
        _ -> evalBuiltinOp env op args

evalArgs :: Env -> [Ast] -> Maybe ([Ast], Env)
evalArgs env [] = Just ([], env)
evalArgs env (x:xs) =
    case evalAST env x of
        Just (v, env1) ->
            case evalArgs env1 xs of
                Just (vs, env2) -> Just (v:vs, env2)
                Nothing -> Nothing
        Nothing -> Nothing

getInt :: Ast -> Maybe Int
getInt (AstInt n) = Just n
getInt _ = Nothing

evalOp :: String -> [Int] -> Maybe Ast
evalOp "+" ns = Just (AstInt (sum ns))
evalOp "+" _ = Nothing
evalOp "*" ns = Just (AstInt (product ns))
evalOp "*" _ = Nothing
evalOp "-" (x:xs) = Just (AstInt (foldl (-) x xs))
evalOp "-" _ = Nothing
evalOp "div" (x:xs)
    | all (/= 0) xs = Just (AstInt (foldl div x xs))
    | otherwise = Nothing
evalOp "div" _ = Nothing
evalOp "mod" [x, y]
    | y /= 0 = Just (AstInt (mod x y))
    | otherwise = Nothing
evalOp _ _ = Nothing
