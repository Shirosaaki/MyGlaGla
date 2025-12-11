{-
-- EPITECH PROJECT, 2025
-- lib module
-- File description:
-- lib module
-}
module Lib (SExpr(..), Ast(..), Type(..), Value(..), Env, sexprToAST, evalAST, EvalResult,
            defName, defValue,
            parseSExpr, parseSExprMultiple, parseSExprEither,
            parseSExprMultipleEither,
            runConsole, runBatch) where

import AST (SExpr(..), Ast(..), Type(..), Value(..), Env, sexprToAST, evalAST, EvalResult,
            defName, defValue)
import Parser (parseSExpr, parseSExprMultiple, parseSExprEither,
               parseSExprMultipleEither)
import Console (runConsole, runBatch)
