{-
-- EPITECH PROJECT, 2025
-- Parser
-- File description:
-- Runtime wrapper to select between TheShow parser and Lisp parser
-}

module Parser (
  parseSExpr,
  parseSExprEither,
  parseSExprMultiple,
  parseSExprMultipleEither,
  setUseLisp
) where

import qualified Theshow.Parser as TS
import qualified Lisp.Parser as LP
import AST (SExpr(..))
import System.IO.Unsafe (unsafePerformIO)
import Data.IORef

-- | Runtime flag (default: False -> use Theshow.Parser)
{-# NOINLINE useLispRef #-}
useLispRef :: IORef Bool
useLispRef = unsafePerformIO (newIORef False)

setUseLisp :: Bool -> IO ()
setUseLisp v = writeIORef useLispRef v

getUseLisp :: Bool
getUseLisp = unsafePerformIO (readIORef useLispRef)

parseSExprEither :: String -> Either String SExpr
parseSExprEither src = if getUseLisp then LP.parseSExprEither src else TS.parseSExprEither src

parseSExpr :: String -> Maybe SExpr
parseSExpr s = if getUseLisp then LP.parseSExpr s else TS.parseSExpr s

parseSExprMultiple :: String -> Maybe [SExpr]
parseSExprMultiple s = if getUseLisp then LP.parseSExprMultiple s else TS.parseSExprMultiple s

parseSExprMultipleEither :: String -> Either String [SExpr]
parseSExprMultipleEither src = if getUseLisp then LP.parseSExprMultipleEither src else TS.parseSExprMultipleEither src
