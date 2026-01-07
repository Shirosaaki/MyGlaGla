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
import Debug.Trace (trace)

type Parser = Parsec Void String

keywords :: [String]
keywords = ["destruct", "deschodt", "erif", "deschelse", "darius", "aer", "eric", "peric", "desnum", "desnote", "deschontinue", "deschreak"]

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
  content <- many (noneOf "\"")
  _ <- char '"'
  return $ SList [SSymbol "string", SSymbol content]

charAtom :: Parser SExpr
charAtom = do
  _ <- string "desnote\\"
  c <- anySingle
  let val = case c of
              'n' -> '\n'
              'r' -> '\r'
              't' -> '\t'
              _ -> c
  return $ SChar val

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

-- | Parse type annotations: int, float, string, int[], int*, Personne, etc.
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
  base <- parenExpr <|> try parseFuncCall <|> atom
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
      -- Slice can be [start:end], [:end], [start:], or [index]
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

-- | Parse binary operators with precedence
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
  [ try parseComment
  , try parseEnum
  , try parseStruct
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

parseComment :: Parser SExpr
parseComment = do
  _ <- string "desnote"
  _ <- notFollowedBy (char '\\')
  content <- takeWhileP (Just "comment content") (/= '\n')
  return $ SList [SSymbol "comment", SString content]

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
  spaceConsumer
  _ <- char ':'
  -- If we have a newline, it's a block. Otherwise, it's inline.
  fields <- try (char '\n' >> parseStructFieldsBlock)
        <|> (many (oneOf " \t") >> many parseStructField)
  return $ SList ([SSymbol "struct", SSymbol name] ++ fields)

parseStructField :: Parser SExpr
parseStructField = do
  fname <- identifier
  many (oneOf " \t")
  _ <- string "->"
  many (oneOf " \t")
  ftype <- parseType
  -- Consume trailing spaces on the same line
  many (oneOf " \t")
  return $ SList [SSymbol fname, ftype]

parseStructFieldsBlock :: Parser [SExpr]
parseStructFieldsBlock = parseStructFieldsBlockMin 0

parseStructFieldsBlockMin :: Int -> Parser [SExpr]
parseStructFieldsBlockMin minIndent = do
  -- skip blank lines
  _ <- many (try (many (oneOf " \t") >> char '\n'))
  indents <- some (char ' ' <|> char '\t')
  let indentCount = length indents
  if indentCount <= minIndent
    then fail "insufficient indentation for struct fields block"
    else do
      first <- parseStructField
      _ <- many (char ' ' <|> char '\t')
      _ <- optional (char '\n')
      rest <- many $ try $ do
        -- skip blank lines
        _ <- many (try (many (oneOf " \t") >> char '\n'))
        -- count spaces for each field to ensure they align
        _ <- count indentCount (char ' ' <|> char '\t')
        f <- parseStructField
        _ <- many (char ' ' <|> char '\t')
        _ <- optional (char '\n')
        return f
      return (first : rest)

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

-- | Assignment: x = 5  OR  arr[0] = 10  OR  p.name = "Alice"
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
      let binOp = init op -- remove '='
      in return $ SList [SSymbol "assign", target, SList [SSymbol binOp, target, value]]

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
  _ <- many (oneOf " \t")
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
  _ <- many (oneOf " \t")
  body <- parseBlock
  return $ SList [SSymbol "for", SSymbol var, start, end, SList body]

-- | Return statement: deschodt value
parseReturn :: Parser SExpr
parseReturn = do
  _ <- string "deschodt"
  spaceConsumer
  value <- parseExpr
  return $ SList [SSymbol "return", value]

-- | Continue: deschontinue
parseContinue :: Parser SExpr
parseContinue = do
  _ <- string "deschontinue"
  return $ SSymbol "continue"

-- | Break: deschreak
parseBreak :: Parser SExpr
parseBreak = do
  _ <- string "deschreak"
  return $ SSymbol "break"

-- | Print statement: peric("message {var}")
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
  content <- many (noneOf "\"")
  _ <- char '"'
  let parts = parseInterp content
      partsSExpr = SList parts
  return $ SList [SSymbol "string-interp", partsSExpr]


-- Split a string like "x = {x}, y = {y}" into SExpr parts
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
          -- no closing brace: treat the whole chunk as literal
          "" -> (SString (before ++ "{" ++ var) : acc)
          -- found closing brace: add before (if any) and symbol, continue after brace
          ('}':after) ->
            let acc' = (if null before then acc else SString before : acc)
            in go after (SSymbol var : acc')
          _ -> (SString before : acc)

-- | Function definition: Deschodt funcName(params) -> retType body (REMOVED)


-- | Function call: funcName(arg1, arg2)
parseFuncCall :: Parser SExpr
parseFuncCall = do
  name <- identifier
  _ <- char '('
  spaceConsumer
  args <- sepBy parseExpr (char ',' >> spaceConsumer)
  _ <- char ')'
  return $ SList ([SSymbol "call", SSymbol name, SList args])

-- parseBlockMin takes a minimum indent (number of spaces/tabs). The first
-- statement in the block must be indented strictly more than `minIndent`.
-- All subsequent statements in the same block must have the same indentation
-- as the first statement. Nested blocks (handled by nested calls) must be
-- indented further.
parseBlockMin :: Int -> Parser [SExpr]
parseBlockMin minIndent = do
  _ <- many (try $ (many (oneOf " \t")) >> char '\n')
  -- count indentation of first statement
  indents <- some (char ' ' <|> char '\t')
  let indentCount = length indents
  if indentCount <= minIndent
    then fail "insufficient indentation for block"
    else do
      first <- parseStmt
      _ <- many (try $ (many (oneOf " \t")) >> char '\n')
      rest <- many $ try $ do
        -- require same indentation for other statements in this block
        _ <- count indentCount (char ' ' <|> char '\t')
        s <- parseStmt
        _ <- many (try $ (many (oneOf " \t")) >> char '\n')
        return s
      return (first : rest)

-- Convenience wrapper for existing callers when no minimum indent is known
parseBlock :: Parser [SExpr]
parseBlock = try parseInlineBlock <|> parseBlockMin 0

parseInlineBlock :: Parser [SExpr]
parseInlineBlock = (:[]) <$> parseStmt
