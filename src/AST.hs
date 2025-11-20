{-
-- EPITECH PROJECT, 2025
-- AST module
-- File description:
-- file where the AST is defined
-}
module AST (SExpr(..), Ast(..), sexprToAST, evalAST) where

data SExpr = SInt Int
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

sexprToAST :: SExpr -> Maybe Ast
sexprToAST (SSymbol s) = Just (AstSymbol s)
sexprToAST (SInt n) = Just (AstInt n)
sexprToAST (SList []) = Just (AstList [])
sexprToAST (SList [SSymbol "define", SSymbol name, value]) =
    fmap (Define name) (sexprToAST value)
sexprToAST (SList (SSymbol "define" : _)) = Nothing
sexprToAST (SList (fn:args)) = makeCall fn args

makeCall :: SExpr -> [SExpr] -> Maybe Ast
makeCall fn args =
    case sexprToAST fn of
        Nothing -> Nothing
        Just fnAst -> makeCallArgs fnAst args

makeCallArgs :: Ast -> [SExpr] -> Maybe Ast
makeCallArgs fnAst args =
    fmap (Call fnAst) (mapM sexprToAST args)
evalAST :: Ast -> Maybe Ast
evalAST (AstInt n) = Just (AstInt n)
evalAST (AstSymbol s) = Just (AstSymbol s)
evalAST (Call (AstSymbol op) args) =
    evalOpCall op args
evalAST (Call _ _) = Nothing
evalAST (Define name val) = Just (Define name val)
evalAST (AstList xs) = AstList <$> mapM evalAST xs
evalAST (AstBool b) = Just (AstBool b)

evalOpCall :: String -> [Ast] -> Maybe Ast
evalOpCall op args =
    case mapM evalAST args of
        Nothing -> Nothing
        Just argVals ->
            let intArgs = mapM getInt argVals in
            case intArgs of
                Nothing -> Nothing
                Just ns -> evalOp op ns

getInt :: Ast -> Maybe Int
getInt (AstInt n) = Just n
getInt _ = Nothing

evalOp :: String -> [Int] -> Maybe Ast
evalOp "+" ns = Just (AstInt (sum ns))
evalOp "*" ns = Just (AstInt (product ns))
evalOp "-" (x:xs) = Just (AstInt (foldl (-) x xs))
evalOp "-" _ = Nothing
evalOp "/" (x:xs)
    | all (/= 0) xs = Just (AstInt (foldl div x xs))
    | otherwise = Nothing
evalOp "/" _ = Nothing
evalOp _ _ = Nothing