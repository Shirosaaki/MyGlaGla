{-
-- EPITECH PROJECT, 2025
-- Parser
-- File description:
-- Runtime wrapper to select between TheShow, Lisp, or WaifuLang parser
-}

module Parser (
  parseSExpr,
  parseSExprEither,
  parseSExprMultiple,
  parseSExprMultipleEither,
  setUseLisp,
  setUseWaifu,
  getUseLisp,
  getUseWaifu
) where

import qualified Theshow.Parser as TS
import qualified Lisp.Parser as LP
import qualified WaifuLang.Parser as WP
import AST (SExpr(..))
import System.IO.Unsafe (unsafePerformIO)
import Data.IORef

-- ============================================================================
-- Runtime Flags (Global State)
-- ============================================================================

-- Flag pour le mode Lisp (-l)
{-# NOINLINE useLispRef #-}
useLispRef :: IORef Bool
useLispRef = unsafePerformIO (newIORef False)

setUseLisp :: Bool -> IO ()
setUseLisp v = writeIORef useLispRef v

getUseLisp :: Bool
getUseLisp = unsafePerformIO (readIORef useLispRef)

-- Flag pour le mode WaifuScript (-w)
{-# NOINLINE useWaifuRef #-}
useWaifuRef :: IORef Bool
useWaifuRef = unsafePerformIO (newIORef False)

setUseWaifu :: Bool -> IO ()
setUseWaifu v = writeIORef useWaifuRef v

getUseWaifu :: Bool
getUseWaifu = unsafePerformIO (readIORef useWaifuRef)

-- ============================================================================
-- Helper: Conversion Either -> Maybe
-- ============================================================================

eitherToMaybe :: Either a b -> Maybe b
eitherToMaybe (Right v) = Just v
eitherToMaybe (Left _)  = Nothing

-- ============================================================================
-- Public API with Dispatch Logic
-- ============================================================================

-- | Parse un seul SExpr (version Either pour avoir les erreurs)
parseSExprEither :: String -> Either String SExpr
parseSExprEither src
  | getUseLisp  = LP.parseSExprEither src
  | getUseWaifu = WP.parseSExprEither src
  | otherwise   = TS.parseSExprEither src

-- | Parse un seul SExpr (version Maybe)
parseSExpr :: String -> Maybe SExpr
parseSExpr s
  | getUseLisp  = LP.parseSExpr s
  | getUseWaifu = eitherToMaybe (WP.parseSExprEither s)
  | otherwise   = TS.parseSExpr s

-- | Parse plusieurs SExpr (version Maybe)
parseSExprMultiple :: String -> Maybe [SExpr]
parseSExprMultiple s
  | getUseLisp  = LP.parseSExprMultiple s
  | getUseWaifu = eitherToMaybe (WP.parseSExprMultipleEither s)
  | otherwise   = TS.parseSExprMultiple s

-- | Parse plusieurs SExpr (version Either pour avoir les erreurs)
parseSExprMultipleEither :: String -> Either String [SExpr]
parseSExprMultipleEither src
  | getUseLisp  = LP.parseSExprMultipleEither src
  | getUseWaifu = WP.parseSExprMultipleEither src
  | otherwise   = TS.parseSExprMultipleEither src