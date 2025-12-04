{-
-- EPITECH PROJECT, 2025
-- lib module
-- File description:
-- lib module
-}
module Lib (SExpr(..), Ast(..), sexprToAST, evalAST, EvalResult,
            parseSExpr, parseSExprMultiple, parseSExprEither,
            parseSExprMultipleEither) where

import AST (SExpr(..), Ast(..), sexprToAST, evalAST, EvalResult)
import Parser (parseSExpr, parseSExprMultiple, parseSExprEither,
               parseSExprMultipleEither)
