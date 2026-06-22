{-# LANGUAGE OverloadedStrings #-}
module WaifuLang.Parser (parseSExprEither, parseSExprMultipleEither) where

import Control.Monad (void)
import Data.Void
import Data.Maybe (fromMaybe)
import Text.Megaparsec
import Text.Megaparsec.Char
import qualified Text.Megaparsec.Char.Lexer as L
import AST (SExpr(..))

type Parser = Parsec Void String

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
  , "adds", "removes", "after", "first", "second", "third", "fourth", "fifth"
  , "sixth", "seventh", "eighth", "ninth", "tenth", "at", "position", "on", "in"
  , "contains", "empty", "length", "split", "puts", "the", "Darkness"
  ]

identifier :: Parser String
identifier = (lexeme . try) $ do
  name <- (:) <$> (letterChar <|> char '_') <*> many (alphaNumChar <|> char '_')
  if name `elem` keywords
    then fail $ "mot réservé : " ++ name
    else return name

ordinalWord :: Parser Int
ordinalWord = choice
  [ reserved "first"  >> return 1, reserved "second" >> return 2
  , reserved "third"  >> return 3, reserved "fourth" >> return 4
  , reserved "fifth"  >> return 5, reserved "sixth"  >> return 6
  , reserved "seventh" >> return 7, reserved "eighth" >> return 8
  , reserved "ninth"  >> return 9, reserved "tenth"  >> return 10
  ]

parseIndex :: Parser SExpr
parseIndex = choice
  [ try $ do _ <- optional (reserved "the"); o <- ordinalWord; optional (reserved "position"); return (SInt (o - 1))
  , parseExpression
  ]

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
  left <- parsePostfix
  parseMulDivRest left
  where
    parseMulDivRest acc = do
      op <- optional . try $ choice [symbol "*", symbol "/"]
      case op of
        Nothing -> return acc
        Just o  -> do
          right <- parsePostfix
          parseMulDivRest (SList [SSymbol o, acc, right])

parsePostfix :: Parser SExpr
parsePostfix = do
  base <- parsePrimary
  post <- optional $ try $ choice
    [ reserved "length" >> return (SSymbol "str-len")
    , reserved "split" >> reserved "by" >> parseExpression >>= \s -> return (SList [SSymbol "str-split", s])
    ]
  case post of
    Nothing -> return base
    Just (SSymbol "str-len") -> return $ SList [SSymbol "str-len", base]
    Just (SList [SSymbol "str-split", sep]) -> return $ SList [SSymbol "str-split", base, sep]
    _ -> return base

parsePrimary :: Parser SExpr
parsePrimary = choice
  [ try parseAtAccess
  , parseCall
  ]

parseAtAccess :: Parser SExpr
parseAtAccess = do
  v <- identifier
  reserved "at"
  idx <- parseIndex
  return $ SList [SSymbol "list-at", SSymbol v, idx]

parseCall :: Parser SExpr
parseCall = do
  atoms <- some (try parseAtom)
  case atoms of
    [SSymbol id1, SSymbol id2] ->
        return $ SList [SSymbol "call", SSymbol id2, SList [SSymbol id1]]
    (SSymbol id1 : SSymbol id2 : rest) ->
        return $ SList [SSymbol "call", SSymbol id2, SList (SSymbol id1 : rest)]
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
  , try (reserved "nothing" >> return (SSymbol "nothing"))
  , SSymbol <$> identifier
  ]

-- ============================================================================
-- STATEMENTS
-- ============================================================================

parseStatement :: Parser SExpr
parseStatement = sc >> choice
  [ try parseClass
  , try parseIf
  , try parseForEach
  , try parseFor
  , try parseWhile
  , try parseFunctionDef
  , try parseVariable
  , try parseNewInstance
  , try parseMapPut
  , try parseListRemove
  , try parseMapRemove
  , try parseListAdd
  , try parseAssignment
  , try parseDarknessPrint
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
-- OOP
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
  choice
    [ try (parseConstBinding fName)
    , parseLambdaBinding fName
    ]

parseConstBinding :: String -> Parser SExpr
parseConstBinding fName = do
  val <- choice
    [ try (SFloat <$> lexeme L.float)
    , try (SInt . fromIntegral <$> (lexeme L.decimal :: Parser Integer))
    , SString <$> (char '"' *> manyTill L.charLiteral (char '"') <* sc)
    , SChar <$> (char '\'' *> L.charLiteral <* char '\'' <* sc)
    , reserved "nothing" >> return (SSymbol "nothing")
    ]
  dot
  return $ SList [SSymbol "assign", SSymbol fName, val]

parseLambdaBinding :: String -> Parser SExpr
parseLambdaBinding fName = do
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
-- LISTS & MAPS
-- ============================================================================

parseTakesValue :: Parser SExpr
parseTakesValue = parseExpression

parseAssignment :: Parser SExpr
parseAssignment = do
  v <- identifier
  reserved "takes"
  first <- parseTakesValue
  mColon <- optional (try (symbol ":"))
  case mColon of
    Just _ -> do
      val1 <- parseTakesValue
      rest <- many (try (symbol "," >> parseMapPairFromKey))
      dot
      return $ SList (SSymbol "map-create" : SSymbol v : SList [first, val1] : rest)
    Nothing -> do
      isList <- optional (try (symbol ","))
      case isList of
        Nothing -> do
          dot
          return $ SList [SSymbol "assign", SSymbol v, first]
        Just _ -> do
          rest <- optional (parseTakesValue `sepBy` symbol ",")
          dot
          return $ SList (SSymbol "list-create" : SSymbol v : first : fromMaybe [] rest)

parseMapPairFromKey :: Parser SExpr
parseMapPairFromKey = do
  k <- parseTakesValue
  symbol ":"
  v <- parseTakesValue
  return $ SList [k, v]

parseListAdd :: Parser SExpr
parseListAdd = do
  listVar <- identifier
  reserved "adds"
  first <- parseAtom
  more <- many $ try $ do
    reserved "and"
    notFollowedBy (reserved "after")
    parseAtom
  modifier <- optional $ try parseAddModifier
  dot
  let items = first : more
  case modifier of
    Nothing -> return $ SList [SSymbol "list-add", SSymbol listVar, SSymbol "append", SList items]
    Just modS -> return $ SList [SSymbol "list-add", SSymbol listVar, modS, SList items]

parseAddModifier :: Parser SExpr
parseAddModifier = choice
  [ try (reserved "at" >> reserved "the" >> reserved "first" >> return (SSymbol "prepend"))
  , try parseInsertAfterModifier
  ]

parseInsertAfterModifier :: Parser SExpr
parseInsertAfterModifier = do
  reserved "after"
  nth <- optional (try (reserved "the" >> ordinalWord))
  target <- parseAtom
  return $ SList [SSymbol "insert-after", maybe (SInt 1) SInt nth, target]

parseListRemove :: Parser SExpr
parseListRemove = do
  listVar <- identifier
  reserved "removes"
  mode <- parseRemoveMode
  dot
  return $ SList [SSymbol "list-remove", SSymbol listVar, mode]

parseRemoveMode :: Parser SExpr
parseRemoveMode = choice
  [ try $ do
      reserved "at"
      reserved "the"
      o <- ordinalWord
      return $ SList [SSymbol "at-index", SInt (o - 1)]
  , try $ do
      reserved "after"
      optional (reserved "the")
      target <- parseExpression
      return $ SList [SSymbol "after-value", SInt 1, target]
  , try $ do
      reserved "the"
      o <- ordinalWord
      target <- parseExpression
      return $ SList [SSymbol "nth-value", SInt o, target]
  , do
      target <- parseExpression
      return $ SList [SSymbol "first-value", SInt 1, target]
  ]

parseMapPut :: Parser SExpr
parseMapPut = do
  v <- identifier
  reserved "puts"
  k <- parseExpression
  symbol ":"
  val <- parseTakesValue
  dot
  return $ SList [SSymbol "map-put", SSymbol v, k, val]

parseMapRemove :: Parser SExpr
parseMapRemove = do
  v <- identifier
  reserved "removes"
  k <- parseExpression
  dot
  return $ SList [SSymbol "map-remove", SSymbol v, k]

-- ============================================================================
-- ACTIONS
-- ============================================================================

parsePrint :: Parser SExpr
parsePrint = do
  _ <- identifier >> reserved "say"
  expr <- parseExpression <* dot
  return $ SList [SSymbol "call", SSymbol "peric", SList [expr]]

parseDarknessPrint :: Parser SExpr
parseDarknessPrint = do
  _ <- reserved "Darkness" >> reserved "say"
  expr <- parseExpression <* dot
  return $ SList [SSymbol "call", SSymbol "darkness", SList [expr]]

parseExit :: Parser SExpr
parseExit = do
  reserved "Albedo"
  _ <- optional (try (void (reserved "leaves") >> void (reserved "with")))
  val <- parseExpression <* dot
  return $ SList [SSymbol "return", val]

parseIf :: Parser SExpr
parseIf = do
  _ <- identifier >> reserved "thinks"
  cond <- (optional (reserved "that") *> parseFullCondition)
  reserved "so" >> parseBody >>= \b -> return $ SList [SSymbol "if", cond, b, SList []]

parseFor :: Parser SExpr
parseFor = do
  waifu <- identifier
  reserved "will" >> reserved "operate" >> reserved "until"
  _ <- try (reserved waifu >> reserved "nickname")
  v <- identifier
  reserved "equal" >> reserved "to"
  start <- parseExpression
  reserved "is" >> reserved "lower" >> reserved "than"
  limit <- parseExpression
  reserved "and" >> reserved "incremented" >> reserved "by" >> reserved "1"
  reserved "each" >> reserved "time" <* dot
  body <- manyTill (sc >> parseStatement) (try $ reserved waifu >> reserved "finish")
  _ <- reserved "to" >> reserved "operate" <* dot
  return $ SList [SSymbol "call", SSymbol "for", SList [SSymbol v, start, limit, SList (SSymbol "block" : body)]]

parseForEach :: Parser SExpr
parseForEach = do
  waifu <- identifier
  reserved "will" >> reserved "operate"
  reserved "on" >> reserved "each" >> optional (reserved "item") >> reserved "in"
  listVar <- identifier
  reserved "and" >> reserved "incremented" >> reserved "by" >> reserved "1"
  reserved "each" >> reserved "time" <* dot
  body <- manyTill (sc >> parseStatement) (try $ reserved waifu >> reserved "finish")
  _ <- reserved "to" >> reserved "operate" <* dot
  return $ SList [SSymbol "for-each", SSymbol "item", SSymbol listVar, SList (SSymbol "block" : body)]

parseWhile :: Parser SExpr
parseWhile = do
  waifu <- identifier
  reserved "perform" >> reserved "until"
  cond <- parseFullCondition <* dot
  body <- manyTill (sc >> parseStatement) (try $ reserved waifu >> reserved "finish")
  _ <- reserved "to" >> reserved "perform" <* dot
  return $ SList [SSymbol "call", SSymbol "while", SList [cond, SList (SSymbol "block" : body)]]

parseFullCondition :: Parser SExpr
parseFullCondition = choice
  [ try $ reserved "something" >> reserved "different" >> return (SInt 0)
  , try parseListMapCondition
  , try parseStrContainsCondition
  , do
      left <- parseExpression
      op <- optional . try $ (many (reserved "is" <|> reserved "that") >> parseComparisonOp)
      case op of
        Nothing -> return left
        Just o  -> parseExpression >>= \right -> return $ SList [SSymbol o, left, right]
  ]

parseListMapCondition :: Parser SExpr
parseListMapCondition = do
  v <- identifier
  choice
    [ try $ reserved "is" >> reserved "empty" >> return (SList [SSymbol "list-empty", SSymbol v])
    , try $ do
        reserved "contains"
        e <- parseExpression
        return $ SList [SSymbol "contains", SSymbol v, e]
    ]

parseStrContainsCondition :: Parser SExpr
parseStrContainsCondition = do
  s <- identifier
  reserved "contains"
  needle <- parseExpression
  return $ SList [SSymbol "str-contains", SSymbol s, needle]

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
