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
  , "has", "nothing"
  -- Mots-clés OOP
  , "about", "borns", "view", "When", "moves"
  ]

identifier :: Parser String
identifier = (lexeme . try) $ do
  name <- (:) <$> (letterChar <|> char '_') <*> many (alphaNumChar <|> char '_')
  if name `elem` keywords
    then fail $ "mot réservé inattendu : " ++ name
    else return name

-- ============================================================================
-- HELPERS LEXICAUX
-- ============================================================================

-- Matche exactement "-" sans consommer "--"
dashOnly :: Parser ()
dashOnly = void . lexeme . try $ char '-' *> notFollowedBy (char '-')

-- Matche exactement "--" (corps de méthode)
dashDash :: Parser ()
dashDash = void . lexeme $ string "--"

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
-- CONDITIONS LOGIQUES
-- ============================================================================

parseFullCondition :: Parser SExpr
parseFullCondition = parseLogicOr Nothing

parseLogicOr :: Maybe SExpr -> Parser SExpr
parseLogicOr lastLeft = do
  left <- parseLogicAnd lastLeft
  rest <- optional . try $ reserved "or" >> parseLogicOr (extractLeft left)
  return $ case rest of
    Nothing    -> left
    Just right -> SList [SSymbol "||", left, right]

parseLogicAnd :: Maybe SExpr -> Parser SExpr
parseLogicAnd lastLeft = do
  left <- parseLogicAtom lastLeft
  rest <- optional . try $ reserved "and" >> optional (reserved "that") >> parseLogicAnd (extractLeft left)
  return $ case rest of
    Nothing    -> left
    Just right -> SList [SSymbol "&&", left, right]

parseLogicAtom :: Maybe SExpr -> Parser SExpr
parseLogicAtom lastLeft = choice
  [ try $ symbol "(" *> optional (reserved "that") *> parseFullCondition <* symbol ")"
  , parseSingleComparison lastLeft
  ]

extractLeft :: SExpr -> Maybe SExpr
extractLeft (SList [SSymbol op, l, _])
  | op `elem` ["==", "!=", "<", ">", "<=", ">="] = Just l
extractLeft _ = Nothing

parseSingleComparison :: Maybe SExpr -> Parser SExpr
parseSingleComparison lastLeft = choice
  [ try fullComparison
  , case lastLeft of
      Just l  -> shortComparison l
      Nothing -> fail "comparaison attendue"
  ]
  where
    fullComparison = do
      left  <- parseExpression
      _     <- many . try $ reserved "is" <|> reserved "that"
      op    <- parseComparisonOp
      right <- parseExpression
      return $ SList [SSymbol op, left, right]
    shortComparison left = do
      _     <- many . try $ reserved "is" <|> reserved "that"
      op    <- parseComparisonOp
      right <- parseExpression
      return $ SList [SSymbol op, left, right]

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
  [ try parseClass       -- avant les autres : "X nickname is Y and about Z :"
  , try parseIf
  , try parseFor
  , try parseWhile
  , try parseVariable
  , try parseAssignment
  , try parsePrint
  , try parseReturn
  ]

-- Bloc de niveau 1 : ":" suivi de "- stmt" répétés, ou stmt inline.
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

-- Bloc de niveau 2 (corps de méthode) : ":" suivi de "-- stmt" répétés.
-- Utilisé à l'intérieur d'une classe où "-" est déjà consommé par le membre.
parseMethodBody :: Parser SExpr
parseMethodBody = do
  _ <- symbol ":"
  sc
  stmts <- many . try $ sc >> dashDash >> parseStatement
  return $ SList (SSymbol "block" : stmts)

-- ============================================================================
-- IF / ELSE
-- ============================================================================

parseIf :: Parser SExpr
parseIf = do
  _    <- identifier
  reserved "thinks"
  cond <- optional (reserved "that") *> parseFullCondition
  reserved "so"
  body <- parseBody
  alt  <- parseAlt
  return $ SList [SSymbol "if", cond, body, alt]

parseAlt :: Parser SExpr
parseAlt = option (SList []) $ try parseElseDifferent

parseElseDifferent :: Parser SExpr
parseElseDifferent = do
  _ <- identifier
  reserved "thinks" *> reserved "something" *> reserved "different"
  reserved "so"
  body <- parseBody
  alt  <- parseAlt
  return $ SList [SSymbol "if", SList [SSymbol "==", SInt 1, SInt 1], body, alt]

-- ============================================================================
-- WHILE
-- ============================================================================

parseWhile :: Parser SExpr
parseWhile = do
  waifu <- identifier
  reserved "perform" *> reserved "until"
  cond  <- parseFullCondition
  dot
  body  <- manyTill (sc >> parseStatement) (try $ endWhile waifu)
  return $ SList [SSymbol "call", SSymbol "while",
                  SList [cond, SList (SSymbol "block" : body)]]
  where
    endWhile w =
      sc *> reserved w *> reserved "finish" *> reserved "to" *> reserved "perform" *> dot

-- ============================================================================
-- FOR
-- ============================================================================

parseFor :: Parser SExpr
parseFor = do
  waifu <- identifier
  reserved "will" *> reserved "operate" *> reserved "until"
  _     <- identifier
  reserved "nickname"
  v     <- identifier
  reserved "equal" *> reserved "to"
  start <- parseExpression
  _     <- many . try $ reserved "is" <|> reserved "that"
  _     <- parseComparisonOp
  limit <- parseExpression
  reserved "and" *> reserved "incremented" *> reserved "by"
  _     <- lexeme (L.decimal :: Parser Integer)
  reserved "each" *> reserved "time" *> dot
  body  <- manyTill (sc >> parseStatement) (try $ endFor waifu)
  return $ SList [SSymbol "call", SSymbol "for",
                  SList [SSymbol v, start, limit, SList (SSymbol "block" : body)]]
  where
    endFor w =
      sc *> reserved w *> reserved "finish" *> reserved "to" *> reserved "operate" *> dot

-- ============================================================================
-- VARIABLES & ASSIGNATION
-- ============================================================================

parseVariable :: Parser SExpr
parseVariable = do
  _ <- identifier
  res <- choice
    [ try $ do
        reserved "nickname" *> reserved "is"
        v <- identifier
        reserved "and" *> reserved "takes"
        r <- choice
          [ try (reserved "nothing") *> return (SList [SSymbol "define", SSymbol v, SSymbol "void"])
          , do
              val <- parseExpression
              let ty = case val of { SFloat _ -> "float"; _ -> "int" }
              return $ SList [SSymbol "define", SSymbol v, val, SSymbol ty]
          ]
        return r
    , do
        reserved "doesn't" *> reserved "have" *> reserved "nickname"
        reserved "and" *> reserved "has"
        v <- identifier
        return $ SList [SSymbol "define", SSymbol v, SSymbol "int"]
    ]
  dot
  return res

parseAssignment :: Parser SExpr
parseAssignment = do
  v   <- identifier
  reserved "takes"
  val <- parseExpression
  dot
  return $ SList [SSymbol "assign", SSymbol v, val]

-- ============================================================================
-- PRINT / RETURN
-- ============================================================================

parsePrint :: Parser SExpr
parsePrint = do
  _ <- identifier
  reserved "say"
  expr <- parseExpression
  dot
  return $ SList [SSymbol "call", SSymbol "peric",
                  SList [SList [SSymbol "string-interp", expr]]]

parseReturn :: Parser SExpr
parseReturn = do
  _ <- identifier
  reserved "leave" *> reserved "with"
  expr <- parseExpression
  dot
  return $ SList [SSymbol "return", expr]

-- ============================================================================
-- CLASSES (OOP)
--
-- Syntaxe :
--   <waifu> nickname is <className> and about <pronoun> :
--   - <pronoun> has <waifu> <field> equal to <expr>.      ← champ
--   - When <pronoun> borns (<waifu> <p> and)* so :        ← constructeur
--   -- <stmt>
--   - When <pronoun> <method> :                           ← méthode
--   -- <stmt>
--
-- SExpr émise :
--   (class <className>
--     (fields (field <name> <defaultVal> <type>) ...)
--     (constructor (params (<p> <type>) ...) <body>)
--     (method <name> (params (<p> <type>) ...) <body>)
--     ...)
-- ============================================================================

parseClass :: Parser SExpr
parseClass = do
  _         <- identifier                          -- nom de la waifu déclarante
  reserved "nickname" *> reserved "is"
  className <- identifier                          -- nom de la classe
  reserved "and" *> reserved "about"
  pronoun   <- identifier                          -- pronom (she/he/it/...)
  _ <- symbol ":"
  sc
  members <- many . try $ sc >> dashOnly >> parseClassMember pronoun
  return $ SList ([SSymbol "class", SSymbol className] ++ members)

-- Un membre de classe : champ ou méthode (dont constructeur).
parseClassMember :: String -> Parser SExpr
parseClassMember pronoun = choice
  [ try (parseField pronoun)
  , try (parseMethod pronoun)
  ]

-- -----------------------------------------------------------------------
-- Champ : "<pronoun> has <waifu> <fieldName> equal to <expr>."
-- -----------------------------------------------------------------------
-- Émet : (field <fieldName> <defaultVal> <type>)
parseField :: String -> Parser SExpr
parseField pronoun = do
  reserved pronoun
  reserved "has"
  _         <- identifier    -- waifu décorative (ex: "Mikasa")
  fieldName <- identifier
  reserved "equal" *> reserved "to"
  val       <- parseExpression
  dot
  let ty = case val of { SFloat _ -> SSymbol "float"; _ -> SSymbol "int" }
  return $ SList [SSymbol "field", SSymbol fieldName, val, ty]

-- -----------------------------------------------------------------------
-- Méthode / Constructeur :
--   "When <pronoun> borns (<pronoun> view <waifu> <p> (and <waifu> <p>)*)? so :"
--   "When <pronoun> <methodName> (paramList)? :"
-- -----------------------------------------------------------------------
-- Émet :
--   (constructor (params (p1 int) (p2 int) ...) <body>)
--   (method <name> (params (p1 int) ...) <body>)
parseMethod :: String -> Parser SExpr
parseMethod pronoun = do
  reserved "When"
  reserved pronoun
  -- Constructeur ou méthode ordinaire ?
  isConstructor <- optional . try $ reserved "borns"
  case isConstructor of
    Just () -> do
      params <- parseParamList pronoun
      reserved "so"
      body <- parseMethodBody
      return $ SList [SSymbol "constructor",
                      SList (SSymbol "params" : params),
                      body]
    Nothing -> do
      methodName <- identifier
      params     <- parseParamList pronoun
      optional (reserved "so")
      body <- parseMethodBody
      return $ SList [SSymbol "method", SSymbol methodName,
                      SList (SSymbol "params" : params),
                      body]

-- -----------------------------------------------------------------------
-- Liste de paramètres (optionnelle) :
--   "view <waifu> <p1> and <waifu> <p2> ..."
-- Le pronom n'apparaît PAS devant "view" dans la syntaxe réelle.
-- -----------------------------------------------------------------------
parseParamList :: String -> Parser [SExpr]
parseParamList _pronoun = do
  hasParams <- optional . try $ reserved "view"
  case hasParams of
    Nothing -> return []
    Just () -> do
      first <- parseOneParam
      rest  <- many . try $ reserved "and" >> parseOneParam
      return (first : rest)
  where
    -- "<waifu> <paramName>" — la waifu est décorative
    parseOneParam :: Parser SExpr
    parseOneParam = do
      _ <- identifier       -- waifu décorative (ex: "Mikasa")
      p <- identifier       -- nom du paramètre
      return $ SList [SSymbol p, SSymbol "int"]

-- ============================================================================
-- EXPORTS
-- ============================================================================

parseSExprEither :: String -> Either String SExpr
parseSExprEither src =
  case parse (sc >> parseStatement <* eof) "<waifu>" src of
    Left err -> Left (errorBundlePretty err)
    Right v  -> Right v

parseSExprMultipleEither :: String -> Either String [SExpr]
parseSExprMultipleEither src =
  case parse (sc >> many (sc >> parseStatement) <* sc <* eof) "<waifu>" src of
    Left err -> Left (errorBundlePretty err)
    Right v  -> Right v