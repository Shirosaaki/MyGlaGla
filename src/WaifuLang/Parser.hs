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
  , "perform", "until", "will", "finish", "say", "leave", "different"
  , "something", "operate", "incremented", "by", "each", "time", "equal"
  , "equals", "greater", "lower", "than", "to", "with", "doesn't", "have"
  , "has", "nothing", "a", "an", "about", "borns", "view", "When", "get"
  , "Albedo"
  ]

identifier :: Parser String
identifier = (lexeme . try) $ do
  name <- (:) <$> (letterChar <|> char '_') <*> many (alphaNumChar <|> char '_')
  if name `elem` keywords
    then fail $ "mot réservé inattendu : " ++ name
    else return name

-- ============================================================================
-- EXPRESSIONS
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
  left <- parseAtom
  parseMulDivRest left
  where
    parseMulDivRest acc = do
      op <- optional . try $ choice [symbol "*", symbol "/"]
      case op of
        Nothing -> return acc
        Just o  -> do
          right <- parseAtom
          parseMulDivRest (SList [SSymbol o, acc, right])

parseAtom :: Parser SExpr
parseAtom = choice
  [ try (SFloat <$> lexeme L.float)
  , try (SInt . fromIntegral <$> (lexeme L.decimal :: Parser Integer))
  , SString <$> (char '"' *> manyTill L.charLiteral (char '"') <* sc)
  , SChar   <$> (char '\'' *> L.charLiteral <* char '\'' <* sc)
  , SSymbol <$> identifier
  ]

-- ============================================================================
-- CONDITIONS (Pour les IF et WHILE)
-- ============================================================================

parseFullCondition :: Parser SExpr
parseFullCondition = do
  left <- parseExpression
  op <- optional . try $ do
    _ <- many (reserved "is" <|> reserved "that")
    parseComparisonOp
  case op of
    Nothing -> return left
    Just o -> do
      right <- parseExpression
      return $ SList [SSymbol o, left, right]

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
-- STATEMENTS
-- ============================================================================

parseStatement :: Parser SExpr
parseStatement = sc >> choice
  [ try parseClass
  , try parseIf
  , try parseWhile
  , try parseNewInstance
  , try parseMethodCall
  , try parseVariable
  , try parseAssignment
  , try parsePrint
  , try parseReturn
  , try parseExit
  ]

parseBody :: Parser SExpr
parseBody = choice
  [ do
      _ <- symbol ":"
      sc
      stmts <- many . try $ sc >> symbol "-" >> parseStatement
      return $ SList (SSymbol "block" : stmts)
  , do
      stmt <- parseStatement
      return $ SList [SSymbol "block", stmt]
  ]

parseMethodBody :: Parser SExpr
parseMethodBody = do
  _ <- symbol ":"
  sc
  stmts <- many . try $ sc >> string "--" >> sc >> parseStatement
  return $ SList (SSymbol "block" : stmts)

-- ============================================================================
-- CLASSES & OOP
-- ============================================================================

parseClass :: Parser SExpr
parseClass = do
  _         <- identifier
  reserved "is"
  _         <- reserved "a" <|> reserved "an"
  className <- identifier
  reserved "and" *> reserved "about"
  pronoun   <- identifier
  _         <- symbol ":"
  sc
  members   <- many . try $ sc >> symbol "-" >> parseClassMember pronoun
  return $ SList ([SSymbol "class", SSymbol className] ++ members)

parseClassMember :: String -> Parser SExpr
parseClassMember pronoun = choice
  [ try (parseField pronoun)
  , try (parseMethod pronoun)
  ]

parseField :: String -> Parser SExpr
parseField pronoun = do
  reserved pronoun
  reserved "has"
  mType <- optional (try identifier)
  fieldName <- identifier
  reserved "equal" *> reserved "to"
  val <- parseExpression
  dot
  let ty = case mType of
             Just t  -> SSymbol t
             -- FIX: Wrapping "float" and "int" in SSymbol
             Nothing -> case val of { SFloat _ -> SSymbol "float"; _ -> SSymbol "int" }
  return $ SList [SSymbol "field", SSymbol fieldName, val, ty]

parseMethod :: String -> Parser SExpr
parseMethod pronoun = do
  reserved "When"
  reserved pronoun
  isCtor <- optional . try $ reserved "borns"
  case isCtor of
    Just () -> do
      params <- parseParamList
      _ <- optional (reserved "so") -- Ajout de _ <-
      body <- parseMethodBody
      return $ SList [SSymbol "constructor", SList (SSymbol "params" : params), body]
    Nothing -> do
      mName  <- identifier
      params <- parseParamList
      _ <- optional (reserved "so") -- Ajout de _ <-
      body <- parseMethodBody
      return $ SList [SSymbol "method", SSymbol mName, SList (SSymbol "params" : params), body]
      
parseParamList :: Parser [SExpr]
parseParamList = do
  hasParams <- optional . try $ reserved "view"
  case hasParams of
    Nothing -> return []
    Just () -> do
      p1   <- parseOneParam
      rest <- many . try $ reserved "and" >> parseOneParam
      return (p1 : rest)
  where
    parseOneParam = do
      mType <- optional (try identifier)
      pName <- identifier
      return $ SList [SSymbol pName, maybe (SSymbol "int") SSymbol mType]

parseNewInstance :: Parser SExpr
parseNewInstance = do
  className <- identifier
  reserved "has" *> reserved "nickname"
  varName   <- identifier
  reserved "and" *> reserved "borns"
  args <- option [] $ try $ reserved "and" *> reserved "get" *> (parseExpression `sepBy` reserved "and")
  dot
  return $ SList [SSymbol "define", SSymbol varName,
                  SList [SSymbol "call", SSymbol (className ++ "_new"), SList args],
                  SSymbol className]

parseMethodCall :: Parser SExpr
parseMethodCall = do
  varName <- identifier
  mName   <- identifier
  args    <- option [] $ try $ reserved "and" *> reserved "get" *> (parseExpression `sepBy` reserved "and")
  dot
  return $ SList [SSymbol "call", SSymbol mName, SList (SSymbol varName : args)]

-- ============================================================================
-- AUTRES STATEMENTS
-- ============================================================================

parseExit :: Parser SExpr
parseExit = do
  reserved "Albedo"
  val <- parseExpression
  dot
  return $ SList [SSymbol "return", val]

parseVariable :: Parser SExpr
parseVariable = do
  _ <- identifier
  res <- choice
    [ try $ do
        reserved "nickname" *> reserved "is"
        v <- identifier
        reserved "and" *> reserved "takes"
        val <- parseExpression
        return $ SList [SSymbol "define", SSymbol v, val, SSymbol "int"]
    , do
        reserved "doesn't" *> reserved "have" *> reserved "nickname"
        reserved "and" *> reserved "takes" *> reserved "nothing"
        return $ SList [SSymbol "block"]
    ]
  dot
  return res

parseAssignment :: Parser SExpr
parseAssignment = do
  v <- identifier
  reserved "takes"
  val <- parseExpression
  dot
  return $ SList [SSymbol "assign", SSymbol v, val]

parseIf :: Parser SExpr
parseIf = do
  _ <- identifier
  reserved "thinks"
  cond <- optional (reserved "that") *> parseFullCondition
  reserved "so"
  body <- parseBody
  return $ SList [SSymbol "if", cond, body, SList []]

parseWhile :: Parser SExpr
parseWhile = do
  waifu <- identifier
  reserved "perform"
  reserved "until"
  cond <- parseFullCondition
  dot
  body <- manyTill (sc >> parseStatement) (try $ reserved waifu >> reserved "finish")
  return $ SList [SSymbol "call", SSymbol "while", SList [cond, SList (SSymbol "block" : body)]]

parsePrint :: Parser SExpr
parsePrint = do
  _ <- identifier
  reserved "say"
  expr <- parseExpression
  dot
  return $ SList [SSymbol "call", SSymbol "peric", SList [expr]]

parseReturn :: Parser SExpr
parseReturn = do
  _ <- identifier
  reserved "leave" >> reserved "with"
  expr <- parseExpression
  dot
  return $ SList [SSymbol "return", expr]

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