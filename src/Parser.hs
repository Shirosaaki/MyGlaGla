{-
-- EPITECH PROJECT, 2025
-- Parser
-- File description:
-- Dispatch wrapper to select between TheShow, Lisp, or WaifuLang parser
-}

module Parser (
  Dialect(..),
  dialectForFile,
  parseSExpr,
  parseSExprEither,
  parseSExprMultiple,
  parseSExprMultipleEither
) where

import qualified Theshow.Parser as TS
import qualified Lisp.Parser as LP
import qualified WaifuLang.Parser as WP
import AST (SExpr(..))
import System.FilePath (takeExtension)

-- | The three surface languages supported by glados.
data Dialect = TheShow | Lisp | Waifu
  deriving (Eq, Show)

-- | Detect the dialect from a source file extension, when recognizable.
dialectForFile :: FilePath -> Maybe Dialect
dialectForFile path = case takeExtension path of
  ".waifu"  -> Just Waifu
  ".tslang" -> Just TheShow
  ".tsl"    -> Just TheShow
  ".scm"    -> Just Lisp
  ".lisp"   -> Just Lisp
  _         -> Nothing

eitherToMaybe :: Either a b -> Maybe b
eitherToMaybe (Right v) = Just v
eitherToMaybe (Left _)  = Nothing

-- | Parse a single statement/expression (with error message).
parseSExprEither :: Dialect -> String -> Either String SExpr
parseSExprEither Lisp    = LP.parseSExprEither
parseSExprEither Waifu   = WP.parseSExprEither
parseSExprEither TheShow = TS.parseSExprEither

-- | Parse a single statement/expression (Maybe version).
parseSExpr :: Dialect -> String -> Maybe SExpr
parseSExpr Lisp    = LP.parseSExpr
parseSExpr Waifu   = eitherToMaybe . WP.parseSExprEither
parseSExpr TheShow = TS.parseSExpr

-- | Parse a whole program (Maybe version).
parseSExprMultiple :: Dialect -> String -> Maybe [SExpr]
parseSExprMultiple Lisp    = LP.parseSExprMultiple
parseSExprMultiple Waifu   = eitherToMaybe . WP.parseSExprMultipleEither
parseSExprMultiple TheShow = TS.parseSExprMultiple

-- | Parse a whole program (with error message).
parseSExprMultipleEither :: Dialect -> String -> Either String [SExpr]
parseSExprMultipleEither Lisp    = LP.parseSExprMultipleEither
parseSExprMultipleEither Waifu   = WP.parseSExprMultipleEither
parseSExprMultipleEither TheShow = TS.parseSExprMultipleEither
