{-
-- EPITECH PROJECT, 2025
-- GlaGla [WSL: Debian]
-- File description:
-- TheShowLang Parser
-}

module Theshow.Parser (
  parseSExpr,
  parseSExprEither,
  parseSExprMultiple,
  parseSExprMultipleEither,
  parseStmt,
  parseIf,
  parseWhile,
  parseFor,
  parseDef,
  parseFuncCall,
  parseType
) where

import AST (SExpr(..))

import Text.Megaparsec
import Text.Megaparsec.Char
import qualified Text.Megaparsec.Char.Lexer as L
import Data.Void (Void)
import Control.Monad (void)
import Data.Maybe (fromMaybe)

type Parser = Parsec Void String

-- ============================================================================
-- Public API
-- ============================================================================

parseSExprEither :: String -> Either String SExpr
parseSExprEither src =
  case parse (spaceConsumer *> parseStmt <* eof) "<input>" src of
    Left e  -> Left (errorBundlePretty e)
    Right v -> Right v

parseSExpr :: String -> Maybe SExpr
parseSExpr s = either (const Nothing) Just (parseSExprEither s)

parseSExprMultiple :: String -> Maybe [SExpr]
parseSExprMultiple s = either (const Nothing) Just (parseSExprMultipleEither s)

parseSExprMultipleEither :: String -> Either String [SExpr]
parseSExprMultipleEither src =
  case parse (spaceConsumer *> many (parseStmt <* spaceConsumer) <* eof)
             "<input>" src of
    Left e  -> Left (errorBundlePretty e)
    Right v -> Right v

-- ============================================================================
-- Whitespace & Comments
-- ============================================================================

spaceConsumer :: Parser ()
spaceConsumer = L.space
  (void $ oneOf " \t\n\r")
  lineComment
  empty

lineComment :: Parser ()
lineComment = try (L.skipLineComment "desnote") <|> L.skipLineComment ";"

-- ============================================================================
-- Basic Atoms
-- ============================================================================

atom :: Parser SExpr
atom = try floatAtom <|> try intAtom <|> try stringAtom <|> symbolAtom

floatAtom :: Parser SExpr
floatAtom = do
  sign <- optional (char '-' <|> char '+')
  whole <- some digitChar
  _ <- char '.'
  frac <- some digitChar
  let numStr = maybe "" (:[]) sign ++ whole ++ "." ++ frac
  return $ SList [SSymbol "float", SSymbol numStr]

intAtom :: Parser SExpr
intAtom = SInt <$> (try negativeInt <|> try positiveInt <|> unsignedInt)
  where
    negativeInt = char '-' >> some digitChar >>= \d -> return (-(read d))
    positiveInt = char '+' >> some digitChar >>= \d -> return (read d)
    unsignedInt = read <$> some digitChar

stringAtom :: Parser SExpr
stringAtom = do
  _ <- char '"'
  content <- many (noneOf "\"")
  _ <- char '"'
  return $ SList [SSymbol "string", SSymbol content]

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

identifier :: Parser String
identifier = do
    first <- oneOf validFirstChars
    rest <- many (oneOf validRestChars)
    return (first : rest)
  where
    validFirstChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"
    validRestChars = validFirstChars ++ "0123456789"

-- ============================================================================
-- Types
-- ============================================================================

-- | Parse type annotations: int, float, string, int[], int*, Personne, etc.
parseType :: Parser SExpr
parseType = do
  base <- identifier
  suffix <- optional (try (string "[]") <|> try (string "*"))
  case suffix of
    Just "[]" -> return $ SList [SSymbol "array-type", SSymbol base]
    Just "*"  -> return $ SList [SSymbol "pointer-type", SSymbol base]
    _         -> return $ SSymbol base

-- ============================================================================
-- Expressions
-- ============================================================================

-- | Parse a parenthesized expression
parenExpr :: Parser SExpr
parenExpr = do
  _ <- char '('
  spaceConsumer
  e <- parseExpr
  spaceConsumer
  _ <- char ')'
  return e

-- | Parse primary expressions (atoms, parens, array/member access)
parsePrimary :: Parser SExpr
parsePrimary = do
  base <- parenExpr <|> atom
  parseAccessChain base

-- | Parse array indexing and member access chains: x[0], p.name, arr[i].field
parseAccessChain :: SExpr -> Parser SExpr
parseAccessChain base = do
  access <- optional (try parseArrayAccess <|> try parseMemberAccess)
  case access of
    Nothing -> return base
    Just accessFn -> parseAccessChain (accessFn base)
  where
    parseArrayAccess = do
      _ <- char '['
      spaceConsumer
      idx <- parseExpr
      spaceConsumer
      _ <- char ']'
      return $ \b -> SList [SSymbol "array-access", b, idx]
    parseMemberAccess = do
      _ <- char '.'
      field <- identifier
      return $ \b -> SList [SSymbol "member-access", b, SSymbol field]

-- | Parse binary operators with precedence
parseExpr :: Parser SExpr
parseExpr = parseComparison

parseComparison :: Parser SExpr
parseComparison = do
  left <- parseAddSub
  rest <- optional (try $ do
    spaceConsumer
    op <- choice
      [ try (string "<=") >> return "<="
      , try (string ">=") >> return ">="
      , try (string "==") >> return "=="
      , try (string "!=") >> return "!="
      , string "<" >> return "<"
      , string ">" >> return ">"
      ]
    spaceConsumer
    right <- parseAddSub
    return (op, right))
  case rest of
    Nothing -> return left
    Just (op, right) -> return $ SList [SSymbol op, left, right]

parseAddSub :: Parser SExpr
parseAddSub = do
  left <- parseMulDiv
  parseAddSubRest left

parseAddSubRest :: SExpr -> Parser SExpr
parseAddSubRest left = do
  rest <- optional (try $ do
    spaceConsumer
    op <- (char '+' >> return "+") <|> (char '-' >> return "-")
    spaceConsumer
    right <- parseMulDiv
    return (op, right))
  case rest of
    Nothing -> return left
    Just (op, right) -> parseAddSubRest $ SList [SSymbol op, left, right]

parseMulDiv :: Parser SExpr
parseMulDiv = do
  left <- parseUnary
  parseMulDivRest left

parseMulDivRest :: SExpr -> Parser SExpr
parseMulDivRest left = do
  rest <- optional (try $ do
    spaceConsumer
    op <- (char '*' >> return "*") <|> (char '/' >> return "/")
    spaceConsumer
    right <- parseUnary
    return (op, right))
  case rest of
    Nothing -> return left
    Just (op, right) -> parseMulDivRest $ SList [SSymbol op, left, right]

parseUnary :: Parser SExpr
parseUnary = parseDeref <|> parseAddrOf <|> parsePrimary

-- | Dereference: *ptr
parseDeref :: Parser SExpr
parseDeref = do
  _ <- char '*'
  e <- parsePrimary
  return $ SList [SSymbol "deref", e]

-- | Address-of: &var
parseAddrOf :: Parser SExpr
parseAddrOf = do
  _ <- char '&'
  e <- parsePrimary
  return $ SList [SSymbol "addr-of", e]

-- ============================================================================
-- Statements
-- ============================================================================

parseStmt :: Parser SExpr
parseStmt = choice
  [ try parseEnum
  , try parseStruct
  , try parseFuncDef
  , try parseDef
  , try parseAssign
  , try parseArrayDecl
  , try parseIf
  , try parseWhile
  , try parseFor
  , try parseReturn
  , try parsePrint
  , try parseFuncCall
  , parseExpr
  ]

-- | Enum: desnum Status: Inactive Active Graduated
parseEnum :: Parser SExpr
parseEnum = do
  _ <- string "desnum"
  spaceConsumer
  name <- identifier
  _ <- char ':'
  spaceConsumer
  values <- many (identifier <* spaceConsumer)
  return $ SList ([SSymbol "enum", SSymbol name] ++ map SSymbol values)

-- | Struct: destruct Personne: nom -> string age -> int
parseStruct :: Parser SExpr
parseStruct = do
  _ <- string "destruct"
  spaceConsumer
  name <- identifier
  _ <- char ':'
  spaceConsumer
  fields <- many parseStructField
  return $ SList ([SSymbol "struct", SSymbol name] ++ fields)

parseStructField :: Parser SExpr
parseStructField = do
  fname <- identifier
  spaceConsumer
  _ <- string "->"
  spaceConsumer
  ftype <- parseType
  spaceConsumer
  return $ SList [SSymbol fname, ftype]

-- | Variable definition: eric x = 5 -> int  OR  eric x -> int
parseDef :: Parser SExpr
parseDef = do
  _ <- string "eric"
  spaceConsumer
  name <- identifier
  spaceConsumer
  defBody <- try parseDefWithValue <|> parseDefWithoutValue
  return $ defBody name

parseDefWithValue :: Parser (String -> SExpr)
parseDefWithValue = do
  _ <- char '='
  spaceConsumer
  value <- parseExpr
  spaceConsumer
  _ <- string "->"
  spaceConsumer
  ty <- parseType
  return $ \name -> SList [SSymbol "define", SSymbol name, value, ty]

parseDefWithoutValue :: Parser (String -> SExpr)
parseDefWithoutValue = do
  _ <- string "->"
  spaceConsumer
  ty <- parseType
  return $ \name -> SList [SSymbol "define", SSymbol name, ty]

-- | Array declaration: eric nu -> int[]  then  nu[0] -> int[]
parseArrayDecl :: Parser SExpr
parseArrayDecl = do
  name <- identifier
  _ <- char '['
  spaceConsumer
  idx <- parseExpr
  spaceConsumer
  _ <- char ']'
  spaceConsumer
  _ <- string "->"
  spaceConsumer
  ty <- parseType
  return $ SList [SSymbol "array-decl", SSymbol name, idx, ty]

-- | Assignment: x = 5  OR  arr[0] = 10  OR  p.name = "Alice"
parseAssign :: Parser SExpr
parseAssign = do
  target <- parsePrimary
  spaceConsumer
  _ <- char '='
  spaceConsumer
  value <- parseExpr
  return $ SList [SSymbol "assign", target, value]

-- | If statement: erif (cond): thenBranch [deschelse: elseBranch]
parseIf :: Parser SExpr
parseIf = do
  _ <- string "erif"
  spaceConsumer
  _ <- char '('
  spaceConsumer
  cond <- parseExpr
  spaceConsumer
  _ <- char ')'
  _ <- char ':'
  spaceConsumer
  thenBranch <- parseBlock
  elseBranch <- optional $ do
    spaceConsumer
    _ <- string "deschelse"
    _ <- char ':'
    spaceConsumer
    parseBlock
  return $ SList [SSymbol "if", cond, SList thenBranch,
                  SList (fromMaybe [] elseBranch)]

-- | While loop: darius (cond): body
parseWhile :: Parser SExpr
parseWhile = do
  _ <- string "darius"
  spaceConsumer
  _ <- char '('
  spaceConsumer
  cond <- parseExpr
  spaceConsumer
  _ <- char ')'
  _ <- char ':'
  spaceConsumer
  body <- parseBlock
  return $ SList [SSymbol "while", cond, SList body]

-- | For loop: aer i in range(start, end): body
parseFor :: Parser SExpr
parseFor = do
  _ <- string "aer"
  spaceConsumer
  var <- identifier
  spaceConsumer
  _ <- string "in"
  spaceConsumer
  _ <- string "range("
  spaceConsumer
  start <- parseExpr
  spaceConsumer
  _ <- char ','
  spaceConsumer
  end <- parseExpr
  spaceConsumer
  _ <- char ')'
  _ <- char ':'
  spaceConsumer
  body <- parseBlock
  return $ SList [SSymbol "for", SSymbol var, start, end, SList body]

-- | Return statement: deschodt value
parseReturn :: Parser SExpr
parseReturn = do
  _ <- string "deschodt"
  spaceConsumer
  value <- parseExpr
  return $ SList [SSymbol "return", value]

-- | Print statement: peric("message {var}")
parsePrint :: Parser SExpr
parsePrint = do
  _ <- string "peric("
  _ <- char '"'
  content <- many (noneOf "\"")
  _ <- char '"'
  _ <- char ')'
  return $ SList [SSymbol "call", SSymbol "peric", SList [SString content]]

-- | Function definition: Deschodt funcName(params) -> retType body
parseFuncDef :: Parser SExpr
parseFuncDef = do
  _ <- string "Deschodt"
  spaceConsumer
  name <- identifier
  _ <- char '('
  spaceConsumer
  params <- parseParams
  _ <- char ')'
  spaceConsumer
  retType <- optional $ do
    _ <- string "->"
    spaceConsumer
    parseType
  spaceConsumer
  body <- parseBlock
  -- Convert to (fun name params retType body)
  let ret = case retType of
              Just t -> t
              Nothing -> SSymbol "void"
  return $ SList [SSymbol "fun", SSymbol name, SList params, ret, SList body]

-- | Parse function parameters: (a -> int, b -> int)
parseParams :: Parser [SExpr]
parseParams = sepBy parseParam (char ',' >> spaceConsumer)

parseParam :: Parser SExpr
parseParam = do
  pname <- identifier
  spaceConsumer
  _ <- string "->"
  spaceConsumer
  ty <- parseType
  spaceConsumer
  return $ SList [SSymbol pname, ty]

-- | Function call: funcName(arg1, arg2)
parseFuncCall :: Parser SExpr
parseFuncCall = do
  name <- identifier
  _ <- char '('
  spaceConsumer
  args <- sepBy parseExpr (char ',' >> spaceConsumer)
  _ <- char ')'
  return $ SList ([SSymbol "call", SSymbol name, SList args])

-- | Parse a block of statements (indentation-based)
parseBlock :: Parser [SExpr]
parseBlock = many $ try $ do
  spaceConsumer
  parseStmt
