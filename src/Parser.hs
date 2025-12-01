{-
-- EPITECH PROJECT, 2025
-- Parser
-- File description:
-- Parsing with Megaparsec
-}

module Parser (parseSExpr, parseSExprEither, parseSExprMultiple, parseSExprMultipleEither) where

import AST (SExpr(..))
import Data.Void (Void)
import Control.Monad (void)
import Text.Megaparsec
import Text.Megaparsec.Char
import qualified Text.Megaparsec.Char.Lexer as L

type Parser = Parsec Void String

parseSExprEither :: String -> Either String SExpr
parseSExprEither src =
  case parse (spaceConsumer *> sexpr <* eof) "<input>" src of
    Left e  -> Left (errorBundlePretty e)
    Right v -> Right v

parseSExpr :: String -> Maybe SExpr
parseSExpr s = either (const Nothing) Just (parseSExprEither s)

parseSExprMultiple :: String -> Maybe [SExpr]
parseSExprMultiple s = either (const Nothing) Just (parseSExprMultipleEither s)

parseSExprMultipleEither :: String -> Either String [SExpr]
parseSExprMultipleEither src =
  case parse (spaceConsumer *> many (sexpr <* spaceConsumer) <* eof)
             "<input>" src of
    Left e  -> Left (errorBundlePretty e)
    Right v -> Right v

sexpr :: Parser SExpr
sexpr = spaceConsumer *> (atom <|> list) <* spaceConsumer

atom :: Parser SExpr
atom = boolAtom <|> intAtom <|> symbolAtom

boolAtom :: Parser SExpr
boolAtom = (string "#t" >> pure (SBool True))
       <|> (string "#f" >> pure (SBool False))

intAtom :: Parser SExpr
intAtom = SInt <$> (try negativeInt <|> positiveInt)
  where
    negativeInt = do
      char '-'
      digits <- some digitChar
      return (-(read digits))
    positiveInt = do
      optional (char '+')
      read <$> some digitChar

symbolAtom :: Parser SExpr
symbolAtom = SSymbol <$> some (oneOf validSymbolChars)
  where
    validSymbolChars = "+-*/<>=!?" ++
                       "abcdefghijklmnopqrstuvwxyz" ++
                       "ABCDEFGHIJKLMNOPQRSTUVWXYZ_"

list :: Parser SExpr
list = do
  char '('
  spaceConsumer
  xs <- many (sexpr <* spaceConsumer)
  char ')'
  return (SList xs)

spaceConsumer :: Parser ()
spaceConsumer = L.space (void $ oneOf " \t\n") empty empty