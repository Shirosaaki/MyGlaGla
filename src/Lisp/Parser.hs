{-
-- EPITECH PROJECT, 2025
-- Parser (Lisp/Scheme style)
-- File description:
-- Parsing with Megaparsec (Lisp flavor)
-}
module Lisp.Parser (parseSExpr, parseSExprEither, parseSExprMultiple, parseSExprMultipleEither) where

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
atom = boolAtom <|> charAtom <|> stringAtom <|>
       try floatAtom <|> try intAtom <|> symbolAtom

boolAtom :: Parser SExpr
boolAtom = (string "#t" >> pure (SBool True))
       <|> (string "#f" >> pure (SBool False))

-- | Parse character literals: #\a, #\newline, #\space, etc.
charAtom :: Parser SExpr
charAtom = do
  _ <- try (string "#\\")
  c <- satisfy (const True)
  return (SChar c)

-- | Parse string literals: "hello"
stringAtom :: Parser SExpr
stringAtom = do
  _ <- char '"'
  chars <- many (noneOf "\"")
  _ <- char '"'
  return (SString chars)

negativeInt :: Parser Int
negativeInt = do
  _ <- char '-'
  _ <- lookAhead digitChar  -- Vérifie qu'il y a un chiffre après
  digits <- some digitChar
  return (-(read digits))

positiveInt :: Parser Int
positiveInt = do
  _ <- char '+'
  _ <- lookAhead digitChar  -- Vérifie qu'il y a un chiffre après
  digits <- some digitChar
  return (read digits)

unsignedInt :: Parser Int
unsignedInt = read <$> some digitChar

-- | Parse floating point numbers: 3.14, -2.5, etc.
floatAtom :: Parser SExpr
floatAtom = do
  sign <- option "" (string "-" <|> string "+")
  intPart <- some digitChar
  _ <- char '.'
  fracPart <- some digitChar
  let floatStr = sign ++ intPart ++ "." ++ fracPart
  return (SFloat (read floatStr))

intAtom :: Parser SExpr
intAtom = SInt <$> (try negativeInt <|> try positiveInt <|> unsignedInt)

symbolAtom :: Parser SExpr
symbolAtom = do
    first <- oneOf validFirstChars
    rest <- many (oneOf validRestChars)
    return $ SSymbol (first : rest)
  where
    validFirstChars = "+-*/<>=!?" ++
                      "abcdefghijklmnopqrstuvwxyz" ++
                      "ABCDEFGHIJKLMNOPQRSTUVWXYZ_"
    validRestChars = validFirstChars ++ "0123456789"

list :: Parser SExpr
list = do
  _ <- char '('
  spaceConsumer
  xs <- many (sexpr <* spaceConsumer)
  _ <- char ')'
  return (SList xs)

-- | Space consumer that also skips comments
-- Comments in Scheme start with ';' and go to end of line
spaceConsumer :: Parser ()
spaceConsumer = L.space
  (void $ oneOf " \t\n\r")
  lineComment
  empty

lineComment :: Parser ()
lineComment = try (L.skipLineComment "desnote") <|> L.skipLineComment ";"
