{-
-- EPITECH PROJECT, 2025
-- AST module
-- File description:
-- file where the AST is defined
-}
module AST (SExpr(..), Ast(..), Type(..), Env, sexprToAST, evalAST, EvalResult,
            defName, defValue) where

data SExpr = SInt Int
            | SFloat Double
            | SBool Bool
            | SString String
            | SChar Char
            | SSymbol String
            | SList [SExpr]
            deriving (Show, Eq)

-- | Simple Type system for TheShow (used in AST definitions)
data Type = TInt
          | TFloat
          | TBool
          | TString
          | TChar
          | TVoid
          | TCustom String
          deriving (Show, Eq)

-- | AST nodes used by the compiler / evaluator
data Ast = Define String (Maybe Type) Ast           -- variable/function definition with optional type
         | AstInt Int
         | AstFloat Double
         | AstBool Bool
         | AstString String
         | AstChar Char
         | AstSymbol String
         | AstList [Ast]
         | Call Ast [Ast]
         | AstLambda [String] Ast
         | AstClosure [String] Ast Env
         | AstVoid
         | Assign String Ast                        -- variable assignment
         | IfElse Ast Ast Ast                        -- if-then-else
         | While Ast Ast                             -- while loop
         | For String Ast Ast                        -- for-in loop (var, collection, body)
         | Break
         | Continue
         | Return Ast
         | ArrayAccess Ast Ast                       -- array[index]
         | Slice Ast Ast Ast                         -- array[start:end]
         | ArrayAssign String Ast Ast               -- array[index] = value
         | Struct String [(String, Type)]            -- struct definition (name, fields)
         | StructFieldAssign String String Ast      -- struct.field = value
         | Block [Ast]                               -- sequence of statements
         | TypedVar String Type Ast                  -- variable with explicit type and init value
         deriving (Show, Eq)


-- | Accessor for Define name
defName :: Ast -> String
defName (Define n _ _) = n
defName _ = error "defName: not a Define"

-- | Accessor for Define value
defValue :: Ast -> Ast
defValue (Define _ _ v) = v
defValue _ = error "defValue: not a Define"

type Env = [(String, Ast)]
type EvalResult = Either String (Ast, Env)

-- Helper extractors and call builders used by `sexprToAST`
paramNameE :: SExpr -> Either String String
paramNameE (SSymbol s) = Right s
paramNameE _ = Left "lambda: parameter must be a symbol"

extractParamName :: SExpr -> Either String String
extractParamName (SList [SSymbol n, _]) = Right n
extractParamName _ = Left "fun: parameter must be a (name type) list"

-- Helper: convert an SExpr representing a type into a Type value
parseTypeSExpr :: SExpr -> Either String Type
parseTypeSExpr (SSymbol "int") = Right TInt
parseTypeSExpr (SSymbol "float") = Right TFloat
parseTypeSExpr (SSymbol "string") = Right TString
parseTypeSExpr (SSymbol "bool") = Right TBool
parseTypeSExpr (SSymbol "char") = Right TChar
parseTypeSExpr (SSymbol "void") = Right TVoid
parseTypeSExpr (SSymbol other) = Right (TCustom other)
parseTypeSExpr (SList [SSymbol "array-type", SSymbol base]) = Right (TCustom (base ++ "[]"))
parseTypeSExpr (SList [SSymbol "fixed-array-type", SSymbol base, SInt size]) = Right (TCustom (base ++ "[" ++ show size ++ "]"))
parseTypeSExpr _ = Left "bad type"

makeCallArgs :: Ast -> [SExpr] -> Either String Ast
makeCallArgs fnAst args = fmap (Call fnAst) (mapM sexprToAST args)

makeCall :: SExpr -> [SExpr] -> Either String Ast
makeCall fn args =
    case sexprToAST fn of
        Left err -> Left err
        Right fnAst -> makeCallArgs fnAst args

-- Unified and (more) exhaustive SExpr -> Ast converter tailored to TheShow SExprs
sexprToAST :: SExpr -> Either String Ast
sexprToAST (SSymbol s) = Right (AstSymbol s)
sexprToAST (SInt n) = Right (AstInt n)
sexprToAST (SFloat f) = Right (AstFloat f)
sexprToAST (SBool b) = Right (AstBool b)
sexprToAST (SString s) = Right (AstString s)
sexprToAST (SChar c) = Right (AstChar c)
sexprToAST (SList []) = Right (AstList [])

-- Handle parser's string S-expr form: (string "content") or (string contentSymbol)
sexprToAST (SList [SSymbol "string", SSymbol s]) = Right (AstString s)
sexprToAST (SList [SSymbol "string", SString s]) = Right (AstString s)

-- top-level sequence of statements: treat a list of lists as a Block
sexprToAST (SList xs) | all isSList xs =
    case mapM sexprToAST xs of
        Right bodyAsts ->
            -- If the program is a single top-level zero-arg function definition,
            -- add an automatic call so the function body runs immediately.
            case bodyAsts of
                [def@(Define name _ (AstLambda params _))] | null params ->
                    Right (Block [def, Call (AstSymbol name) []])
                _ -> Right (Block bodyAsts)
        Left err -> Left err
  where
    isSList (SList _) = True
    isSList _ = False

-- function declaration emitted by TheShow: (fun name (params...) ret bodylist)
sexprToAST (SList [SSymbol "fun", SSymbol name, SList params, _ret, SList body]) =
    case mapM extractParamName params of
        Right pnames ->
            case mapM sexprToAST body of
                Right bodyAsts -> Right (Define name Nothing (AstLambda pnames (Block bodyAsts)))
                Left err -> Left err
        Left err -> Left err

-- variable declaration: (eric name type [value])
sexprToAST (SList (SSymbol "eric" : SSymbol name : ty : xs)) =
    let valSexpr = if null xs then SSymbol "unit" else head xs
    in case (sexprToAST valSexpr, parseTypeSExpr ty) of
        (Right v, Right t) -> Right (Define name (Just t) v)
        (Left e, _) -> Left e
        (_, Left e) -> Left e
sexprToAST (SList (SSymbol "eric" : rest)) = Left "eric: bad syntax"

-- return
sexprToAST (SList [SSymbol "return", expr]) =
    case sexprToAST expr of
        Right e -> Right (Return e)
        Left err -> Left err

-- comment: ignore / map to AstList []
sexprToAST (SList [SSymbol "comment", SString _]) = Right (AstList [])

-- assignment: (= target value) or (assign target value)
sexprToAST (SList [SSymbol "=", target, value]) = sexprToAST (SList [SSymbol "assign", target, value])

-- array access: (array-access arr idx) or (index arr idx)
sexprToAST (SList [sym, arr, idx]) | sym == SSymbol "array-access" || sym == SSymbol "index" =
    case (sexprToAST arr, sexprToAST idx) of
        (Right a, Right i) -> Right (ArrayAccess a i)
        (Left e, _) -> Left e
        (_, Left e) -> Left e

-- slice: (slice arr start end)
sexprToAST (SList [SSymbol "slice", arr, start, end]) =
    case (sexprToAST arr, sexprToAST start, sexprToAST end) of
        (Right a, Right s, Right e) -> Right (Slice a s e)
        (Left err, _, _) -> Left err
        (_, Left err, _) -> Left err
        (_, _, Left err) -> Left err

-- for loop: (aer var (range s e) body)
sexprToAST (SList [SSymbol "aer", SSymbol var, SList (SSymbol "range" : s:e:[]), SList body]) =
    case (sexprToAST s, sexprToAST e, mapM sexprToAST body) of
        (Right rs, Right re, Right bodyAsts) -> Right (For var (Block [rs, re]) (Block bodyAsts))
        (Left err, _, _) -> Left err
        (_, Left err, _) -> Left err
        (_, _, Left err) -> Left err

-- while: (darius cond body)
sexprToAST (SList [SSymbol "darius", cond, SList body]) =
    case (sexprToAST cond, mapM sexprToAST body) of
        (Right c, Right bodyAsts) -> Right (While c (Block bodyAsts))
        (Left e, _) -> Left e
        (_, Left e) -> Left e

-- if: (if cond then else)
sexprToAST (SList [SSymbol "if", cond, SList thenBody, SList elseBody]) =
    case (sexprToAST cond, mapM sexprToAST thenBody, mapM sexprToAST elseBody) of
        (Right c, Right t, Right e) -> Right (IfElse c (Block t) (Block e))
        (Left err, _, _) -> Left err
        (_, Left err, _) -> Left err
        (_, _, Left err) -> Left err

-- print/call form emitted by TheShow: (call name (args...))
sexprToAST (SList [SSymbol "call", SSymbol name, SList args]) =
    case mapM sexprToAST args of
        Right argAsts -> Right (Call (AstSymbol name) argAsts)
        Left err -> Left err

-- define: (define name value?) emitted by parser for `eric` and some constructs
sexprToAST (SList [SSymbol "define", SSymbol name, val, ty]) =
    case (sexprToAST val, parseTypeSExpr ty) of
        (Right v, Right t) -> Right (Define name (Just t) v)
        (Left e, _) -> Left e
        (_, Left e) -> Left e
sexprToAST (SList [SSymbol "define", SSymbol name, tySexpr]) =
    case parseTypeSExpr tySexpr of
        Right t -> Right (Define name (Just t) AstVoid)
        Left e -> Left e

-- assign: (assign name value)  OR  (assign (member-access obj field) value)
sexprToAST (SList [SSymbol "assign", SList (SSymbol "member-access" : SSymbol obj : SSymbol field : []) , value]) =
    case sexprToAST value of
        Right v -> Right (Assign (obj ++ "." ++ field) v)
        Left e -> Left e
sexprToAST (SList [SSymbol "assign", targetSexpr, valueSexpr]) =
    case (sexprToAST targetSexpr, sexprToAST valueSexpr) of
        (Right (AstSymbol name), Right v) -> Right (Assign name v)
        (Right (ArrayAccess (AstSymbol name) idx), Right v) -> Right (ArrayAssign name idx v)
        (Right (ArrayAccess target idx), Right v) ->
             -- Nested array access: target[idx] = v.
             -- If target is also an ArrayAccess, we might need more logic or just emit it as a call for now.
             -- But usually it's name[idx1][idx2] which translates to (ArrayAccess (ArrayAccess name idx1) idx2).
             case target of
                AstSymbol name -> Right (ArrayAssign name idx v)
                _ -> Right (Call (AstSymbol "assign") [ArrayAccess target idx, v])
        (Right t, Right v) -> Right (Call (AstSymbol "assign") [t, v])
        (Left e, _) -> Left e
        (_, Left e) -> Left e

-- array-decl: (array-decl target index type)
sexprToAST (SList [SSymbol "array-decl", target, idx, ty]) =
    case (sexprToAST target, sexprToAST idx, parseTypeSExpr ty) of
        (Right t, Right i, Right _) -> Right (Call (AstSymbol "array-decl") [t, i])
        (Left e, _, _) -> Left e
        (_, Left e, _) -> Left e
        (_, _, Left e) -> Left e

-- struct: (struct name (field1 type1) (field2 type2) ...)
sexprToAST (SList (SSymbol "struct" : SSymbol name : fields)) =
    let parseField (SList [SSymbol fname, SSymbol tyStr]) = case parseTypeSExpr (SSymbol tyStr) of
            Right t -> Right (fname, t)
            Left e -> Left e
        parseField _ = Left "struct field: bad syntax"
        (fieldExprs, rest) = span isField fields
        isField (SList [SSymbol _, SSymbol _]) = True
        isField _ = False
    in case mapM parseField fieldExprs of
        Right fs ->
            case rest of
                [] -> Right (Struct name fs)
                _  -> case mapM sexprToAST rest of
                        Right more -> Right (Block (Struct name fs : more))
                        Left e -> Left e
        Left err -> Left err



-- lambda
sexprToAST (SList [SSymbol "lambda", SList params, body]) =
    case mapM paramNameE params of
        Right pn ->
            case sexprToAST body of
                Right bodyAst -> Right (AstLambda pn bodyAst)
                Left err -> Left err
        Left err -> Left err
sexprToAST (SList [SSymbol "lambda", _, _]) = Left "lambda: parameters must be a list"
sexprToAST (SList [SSymbol "lambda", _]) = Left "lambda: missing body"
sexprToAST (SList [SSymbol "lambda"]) = Left "lambda: missing parameters and body"
sexprToAST (SList (SSymbol "lambda" : _)) = Left "lambda: bad syntax"

-- generic application: (fn arg1 arg2 ...)
sexprToAST (SList (fn:args)) =
    case sexprToAST fn of
        Left err -> Left err
        Right fnAst -> makeCallArgs fnAst args

-- fallback
sexprToAST other = Left ("Unsupported SExpr: " ++ show other)

-- | Evaluation with enhanced type support (keeps previous behavior)
evalAST :: Env -> Ast -> EvalResult
evalAST env (AstInt n) = Right (AstInt n, env)
evalAST env (AstFloat f) = Right (AstFloat f, env)
evalAST env (AstBool b) = Right (AstBool b, env)
evalAST env (AstString s) = Right (AstString s, env)
evalAST env (AstChar c) = Right (AstChar c, env)
evalAST env AstVoid = Right (AstVoid, env)
evalAST env closure@(AstClosure _ _ _) = Right (closure, env)
evalAST env (AstSymbol s) =
    case lookup s env of
        Just v -> Right (v, env)
        Nothing -> Left ("variable " ++ s ++ " is not bound")
evalAST env (Define name _ty val) =
    case val of
        AstLambda params body ->
            let updatedEnv = (name, AstClosure params body updatedEnv) : env
            in Right (AstVoid, updatedEnv)
        _ ->
            case evalAST env val of
                Right (v, env') -> Right (AstVoid, (name, v) : env')
                Left err -> Left err
evalAST env (AstLambda params body) =
    Right (AstClosure params body env, env)
evalAST env (AstList xs) = evalSeq env xs
  where
    evalSeq e [] = Right (AstList [], e)  -- Empty list
    evalSeq e [x] = evalAST e x
    evalSeq e (x:xs') =
        case evalAST e x of
            Right (_, e') -> evalSeq e' xs'
            Left err -> Left err
evalAST env (IfElse cond thenExpr elseExpr) =
    case evalAST env cond of
        Right (AstBool True, env1) -> evalAST env1 thenExpr
        Right (AstBool False, env1) -> evalAST env1 elseExpr
        Right (_, _) -> Left "if: condition must be a boolean"
        Left err -> Left err
evalAST env (Block stmts) = evalBlock env stmts
evalAST env (Call fnAst args) = evalCall env fnAst args
evalAST _ other = Left ("Unsupported AST node: " ++ show other)

-- | Evaluate a block of statements
evalBlock :: Env -> [Ast] -> EvalResult
evalBlock env [] = Right (AstVoid, env)
evalBlock env [s] = evalAST env s
evalBlock env (s:rest) =
    case evalAST env s of
        Right (_, env') -> evalBlock env' rest
        Left err -> Left err

-- | Evaluate a function call
evalCall :: Env -> Ast -> [Ast] -> EvalResult
evalCall env (AstSymbol op) args = evalOpCall env op args
evalCall env fnAst args =
    case evalAST env fnAst of
        Right (AstClosure _ _ _, _) ->
            evalClosureCall env args fnAst
        Right (other, _) ->
            Left ("attempt to apply non-procedure: " ++ show other)
        Left err -> Left err

-- | Helper to convert closure AST to value
-- Closures are represented as `AstClosure`; printing relies on `show` for `Ast`.

evalClosureCall :: Env -> [Ast] -> Ast -> EvalResult
evalClosureCall env args closureAst =
    case evalAST env closureAst of
        Right (vc@(AstClosure params _ _), _) ->
            evalClosureCallChecked env args closureAst params vc
        _ -> Left "Invalid closure"

evalClosureCallChecked :: Env -> [Ast] -> Ast -> [String]
                       -> Ast -> EvalResult
evalClosureCallChecked env args closureAst params _ =
    case evalArgs env args of
        Left err -> Left err
        Right (argVals, _) ->
            if length params == length argVals
            then execClosure env closureAst argVals
            else Left ("wrong number of arguments: expected " ++
                      show (length params) ++ ", got " ++ show (length argVals))

execClosure :: Env -> Ast -> [Ast] -> EvalResult
execClosure env closureAst argVals =
    case evalAST env closureAst of
        Right (val, _) ->
            case val of
                AstClosure params body closureEnv ->
                    case evalAST (zip params argVals ++ closureEnv) body of
                        Right (res, _) -> Right (res, env)
                        Left err -> Left err
                _ -> Left "attempt to call non-procedure"
        Left err -> Left err

evalBuiltinOp :: Env -> String -> [Ast] -> EvalResult
evalBuiltinOp env op args =
    case evalArgs env args of
        Right (argVals, env') ->
            case evalOp op argVals of
                Right v -> Right (v, env')
                Left err -> Left err
        Left err -> Left err

-- | Built-in operations for the language
evalOpCall :: Env -> String -> [Ast] -> EvalResult
evalOpCall env "if" [cond, thenExpr, elseExpr] =
    case evalAST env cond of
        Right (AstBool True, env1) -> evalAST env1 thenExpr
        Right (AstBool False, env1) -> evalAST env1 elseExpr
        Right (_, _) -> Left "if: condition must be a boolean"
        Left err -> Left err
evalOpCall _ "if" _ = Left "if: bad syntax"
evalOpCall env "==" args =
    case evalArgs env args of
        Right ([a, b], env') -> Right (AstBool (a == b), env')
        Right (_, _) -> Left "==: expected 2 arguments"
        Left err -> Left err
evalOpCall env "<" args =
    case evalArgs env args of
        Right ([AstInt a, AstInt b], env') -> Right (AstBool (a < b), env')
        Right ([AstFloat a, AstFloat b], env') -> Right (AstBool (a < b), env')
        Right ([_, _], _) -> Left "<: arguments must be numbers"
        Right (_, _) -> Left "<: expected 2 arguments"
        Left err -> Left err
evalOpCall env ">" args =
    case evalArgs env args of
        Right ([AstInt a, AstInt b], env') -> Right (AstBool (a > b), env')
        Right ([AstFloat a, AstFloat b], env') -> Right (AstBool (a > b), env')
        Right ([_, _], _) -> Left ">: arguments must be numbers"
        Right (_, _) -> Left ">: expected 2 arguments"
        Left err -> Left err
evalOpCall env "<=" args =
    case evalArgs env args of
        Right ([AstInt a, AstInt b], env') ->
            Right (AstBool (a <= b), env')
        Right ([AstFloat a, AstFloat b], env') ->
            Right (AstBool (a <= b), env')
        Right ([_, _], _) -> Left "<=: arguments must be numbers"
        Right (_, _) -> Left "<=: expected 2 arguments"
        Left err -> Left err
evalOpCall env ">=" args =
    case evalArgs env args of
        Right ([AstInt a, AstInt b], env') ->
            Right (AstBool (a >= b), env')
        Right ([AstFloat a, AstFloat b], env') ->
            Right (AstBool (a >= b), env')
        Right ([_, _], _) -> Left ">=: arguments must be numbers"
        Right (_, _) -> Left ">=: expected 2 arguments"
        Left err -> Left err
evalOpCall env "peric" args =
    case evalArgs env args of
        Right ([AstString s], env') -> Right (AstString s, env')
        Right ([a], env') -> Right (AstString (astToString a), env')
        Right (asList, env') -> Right (AstString (concatMap astToString asList), env')
        Left err -> Left err
  where
    astToString :: Ast -> String
    astToString (AstString s) = s
    astToString (AstInt n) = show n
    astToString (AstFloat f) = show f
    astToString (AstBool True) = "1"
    astToString (AstBool False) = "0"
    astToString (AstChar c) = [c]
    astToString other = show other

evalOpCall env "string-interp" args =
    case evalArgs env args of
        Right (parts, env') -> Right (AstString (concatMap astToString parts), env')
        Left err -> Left err
  where
    astToString :: Ast -> String
    astToString (AstString s) = s
    astToString (AstInt n) = show n
    astToString (AstFloat f) = show f
    astToString (AstBool True) = "1"
    astToString (AstBool False) = "0"
    astToString (AstChar c) = [c]
    astToString other = show other
evalOpCall env "range" args =
    case evalArgs env args of
        Right ([AstInt _, AstInt _], env') ->
            Right (AstString ("range"), env')  -- Simplified
        Right (_, _) -> Left "range: expected 2 integer arguments"
        Left err -> Left err
evalOpCall env op args =
    case lookup op env of
        Just (AstClosure _ _ _) -> evalClosureCall env args (AstSymbol op)
        Just _ -> Left (op ++ " is not a procedure")
        Nothing -> evalBuiltinOp env op args

evalArgs :: Env -> [Ast] -> Either String ([Ast], Env)
evalArgs env [] = Right ([], env)
evalArgs env (x:xs) =
    case evalAST env x of
        Right (v, env1) ->
            case evalArgs env1 xs of
                Right (vs, env2) -> Right (v:vs, env2)
                Left err -> Left err
        Left err -> Left err

-- | Arithmetic and comparison operations
evalOp :: String -> [Ast] -> Either String Ast
evalOp "+" [] = Right (AstInt 0)
evalOp "+" vals = case mapM getNumeric vals of
    Just nums -> Right (AstInt (sum nums))
    Nothing -> Left "+: arguments must be numbers"
evalOp "*" [] = Right (AstInt 1)
evalOp "*" vals = case mapM getNumeric vals of
    Just nums -> Right (AstInt (product nums))
    Nothing -> Left "*: arguments must be numbers"
evalOp "-" [] = Left "-: expected at least 1 argument"
evalOp "-" (AstInt x:xs) = case mapM getInt xs of
    Just ns -> Right (AstInt (foldl (-) x ns))
    Nothing -> Left "-: arguments must be integers"
evalOp "-" _ = Left "-: arguments must be integers"
evalOp "/" [] = Left "/: expected at least 1 argument"
evalOp "/" [_] = Left "/: expected at least 2 arguments"
evalOp "/" (AstInt x:xs)
    | any isZero xs = Left "/: division by zero"
    | otherwise = case mapM getInt xs of
        Just ns -> Right (AstInt (foldl div x ns))
        Nothing -> Left "/: arguments must be integers"
  where isZero (AstInt y) = y == 0
        isZero _ = False
evalOp "/" _ = Left "/: arguments must be integers"
evalOp "%" [AstInt _, AstInt 0] = Left "%: division by zero"
evalOp "%" [AstInt x, AstInt y] = Right (AstInt (mod x y))
evalOp "%" _ = Left "%: expected exactly 2 integer arguments"
evalOp "==" [a,b] = Right (AstBool (a == b))
evalOp op _ = Left ("unknown procedure: " ++ op)

getInt :: Ast -> Maybe Int
getInt (AstInt n) = Just n
getInt _ = Nothing

getNumeric :: Ast -> Maybe Int
getNumeric (AstInt n) = Just n
getNumeric (AstFloat f) = Just (floor f)
getNumeric _ = Nothing
