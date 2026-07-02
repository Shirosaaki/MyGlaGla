{-
-- EPITECH PROJECT, 2025
-- lib module
-- File description:
-- lib module
-}
module Lib (SExpr(..), Ast(..), Type(..), Env, sexprToAST, evalAST, EvalResult,
            defName, defValue,
            Dialect(..), dialectForFile,
            parseSExpr, parseSExprMultiple, parseSExprEither,
            parseSExprMultipleEither,
            runConsole, runBatch) where

import AST (SExpr(..), Ast(..), Type(..), Env, sexprToAST, evalAST, EvalResult,
            defName, defValue)
import Parser (Dialect(..), dialectForFile,
               parseSExpr, parseSExprMultiple, parseSExprEither,
               parseSExprMultipleEither)
import Console (runConsole, runBatch)
