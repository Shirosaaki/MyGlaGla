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

keywords :: [String]
keywords = ["destruct", "deschodt", "Deschodt", "erif", "deschelse", "darius", "aer", "eric", "peric", "desnum", "desnote", "deschontinue", "deschreak"]

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
lineComment = (try (string "desnote" >> notFollowedBy (char '\\')) >> void (takeWhileP (Just "comment content") (/= '\n')))
           <|> (string ";" >> void (takeWhileP (Just "comment content") (/= '\n')))

-- Helper to skip optional horizontal space then a newline
skipEOL :: Parser ()
skipEOL = void $ try (many (oneOf " \t") >> optional (char '\r') >> char '\n')

eolOrEof :: Parser ()
eolOrEof = void (try (optional (char '\r') >> char '\n')) <|> eof

-- ============================================================================
-- Basic Atoms
-- ============================================================================

atom :: Parser SExpr
atom = try floatAtom <|> try intAtom <|> try stringAtom <|> try charAtom <|> symbolAtom

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
  content <- escapedStringContent
  _ <- char '"'
  return $ SList [SSymbol "string", SSymbol content]

escapedStringContent :: Parser String
escapedStringContent = many (escapedChar <|> noneOf "\\\"")
  where
    escapedChar = do
        _ <- char '\\'
        c <- anySingle
        case c of
            'n' -> return '\n'
            'r' -> return '\r'
            't' -> return '\t'
            '0' -> return '\0'
            '\\' -> return '\\'
            '"' -> return '\"'
            _   -> return c

charAtom :: Parser SExpr
charAtom = try oldStyleChar <|> newStyleChar
  where
    oldStyleChar = do
      _ <- string "desnote\\"
      c <- anySingle
      let val = case c of
                  'n' -> '\n'
                  'r' -> '\r'
                  't' -> '\t'
                  _ -> c
      return $ SChar val

    newStyleChar = do
      _ <- char '\''
      c <- try escapeChar <|> anySingle
      _ <- char '\''
      return $ SChar c
    
    escapeChar = do
        _ <- char '\\'
        code <- anySingle
        case code of
            'n' -> return '\n'
            'r' -> return '\r'
            't' -> return '\t'
            '0' -> return '\0'
            '\\' -> return '\\'
            '\'' -> return '\''
            '"' -> return '\"'
            _   -> return code

symbolAtom :: Parser SExpr
symbolAtom = do
    s <- try $ do
        first <- oneOf validFirstChars
        rest <- many (oneOf validRestChars)
        let ident = first : rest
        if ident `elem` keywords then fail ("keyword " ++ ident) else return ident
    return $ SSymbol s
  where
    validFirstChars = "+-*/<>=!?" ++
                      "abcdefghijklmnopqrstuvwxyz" ++
                      "ABCDEFGHIJKLMNOPQRSTUVWXYZ_"
    validRestChars = validFirstChars ++ "0123456789"

identifier :: Parser String
identifier = try $ do
    ident <- do
        first <- oneOf validFirstChars
        rest <- many (oneOf validRestChars)
        return (first : rest)
    if ident `elem` keywords then fail ("keyword " ++ ident) else return ident
  where
    validFirstChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"
    validRestChars = validFirstChars ++ "0123456789"

-- ============================================================================
-- Types
-- ============================================================================

parseType :: Parser SExpr
parseType = do
  base <- identifier
  let parseArray = do
        _ <- char '['
        n <- optional (some digitChar)
        _ <- char ']'
        case n of
          Nothing -> return $ SList [SSymbol "array-type", SSymbol base]
          Just ds -> return $ SList [SSymbol "fixed-array-type", SSymbol base, SInt (read ds)]
      parsePointer = do
        _ <- char '*'
        return $ SList [SSymbol "pointer-type", SSymbol base]
  suffix <- optional (try parseArray <|> try parsePointer)
  case suffix of
    Nothing -> return $ SSymbol base
    Just s  -> return s

-- ============================================================================
-- Expressions
-- ============================================================================

parenExpr :: Parser SExpr
parenExpr = do
  _ <- char '('
  spaceConsumer
  e <- parseExpr
  spaceConsumer
  _ <- char ')'
  return e

parsePrimary :: Parser SExpr
parsePrimary = do
  base <- parenExpr <|> try parseFuncCall <|> atom
  parseAccessChain base

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
      mStart <- optional parseExpr
      spaceConsumer
      mSlice <- optional $ do
        _ <- char ':'
        spaceConsumer
        optional parseExpr
      spaceConsumer
      _ <- char ']'
      case (mStart, mSlice) of
        (Just idx, Nothing) -> return $ \b -> SList [SSymbol "array-access", b, idx]
        (ms, Just me) ->
          let s = fromMaybe (SInt 0) ms
              e = fromMaybe (SSymbol "nil") me
          in return $ \b -> SList [SSymbol "slice", b, s, e]
        (Nothing, Nothing) -> fail "empty brackets []"
    parseMemberAccess = do
      _ <- char '.'
      field <- identifier
      return $ \b -> SList [SSymbol "member-access", b, SSymbol field]

parseExpr :: Parser SExpr
parseExpr = parseLogicalOr

parseLogicalOr :: Parser SExpr
parseLogicalOr = do
  left <- parseLogicalAnd
  rest <- many $ try $ do
    spaceConsumer
    _ <- string "||"
    spaceConsumer
    right <- parseLogicalAnd
    return right
  return $ foldl (\acc r -> SList [SSymbol "||", acc, r]) left rest

parseLogicalAnd :: Parser SExpr
parseLogicalAnd = do
  left <- parseComparison
  rest <- many $ try $ do
    spaceConsumer
    _ <- string "&&"
    spaceConsumer
    right <- parseComparison
    return right
  return $ foldl (\acc r -> SList [SSymbol "&&", acc, r]) left rest

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
      , try (string "<") >> return "<"
      , try (string ">") >> return ">"
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
    op <- (char '+' >> return "+") <|> try (char '-' <* notFollowedBy (char '>') >> return "-")
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
    op <- (char '*' >> return "*") <|> (char '/' >> return "/") <|> (char '%' >> return "%")
    spaceConsumer
    right <- parseUnary
    return (op, right))
  case rest of
    Nothing -> return left
    Just (op, right) -> parseMulDivRest $ SList [SSymbol op, left, right]

parseUnary :: Parser SExpr
parseUnary = parseDeref <|> parseAddrOf <|> parsePrimary

parseDeref :: Parser SExpr
parseDeref = do
  _ <- char '*'
  e <- parsePrimary
  return $ SList [SSymbol "deref", e]

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
  [ try parseComment
  , try parseEnum
  , try parseStruct
  , try parseFuncDef
  , try parseDef
  , try parseAssign
  , try parseArrayDecl
  , try parseIf
  , try parseWhile
  , try parseFor
  , try parseReturn
  , try parseContinue
  , try parseBreak
  , try parsePrint
  , try parseExpr
  ]

parseFuncDef :: Parser SExpr
parseFuncDef = do
  _ <- string "Deschodt"
  spaceConsumer
  name <- identifier
  spaceConsumer
  _ <- char '('
  spaceConsumer
  params <- sepBy parseDefParam (char ',' >> spaceConsumer)
  _ <- char ')'
  spaceConsumer
  _ <- string "->"
  spaceConsumer
  retType <- parseType
  _ <- many (oneOf " \t")
  body <- parseBlock
  let paramNames = map fst params
  let lambda = SList [SSymbol "lambda", SList (map SSymbol paramNames), SList (SSymbol "block" : body)]
  return $ SList [SSymbol "define", SSymbol name, lambda, retType]

parseDefParam :: Parser (String, SExpr)
parseDefParam = do
  name <- identifier
  spaceConsumer
  _ <- string "->"
  spaceConsumer
  ty <- parseType
  return (name, ty)

parseComment :: Parser SExpr
parseComment = do
  _ <- string "desnote"
  _ <- notFollowedBy (char '\\')
  content <- takeWhileP (Just "comment content") (/= '\n')
  return $ SList [SSymbol "comment", SString content]

parseEnum :: Parser SExpr
parseEnum = do
  _ <- string "desnum"
  spaceConsumer
  name <- identifier
  _ <- char ':'
  -- Capture enum values:
  -- - newline + indented block: one identifier per line (common form)
  -- - inline: values on the same line
  values <-
    try (do
      _ <- many (oneOf " \t")
      _ <- optional (char '\r')
      _ <- char '\n'
      indents <- some (char ' ' <|> char '\t')
      let indentCount = length indents
      first <- identifier
      _ <- many (oneOf " \t")
      eolOrEof
      rest <- many $ try $ do
        lookAhead (count indentCount (char ' ' <|> char '\t'))
        _ <- count indentCount (char ' ' <|> char '\t')
        v <- identifier
        _ <- many (oneOf " \t")
        eolOrEof
        return v
      return (first : rest)
    )
    <|> (many (oneOf " \t") >> many (identifier <* spaceConsumer))
  
  -- Transform enum values into Defines: (block (define Val1 0 int) (define Val2 1 int))
  let defs = zipWith (\val idx -> 
          SList [SSymbol "define", SSymbol val, SInt idx, SSymbol "int"]
        ) values [0..]
  
  return $ SList (SSymbol "block" : defs)

parseEnumValuesBlock :: Parser [String]
parseEnumValuesBlock = do
  _ <- many (try (many (oneOf " \t")) >> optional (char '\r') >> char '\n')
  indents <- some (char ' ' <|> char '\t')
  let indentCount = length indents
  do
      first <- identifier
      _ <- many (char ' ' <|> char '\t')
      eolOrEof
      rest <- many $ try $ do
        _ <- many (try (many (oneOf " \t")) >> char '\n')
        _ <- count indentCount (char ' ' <|> char '\t')
        id <- identifier
        _ <- many (char ' ' <|> char '\t')
        eolOrEof
        return id
      return (first : rest)

parseStruct :: Parser SExpr
parseStruct = do
  _ <- string "destruct"
  spaceConsumer
  name <- identifier
  spaceConsumer
  _ <- char ':'
  -- Capture struct fields:
  -- - newline + indented block: one `field -> type` per line (common form)
  -- - inline: fields on the same line
  fields <-
    try (do
      _ <- many (oneOf " \t")
      _ <- optional (char '\r')
      _ <- char '\n'
      indents <- some (char ' ' <|> char '\t')
      let indentCount = length indents
      first <- parseStructField
      _ <- many (oneOf " \t")
      eolOrEof
      rest <- many $ try $ do
        lookAhead (count indentCount (char ' ' <|> char '\t'))
        _ <- count indentCount (char ' ' <|> char '\t')
        f <- parseStructField
        _ <- many (oneOf " \t")
        eolOrEof
        return f
      return (first : rest)
    )
    <|> (many (oneOf " \t") >> many parseStructField)
  return $ SList ([SSymbol "struct", SSymbol name] ++ fields)

parseStructField :: Parser SExpr
parseStructField = do
  fname <- identifier
  _ <- many (oneOf " \t")
  _ <- string "->"
  _ <- many (oneOf " \t")
  ftype <- parseType
  _ <- many (oneOf " \t")
  return $ SList [SSymbol fname, ftype]

parseStructFieldsBlock :: Parser [SExpr]
parseStructFieldsBlock = parseStructFieldsBlockMin 0

parseStructFieldsBlockMin :: Int -> Parser [SExpr]
parseStructFieldsBlockMin minIndent = do
  _ <- many (try (many (oneOf " \t")) >> optional (char '\r') >> char '\n')
  indents <- some (char ' ' <|> char '\t')
  let indentCount = length indents
  if indentCount <= minIndent
    then fail "insufficient indentation for struct fields block"
    else do
      first <- parseStructField
      _ <- many (char ' ' <|> char '\t')
      eolOrEof
      rest <- many $ try $ do
        _ <- many (try (many (oneOf " \t")) >> char '\n')
        _ <- count indentCount (char ' ' <|> char '\t')
        f <- parseStructField
        _ <- many (char ' ' <|> char '\t')
        eolOrEof
        return f
      return (first : rest)

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

parseArrayDecl :: Parser SExpr
parseArrayDecl = do
  name <- identifier
  idxs <- some $ do
    _ <- char '['
    spaceConsumer
    i <- parseExpr
    spaceConsumer
    _ <- char ']'
    return i
  spaceConsumer
  _ <- string "->"
  spaceConsumer
  ty <- parseType
  let finalBase = if length idxs == 1
                  then SSymbol name
                  else foldl (\acc i -> SList [SSymbol "array-access", acc, i]) (SSymbol name) (init idxs)
      finalIdx = last idxs
  return $ SList [SSymbol "array-decl", finalBase, finalIdx, ty]

parseAssign :: Parser SExpr
parseAssign = do
  target <- parsePrimary
  spaceConsumer
  op <- choice [string "=", try (string "+="), try (string "-="), try (string "*="), try (string "/=")]
  spaceConsumer
  value <- parseExpr
  if op == "="
    then return $ SList [SSymbol "assign", target, value]
    else
      let binOp = init op
      in return $ SList [SSymbol "assign", target, SList [SSymbol binOp, target, value]]

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
  _ <- many (oneOf " \t")
  thenBranch <- parseBlock
  elseBranch <- optional $ try $ do
    spaceConsumer
    _ <- string "deschelse"
    spaceConsumer
    _ <- char ':'
    _ <- many (oneOf " \t")
    parseBlock
  return $ SList [SSymbol "if", cond, SList thenBranch,
                  SList (fromMaybe [] elseBranch)]

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
  _ <- many (oneOf " \t")
  body <- parseBlock
  return $ SList [SSymbol "while", cond, SList body]

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
  _ <- many (oneOf " \t")
  body <- parseBlock
  return $ SList [SSymbol "for", SSymbol var, start, end, SList body]

parseReturn :: Parser SExpr
parseReturn = do
  _ <- string "deschodt"
  spaceConsumer
  value <- parseExpr
  return $ SList [SSymbol "return", value]

parseContinue :: Parser SExpr
parseContinue = do
  _ <- string "deschontinue"
  return $ SSymbol "continue"

parseBreak :: Parser SExpr
parseBreak = do
  _ <- string "deschreak"
  return $ SSymbol "break"

parsePrint :: Parser SExpr
parsePrint = do
  _ <- string "peric("
  spaceConsumer
  e <- (try parseInterpolatedString <|> parseExpr)
  spaceConsumer
  _ <- char ')'
  return $ SList [SSymbol "call", SSymbol "peric", SList [e]]

parseInterpolatedString :: Parser SExpr
parseInterpolatedString = do
  _ <- char '"'
  content <- escapedStringContent
  _ <- char '"'
  let parts = parseInterp content
      partsSExpr = SList parts
  return $ SList [SSymbol "string-interp", partsSExpr]

parseInterp :: String -> [SExpr]
parseInterp s = reverse (go s [])
  where
  go :: String -> [SExpr] -> [SExpr]
  go "" acc = acc
  go str acc =
    case break (=='{') str of
      (before, "") -> (if null before then acc else SString before : acc)
      (before, '{':rest) ->
        let (var, remain) = span (/= '}') rest in
        case remain of
          "" -> (SString (before ++ "{" ++ var) : acc)
          ('}':after) ->
            let acc' = (if null before then acc else SString before : acc)
            in go after (SSymbol var : acc')
          _ -> (SString before : acc)
      (_, _) -> acc

parseFuncCall :: Parser SExpr
parseFuncCall = do
  name <- identifier
  _ <- char '('
  spaceConsumer
  args <- sepBy parseExpr (char ',' >> spaceConsumer)
  _ <- char ')'
  return $ SList ([SSymbol "call", SSymbol name, SList args])

parseBlockMin :: Int -> Parser [SExpr]
parseBlockMin minIndent = do
  _ <- many (try $ (many (oneOf " \t")) >> optional (char '\r') >> char '\n')
  indentStr <- lookAhead (some (char ' ' <|> char '\t'))
  if length indentStr <= minIndent
    then fail "insufficient indentation for block"
    else do
      some $ try $ do
        _ <- many (try $ (many (oneOf " \t")) >> optional (char '\r') >> char '\n')
        _ <- string indentStr
        s <- parseStmt
        _ <- optional (try $ (many (oneOf " \t")) >> optional (char '\r') >> char '\n')
        return s

parseBlock :: Parser [SExpr]
parseBlock = try parseInlineBlock <|> parseBlockMin 0

parseInlineBlock :: Parser [SExpr]
parseInlineBlock = (:[]) <$> parseStmt