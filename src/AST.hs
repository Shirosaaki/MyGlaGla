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
            deriving (Show, Eq)

type Env = [(String, Ast)]

sexprToAST :: SExpr -> Maybe Ast
sexprToAST (SSymbol s) = Just (AstSymbol s)
sexprToAST (SInt n) = Just (AstInt n)
sexprToAST (SBool b) = Just (AstBool b)
sexprToAST (SList []) = Just (AstList [])
sexprToAST (SList [SSymbol "define", SSymbol name, value]) =
    fmap (Define name) (sexprToAST value)
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
    case evalAST env val of
        Just (v, env') -> Just (v, (name, v) : env')
        Nothing -> Nothing
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
    case evalArgs env args of
        Just (argVals, env') ->
            let intArgs = mapM getInt argVals in
            case intArgs of
                Nothing -> Nothing
                Just ns -> case evalOp op ns of
                              Just (AstInt n) -> Just (AstInt n, env')
                              _ -> Nothing
        Nothing -> Nothing

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