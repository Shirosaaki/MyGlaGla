{-# LANGUAGE OverloadedStrings #-}
module WaifuLang.Parser (parseSExprEither, parseSExprMultipleEither) where

import Control.Monad (void)
import Data.Void
import Text.Megaparsec
import Text.Megaparsec.Char
import qualified Text.Megaparsec.Char.Lexer as L
import AST (SExpr(..))

type Parser = Parsec Void String

-- ============================================================================
-- LEXER
-- ============================================================================

sc :: Parser ()
sc = L.space space1 (L.skipLineComment "#") (L.skipBlockComment "/*" "*/")

lexeme :: Parser a -> Parser a
lexeme = L.lexeme sc

symbol :: String -> Parser String
symbol = L.symbol sc

reserved :: String -> Parser ()
reserved w = void . lexeme . try $ string w *> notFollowedBy (alphaNumChar <|> char '_')

dot :: Parser ()
dot = void (symbol ".")

keywords :: [String]
keywords =
  [ "thinks", "that", "so", "and", "or", "is", "nickname", "takes"
  , "perform", "until", "will", "finish", "say", "leave", "leaves", "different"
  , "something", "operate", "incremented", "by", "each", "time", "equal"
  , "equals", "greater", "lower", "than", "to", "with", "doesn't", "have"
  , "has", "nothing", "a", "an", "about", "borns", "view", "get", "gets", "Albedo"
  ]

identifier :: Parser String
identifier = (lexeme . try) $ do
  name <- (:) <$> (letterChar <|> char '_') <*> many (alphaNumChar <|> char '_')
  if name `elem` keywords
    then fail $ "mot réservé : " ++ name
    else return name

-- ============================================================================
-- EXPRESSIONS & CALLS (me attack / test 5)
-- ============================================================================

parseExpression :: Parser SExpr
parseExpression = parseAddSub

parseAddSub :: Parser SExpr
parseAddSub = do
  left <- parseMulDiv
  parseAddSubRest left
  where
    parseAddSubRest acc = do
      op <- optional . try $ choice [symbol "+", symbol "-"]
      case op of
        Nothing -> return acc
        Just o  -> do
          right <- parseMulDiv
          parseAddSubRest (SList [SSymbol o, acc, right])

parseMulDiv :: Parser SExpr
parseMulDiv = do
  left <- parseCall
  parseMulDivRest left
  where
    parseMulDivRest acc = do
      op <- optional . try $ choice [symbol "*", symbol "/"]
      case op of
        Nothing -> return acc
        Just o  -> do
          right <- parseCall
          parseMulDivRest (SList [SSymbol o, acc, right])

parseCall :: Parser SExpr
parseCall = do
  atoms <- some (try parseAtom)
  case atoms of
    -- Cas me attack -> (call attack (me))
    [SSymbol id1, SSymbol id2] -> 
        return $ SList [SSymbol "call", SSymbol id2, SList [SSymbol id1]]
    -- Cas me walks 50 20 -> (call walks (me 50 20))
    (SSymbol id1 : SSymbol id2 : rest) -> 
        return $ SList [SSymbol "call", SSymbol id2, SList (SSymbol id1 : rest)]
    -- Cas ba 5 -> (call ba (5))
    (SSymbol id1 : rest) -> 
        if null rest then return (SSymbol id1)
        else return $ SList [SSymbol "call", SSymbol id1, SList rest]
    [single] -> return single
    _ -> fail "Expression invalide"

parseAtom :: Parser SExpr
parseAtom = choice
  [ try (SFloat <$> lexeme L.float)
  , try (SInt . fromIntegral <$> (lexeme L.decimal :: Parser Integer))
  , try (symbol "(" *> parseExpression <* symbol ")")
  , SString <$> (char '"' *> manyTill L.charLiteral (char '"') <* sc)
  , SChar   <$> (char '\'' *> L.charLiteral <* char '\'' <* sc)
  , SSymbol <$> identifier
  ]

-- ============================================================================
-- STATEMENTS
-- ============================================================================

parseStatement :: Parser SExpr
parseStatement = sc >> choice
  [ try parseClass
  , try parseIf
  , try parseWhile
  , try parseFunctionDef
  , try parseVariable
  , try parseNewInstance
  , try parseAssignment
  , try parsePrint
  , try parseExit
  , try (parseExpression <* dot)
  ]

parseBody :: Parser SExpr
parseBody = choice
  [ do
      _ <- optional (symbol ":")
      sc
      stmts <- some . try $ sc >> symbol "-" >> parseStatement
      return $ SList (SSymbol "block" : stmts)
  , do
      stmt <- parseStatement
      return $ SList [SSymbol "block", stmt]
  ]

parseMethodBody :: Parser SExpr
parseMethodBody = choice
  [ do
      _ <- optional (reserved "so")
      _ <- optional (symbol ":")
      sc
      stmts <- some . try $ sc >> string "--" >> sc >> parseStatement
      return $ SList (SSymbol "block" : stmts)
  , do
      _ <- optional (reserved "so")
      stmt <- parseStatement
      return $ SList [SSymbol "block", stmt]
  ]

-- ============================================================================
-- OOP LOGIC
-- ============================================================================

parseClass :: Parser SExpr
parseClass = do
  _         <- identifier
  reserved "is"
  _         <- reserved "a" <|> reserved "an"
  className <- identifier
  reserved "and" >> reserved "about"
  pronoun   <- identifier
  _         <- optional (symbol ":")
  sc
  members   <- many . try $ sc >> symbol "-" >> parseClassMember pronoun
  return $ SList ([SSymbol "class", SSymbol className] ++ members)

parseClassMember :: String -> Parser SExpr
parseClassMember p = choice [try (parseField p), try (parseMethod p)]

parseField :: String -> Parser SExpr
parseField pronoun = do
  reserved pronoun >> reserved "has"
  firstId <- identifier
  mSecondId <- optional (try identifier)
  let (fld, mTy) = case mSecondId of { Just s -> (s, Just firstId); Nothing -> (firstId, Nothing) }
  reserved "equal" >> reserved "to"
  val <- parseExpression <* dot
  return $ SList [SSymbol "field", SSymbol fld, val, SSymbol (maybe "int" id mTy)]

parseMethod :: String -> Parser SExpr
parseMethod pronoun = do
  reserved "When" >> reserved pronoun
  mName <- (reserved "borns" >> return "borns") <|> identifier
  params <- parseParamList pronoun
  body <- parseMethodBody
  -- FIX: Structure de sortie conforme au compilateur
  if mName == "borns"
    then return $ SList [SSymbol "constructor", SList (SSymbol "params" : params), body]
    else return $ SList [SSymbol "method", SSymbol mName, SList (SSymbol "params" : params), body]

parseParamList :: String -> Parser [SExpr]
parseParamList pronoun = option [] $ try $ do
  _ <- optional (symbol ",")
  _ <- optional (try (reserved pronoun))
  _ <- reserved "view" <|> reserved "gets" <|> reserved "get"
  parseOneParam `sepBy` reserved "and"
  where
    parseOneParam = do
      firstId <- identifier
      mSecondId <- optional (try identifier)
      case mSecondId of
        Just s  -> return $ SList [SSymbol s, SSymbol firstId]
        Nothing -> return $ SList [SSymbol firstId, SSymbol "int"]

parseFunctionDef :: Parser SExpr
parseFunctionDef = do
  _ <- identifier
  reserved "nickname" >> reserved "is"
  fName <- identifier
  reserved "and" >> reserved "takes"
  params <- (identifier `sepBy` reserved "and") <|> (reserved "nothing" >> return [])
  _ <- optional dot
  body <- parseStatement
  let lambda = SList [SSymbol "lambda", SList (map SSymbol params), body]
  return $ SList [SSymbol "define", SSymbol fName, lambda, SSymbol "void"]

parseVariable :: Parser SExpr
parseVariable = do
  _ <- identifier
  reserved "doesn't" >> reserved "have" >> reserved "nickname"
  _ <- optional . try $ do
      reserved "and"
      void (reserved "has" >> identifier) <|> void (reserved "takes" >> reserved "nothing")
  dot
  return $ SList [SSymbol "block"]

parseNewInstance :: Parser SExpr
parseNewInstance = do
  className <- identifier
  reserved "has" >> reserved "nickname"
  varName   <- identifier
  reserved "and" >> reserved "borns"
  args <- option [] $ try $ reserved "and" >> (reserved "get" <|> reserved "gets") >> (parseExpression `sepBy` reserved "and")
  dot
  return $ SList [SSymbol "define", SSymbol varName,
                  SList [SSymbol "call", SSymbol (className ++ "_new"), SList args],
                  SSymbol className]

-- ============================================================================
-- ACTIONS
-- ============================================================================

parseAssignment :: Parser SExpr
parseAssignment = do
  v <- identifier
  reserved "takes"
  val <- parseExpression <* dot
  return $ SList [SSymbol "assign", SSymbol v, val]

parsePrint :: Parser SExpr
parsePrint = do
  _ <- identifier >> reserved "say"
  expr <- parseExpression <* dot
  return $ SList [SSymbol "call", SSymbol "peric", SList [expr]]

parseExit :: Parser SExpr
parseExit = do
  reserved "Albedo"
  _ <- optional (try (void (reserved "leaves") >> void (reserved "with")))
  val <- parseExpression <* dot
  return $ SList [SSymbol "return", val]

parseReturn :: Parser SExpr
parseReturn = do
  _ <- identifier
  reserved "leave" <|> reserved "leaves"
  _ <- optional (reserved "with")
  expr <- parseExpression <* dot
  return $ SList [SSymbol "return", expr]

parseIf :: Parser SExpr
parseIf = do
  _ <- identifier >> reserved "thinks"
  cond <- (optional (reserved "that") *> parseFullCondition)
  reserved "so" >> parseBody >>= \b -> return $ SList [SSymbol "if", cond, b, SList []]

parseWhile :: Parser SExpr
parseWhile = do
  waifu <- identifier
  reserved "perform" >> reserved "until"
  cond <- parseFullCondition <* dot
  body <- manyTill (sc >> parseStatement) (try $ reserved waifu >> reserved "finish")
  return $ SList [SSymbol "call", SSymbol "while", SList [cond, SList (SSymbol "block" : body)]]

parseFullCondition :: Parser SExpr
parseFullCondition = do
  left <- parseExpression
  op <- optional . try $ (many (reserved "is" <|> reserved "that") >> parseComparisonOp)
  case op of
    Nothing -> return left
    Just o  -> parseExpression >>= \right -> return $ SList [SSymbol o, left, right]

parseComparisonOp :: Parser String
parseComparisonOp = choice $ map try
  [ reserved "greater" *> reserved "or" *> reserved "equal" *> reserved "to" *> return ">="
  , reserved "lower"   *> reserved "or" *> reserved "equal" *> reserved "to" *> return "<="
  , reserved "greater" *> reserved "than" *> return ">"
  , reserved "lower"   *> reserved "than" *> return "<"
  , (reserved "equals" <|> reserved "equal") *> reserved "to" *> return "=="
  , reserved "equals" *> return "=="
  , reserved "equal"  *> return "=="
  , reserved "is"     *> return "=="
  , symbol "==" *> return "=="
  , symbol "="  *> return "=="
  ]

-- ============================================================================
-- EXPORTS
-- ============================================================================

parseSExprEither :: String -> Either String SExpr
parseSExprEither src = case parse (sc >> parseStatement <* eof) "<waifu>" src of
  Left err -> Left (errorBundlePretty err)
  Right v  -> Right v

parseSExprMultipleEither :: String -> Either String [SExpr]
parseSExprMultipleEither src = case parse (sc >> many (sc >> parseStatement) <* sc <* eof) "<waifu>" src of
  Left err -> Left (errorBundlePretty err)
  Right v  -> Right v