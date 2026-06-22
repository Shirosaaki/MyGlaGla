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
         | ArrayAssign String Ast Ast               -- array[index] = value
         | Struct String [(String, Type)]            -- struct definition (name, fields)
         | StructFieldAssign String String Ast      -- struct.field = value
         | Block [Ast]                               -- sequence of statements
         | TypedVar String Type Ast                  -- variable with explicit type and init value
         | ClassDef String                           -- nom de la classe
                    [(String, Ast, Type)]            -- champs : (nom, valeur_défaut, type)
                    (Maybe (String, [String], Ast))  -- constructeur optionnel : (nom, params, body)
                    [(String, [String], Ast)]        -- méthodes : (nom, params, body)
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
parseTypeSExpr (SSymbol "int")    = Right TInt
parseTypeSExpr (SSymbol "float")  = Right TFloat
parseTypeSExpr (SSymbol "string") = Right TString
parseTypeSExpr (SSymbol "bool")   = Right TBool
parseTypeSExpr (SSymbol "char")   = Right TChar
parseTypeSExpr (SSymbol "void")   = Right TVoid
parseTypeSExpr (SSymbol other)    = Right (TCustom other)
parseTypeSExpr (SList [SSymbol "array-type", SSymbol base]) =
    Right (TCustom (base ++ "[]"))
parseTypeSExpr _ = Left "bad type"

makeCallArgs :: Ast -> [SExpr] -> Either String Ast
makeCallArgs fnAst args = fmap (Call fnAst) (mapM sexprToAST args)

-- ============================================================================
-- sexprToAST
-- Ordre des branches : du plus spécifique au plus générique.
-- Les branches WaifuLang sont intercalées avant les branches génériques.
-- ============================================================================

sexprToAST :: SExpr -> Either String Ast
sexprToAST (SSymbol "break")    = Right Break
sexprToAST (SSymbol "continue") = Right Continue
sexprToAST (SSymbol s)  = Right (AstSymbol s)
sexprToAST (SInt n)     = Right (AstInt n)
sexprToAST (SFloat f)   = Right (AstFloat f)
sexprToAST (SBool b)    = Right (AstBool b)
sexprToAST (SString s)  = Right (AstString s)
sexprToAST (SChar c)    = Right (AstChar c)
sexprToAST (SList [])   = Right (AstList [])

-- Handle parser's string S-expr form
sexprToAST (SList [SSymbol "string", SSymbol s]) = Right (AstString s)
sexprToAST (SList [SSymbol "string", SString s]) = Right (AstString s)

-- block: (block s1 s2 ...)
sexprToAST (SList (SSymbol "block" : xs)) =
    case mapM sexprToAST xs of
        Right asts -> Right (Block asts)
        Left e     -> Left e

-- return
sexprToAST (SList [SSymbol "return", expr]) =
    fmap Return (sexprToAST expr)

-- comment
sexprToAST (SList [SSymbol "comment", SString _]) = Right (AstList [])

-- -----------------------------------------------------------------------
-- if : WaifuLang émet (if cond thenSExpr elseSExpr) où then/else sont
-- chacun un SExpr quelconque (typiquement un (block ...)).
-- On convertit récursivement plutôt que de déstructurer comme une liste.
-- -----------------------------------------------------------------------
sexprToAST (SList [SSymbol "if", condS, thenS, elseS]) =
    case (sexprToAST condS, sexprToAST thenS, sexprToAST elseS) of
        (Right c, Right t, Right e) -> Right (IfElse c t e)
        (Left err, _, _)            -> Left err
        (_, Left err, _)            -> Left err
        (_, _, Left err)            -> Left err

-- -----------------------------------------------------------------------
-- while : WaifuLang émet (call while (cond body))
-- Le compilateur attend Call (AstSymbol "while") [cond, body], pas While.
-- -----------------------------------------------------------------------
sexprToAST (SList [SSymbol "call", SSymbol "while",
                   SList [condS, bodyS]]) =
    case (sexprToAST condS, sexprToAST bodyS) of
        (Right c, Right b) -> Right (Call (AstSymbol "while") [c, b])
        (Left e, _)        -> Left e
        (_, Left e)        -> Left e

-- -----------------------------------------------------------------------
-- for : WaifuLang émet (call for (v start limit body))
-- Le compilateur attend Call (AstSymbol "for") [AstSymbol v, start, limit, body].
-- -----------------------------------------------------------------------
sexprToAST (SList [SSymbol "call", SSymbol "for",
                   SList [SSymbol v, startS, limitS, bodyS]]) =
    case (sexprToAST startS, sexprToAST limitS, sexprToAST bodyS) of
        (Right s, Right l, Right b) ->
            Right (Call (AstSymbol "for") [AstSymbol v, s, l, b])
        (Left e, _, _) -> Left e
        (_, Left e, _) -> Left e
        (_, _, Left e) -> Left e

-- -----------------------------------------------------------------------
-- assign : WaifuLang émet (assign varName value)
-- -----------------------------------------------------------------------
sexprToAST (SList [SSymbol "assign", SSymbol name, valueS]) =
    fmap (Assign name) (sexprToAST valueS)

-- -----------------------------------------------------------------------
-- WaifuLang lists, maps, strings
-- -----------------------------------------------------------------------
sexprToAST (SList (SSymbol "list-create" : SSymbol name : items)) =
    case mapM sexprToAST items of
        Right is -> Right (Call (AstSymbol "list-create") (AstSymbol name : is))
        Left e   -> Left e

sexprToAST (SList [SSymbol "list-add", SSymbol listVar, mode, SList items]) =
    case mapM sexprToAST items of
        Right is -> Right (Call (AstSymbol "list-add") [AstSymbol listVar, modeAst, AstList is])
        Left e   -> Left e
  where modeAst = case mode of
          SSymbol s -> AstSymbol s
          SList [SSymbol "insert-after", nth, target] ->
              Call (AstSymbol "insert-after") [fromSInt nth, targetAst target]
          other -> AstSymbol (show other)
        targetAst (SSymbol s) = AstSymbol s
        targetAst t = case sexprToAST t of { Right a -> a; Left _ -> AstVoid }
        fromSInt (SInt n) = AstInt n
        fromSInt _ = AstInt 1

sexprToAST (SList [SSymbol "list-remove", SSymbol listVar, mode]) =
    Right (Call (AstSymbol "list-remove") [AstSymbol listVar, modeAst mode])
  where
    modeAst (SList [SSymbol m, a, b]) =
        Call (AstSymbol m) [fromS a, fromS b]
    modeAst (SList [SSymbol m, a]) =
        Call (AstSymbol m) [fromS a]
    modeAst other = AstSymbol (show other)
    fromS (SInt n) = AstInt n
    fromS (SSymbol s) = AstSymbol s
    fromS t = case sexprToAST t of { Right a -> a; Left _ -> AstVoid }

sexprToAST (SList (SSymbol "map-create" : SSymbol name : pairs)) =
    case mapM parsePair pairs of
        Right ps -> Right (Call (AstSymbol "map-create") (AstSymbol name : ps))
        Left e   -> Left e
  where
    parsePair (SList [k, v]) =
        case (sexprToAST k, sexprToAST v) of
            (Right ka, Right va) -> Right (AstList [ka, va])
            (Left e, _)          -> Left e
            (_, Left e)          -> Left e
    parsePair _ = Left "map-create: bad pair"

sexprToAST (SList [SSymbol "map-put", SSymbol name, k, v]) =
    case (sexprToAST k, sexprToAST v) of
        (Right ka, Right va) -> Right (Call (AstSymbol "map-put") [AstSymbol name, ka, va])
        (Left e, _)          -> Left e
        (_, Left e)          -> Left e

sexprToAST (SList [SSymbol "map-remove", SSymbol name, k]) =
    fmap (\ka -> Call (AstSymbol "map-remove") [AstSymbol name, ka]) (sexprToAST k)

sexprToAST (SList [SSymbol "list-at", SSymbol listVar, idx]) =
    fmap (\i -> Call (AstSymbol "list-at") [AstSymbol listVar, i]) (sexprToAST idx)

sexprToAST (SList [SSymbol "list-len", e]) =
    fmap (\a -> Call (AstSymbol "list-len") [a]) (sexprToAST e)

sexprToAST (SList [SSymbol "list-empty", SSymbol v]) =
    Right (Call (AstSymbol "list-empty") [AstSymbol v])

sexprToAST (SList [SSymbol "contains", SSymbol v, e]) =
    fmap (\a -> Call (AstSymbol "contains") [AstSymbol v, a]) (sexprToAST e)
sexprToAST (SList [SSymbol "list-contains", SSymbol v, e]) =
    fmap (\a -> Call (AstSymbol "list-contains") [AstSymbol v, a]) (sexprToAST e)

sexprToAST (SList [SSymbol "map-at", SSymbol m, k]) =
    fmap (\ka -> Call (AstSymbol "map-at") [AstSymbol m, ka]) (sexprToAST k)

sexprToAST (SList [SSymbol "map-contains", SSymbol m, k]) =
    fmap (\ka -> Call (AstSymbol "map-contains") [AstSymbol m, ka]) (sexprToAST k)

sexprToAST (SList [SSymbol "str-len", e]) =
    fmap (\a -> Call (AstSymbol "str-len") [a]) (sexprToAST e)

sexprToAST (SList [SSymbol "str-split", s, sep]) =
    case (sexprToAST s, sexprToAST sep) of
        (Right sa, Right sb) -> Right (Call (AstSymbol "str-split") [sa, sb])
        (Left e, _)          -> Left e
        (_, Left e)          -> Left e

sexprToAST (SList [SSymbol "str-contains", SSymbol s, n]) =
    fmap (\na -> Call (AstSymbol "str-contains") [AstSymbol s, na]) (sexprToAST n)

sexprToAST (SList [SSymbol "for-each", SSymbol itemVar, SSymbol listVar, bodyS]) =
    case sexprToAST bodyS of
        Right b -> Right (Call (AstSymbol "for-each") [AstSymbol itemVar, AstSymbol listVar, b])
        Left e  -> Left e

sexprToAST (SList [SSymbol "call", SSymbol "darkness", SList [expr]]) =
    fmap (\e -> Call (AstSymbol "darkness") [e]) (sexprToAST expr)

-- assign avec member-access (TheShow)
sexprToAST (SList [SSymbol "assign",
                   SList (SSymbol "member-access" : SSymbol obj : SSymbol field : []),
                   valueS]) =
    fmap (Assign (obj ++ "." ++ field)) (sexprToAST valueS)

-- -----------------------------------------------------------------------
-- define : WaifuLang émet (define varName value type)
--          ou               (define varName typeSymbol)   (déclaration seule)
-- -----------------------------------------------------------------------
sexprToAST (SList [SSymbol "define", SSymbol name, valS, tyS]) =
    case (sexprToAST valS, parseTypeSExpr tyS) of
        (Right v, Right t) -> Right (Define name (Just t) v)
        (Left e, _)        -> Left e
        (_, Left e)        -> Left e

sexprToAST (SList [SSymbol "define", SSymbol name, SSymbol ty]) =
    case parseTypeExprLocal (SSymbol ty) of
        Right t -> Right (Define name (Just t) AstVoid)
        Left e  -> Left e
  where
    parseTypeExprLocal (SSymbol "int")    = Right TInt
    parseTypeExprLocal (SSymbol "float")  = Right TFloat
    parseTypeExprLocal (SSymbol "string") = Right TString
    parseTypeExprLocal (SSymbol "bool")   = Right TBool
    parseTypeExprLocal (SSymbol other)    = Right (TCustom other)
    parseTypeExprLocal (SList [SSymbol "array-type", SSymbol base]) =
        Right (TCustom (base ++ "[]"))
    parseTypeExprLocal _ = Left "define: bad type"

-- -----------------------------------------------------------------------
-- Branches héritées de TheShow / génériques
-- -----------------------------------------------------------------------

-- top-level sequence of statements
sexprToAST (SList xs) | all isSList xs =
    case mapM sexprToAST xs of
        Right bodyAsts ->
            case bodyAsts of
                [def@(Define name _ (AstLambda params _))] | null params ->
                    Right (Block [def, Call (AstSymbol name) []])
                _ -> Right (Block bodyAsts)
        Left err -> Left err
  where
    isSList (SList _) = True
    isSList _         = False

-- function declaration: (fun name (params...) ret bodylist)
sexprToAST (SList [SSymbol "fun", SSymbol name, SList params, _ret, SList body]) =
    case mapM extractParamName params of
        Right pnames ->
            case mapM sexprToAST body of
                Right bodyAsts -> Right (Define name Nothing (AstLambda pnames (Block bodyAsts)))
                Left err       -> Left err
        Left err -> Left err

-- variable declaration: (eric name type [value])
sexprToAST (SList (SSymbol "eric" : SSymbol name : ty : xs)) =
    let valSexpr = case xs of { (v:_) -> v; [] -> SSymbol "unit" }
        parseTypeExpr (SSymbol "int")    = Right TInt
        parseTypeExpr (SSymbol "float")  = Right TFloat
        parseTypeExpr (SSymbol "string") = Right TString
        parseTypeExpr (SSymbol "bool")   = Right TBool
        parseTypeExpr (SSymbol other)    = Right (TCustom other)
        parseTypeExpr (SList [SSymbol "array-type", SSymbol base]) =
            Right (TCustom (base ++ "[]"))
        parseTypeExpr _ = Left "eric: bad type"
    in case (sexprToAST valSexpr, parseTypeExpr ty) of
        (Right v, Right t) -> Right (Define name (Just t) v)
        (Left e, _)        -> Left e
        (_, Left e)        -> Left e
sexprToAST (SList (SSymbol "eric" : _)) = Left "eric: bad syntax"

-- assignment: (= target value)
sexprToAST (SList [SSymbol "=", target, value]) =
    case target of
        SSymbol name ->
            fmap (Assign name) (sexprToAST value)
        SList (SSymbol "index" : SSymbol arr : idx : _) ->
            case (sexprToAST idx, sexprToAST value) of
                (Right i, Right v) -> Right (ArrayAssign arr i v)
                (Left e, _)        -> Left e
                (_, Left e)        -> Left e
        _ -> Left "=: unsupported target"

-- array access: (index arr idx)
sexprToAST (SList [SSymbol "index", arr, idx]) =
    case (sexprToAST arr, sexprToAST idx) of
        (Right a, Right i) -> Right (Call (AstSymbol "array-access") [a, i])
        (Left e, _)        -> Left e
        (_, Left e)        -> Left e

-- for loop (TheShow): (aer var (range s e) body)
sexprToAST (SList [SSymbol "aer", SSymbol var,
                   SList (SSymbol "range" : s : e : []), SList body]) =
    case (sexprToAST s, sexprToAST e, mapM sexprToAST body) of
        (Right rs, Right re, Right bodyAsts) ->
            Right (For var (Block [rs, re]) (Block bodyAsts))
        (Left err, _, _) -> Left err
        (_, Left err, _) -> Left err
        (_, _, Left err) -> Left err

-- while (TheShow): (darius cond body)
sexprToAST (SList [SSymbol "darius", cond, SList body]) =
    case (sexprToAST cond, mapM sexprToAST body) of
        (Right c, Right bodyAsts) -> Right (While c (Block bodyAsts))
        (Left e, _)               -> Left e
        (_, Left e)               -> Left e

-- print/call form: (call name (args...))
-- Note : while/for WaifuLang interceptés plus haut ; ici on tombe sur les
-- appels de fonctions ordinaires (peric, etc.).
sexprToAST (SList [SSymbol "call", SSymbol name, SList args]) =
    case mapM sexprToAST args of
        Right argAsts -> Right (Call (AstSymbol name) argAsts)
        Left err      -> Left err

-- struct
sexprToAST (SList (SSymbol "struct" : SSymbol name : fields)) =
    let parseField (SList [SSymbol fname, SSymbol tyStr]) =
            case parseTypeSExpr (SSymbol tyStr) of
                Right t -> Right (fname, t)
                Left e  -> Left e
        parseField _ = Left "struct field: bad syntax"
        isField (SList [SSymbol _, SSymbol _]) = True
        isField _                              = False
        (fieldExprs, rest) = span isField fields
    in case mapM parseField fieldExprs of
        Right fs ->
            case rest of
                [] -> Right (Struct name fs)
                _  -> case mapM sexprToAST rest of
                        Right more -> Right (Block (Struct name fs : more))
                        Left e     -> Left e
        Left err -> Left err

-- lambda
sexprToAST (SList [SSymbol "lambda", SList params, body]) =
    case mapM paramNameE params of
        Right pn ->
            fmap (AstLambda pn) (sexprToAST body)
        Left err -> Left err
sexprToAST (SList [SSymbol "lambda", _, _]) = Left "lambda: parameters must be a list"
sexprToAST (SList [SSymbol "lambda", _])    = Left "lambda: missing body"
sexprToAST (SList [SSymbol "lambda"])       = Left "lambda: missing parameters and body"
sexprToAST (SList (SSymbol "lambda" : _))   = Left "lambda: bad syntax"

-- -----------------------------------------------------------------------
-- class : WaifuLang émet (class name field... constructor? method*...)
-- -----------------------------------------------------------------------
sexprToAST (SList (SSymbol "class" : SSymbol className : members)) =
    let -- Sépare les membres en champs, constructeur, méthodes
        parseMembers [] fields ctor methods = Right (fields, ctor, reverse methods)
        parseMembers (m:ms) fields ctor methods = case m of
            -- Champ : (field name val type)
            SList [SSymbol "field", SSymbol fname, valS, tyS] ->
                case (sexprToAST valS, parseTypeSExpr tyS) of
                    (Right v, Right t) ->
                        parseMembers ms (fields ++ [(fname, v, t)]) ctor methods
                    (Left e, _) -> Left e
                    (_, Left e) -> Left e
            -- Constructeur : (constructor (params ...) body)
            SList [SSymbol "constructor", SList (_ : paramSpecs), bodyS] ->
                case (extractParams paramSpecs, sexprToAST bodyS) of
                    (Right ps, Right b) ->
                        parseMembers ms fields (Just ("born", ps, b)) methods
                    (Left e, _) -> Left e
                    (_, Left e) -> Left e
            -- Méthode : (method name (params ...) body)
            SList [SSymbol "method", SSymbol mname, SList (_ : paramSpecs), bodyS] ->
                case (extractParams paramSpecs, sexprToAST bodyS) of
                    (Right ps, Right b) ->
                        parseMembers ms fields ctor ((mname, ps, b) : methods)
                    (Left e, _) -> Left e
                    (_, Left e) -> Left e
            other -> Left ("class: membre inconnu : " ++ show other)

        -- Extrait les noms de paramètres depuis [(name type) ...]
        extractParams [] = Right []
        extractParams (SList [SSymbol pname, _] : rest) =
            fmap (pname :) (extractParams rest)
        extractParams (other : _) =
            Left ("class: param mal formé : " ++ show other)

    in case parseMembers members [] Nothing [] of
        Right (fields, ctor, methods) ->
            Right (ClassDef className fields ctor methods)
        Left err -> Left err

-- generic application: (fn arg1 arg2 ...)
sexprToAST (SList (fn:args)) =
    case sexprToAST fn of
        Left err    -> Left err
        Right fnAst -> makeCallArgs fnAst args

-- ============================================================================
-- evalAST (inchangé)
-- ============================================================================

evalAST :: Env -> Ast -> EvalResult
evalAST env (AstInt n)    = Right (AstInt n, env)
evalAST env (AstFloat f)  = Right (AstFloat f, env)
evalAST env (AstBool b)   = Right (AstBool b, env)
evalAST env (AstString s) = Right (AstString s, env)
evalAST env (AstChar c)   = Right (AstChar c, env)
evalAST env AstVoid       = Right (AstVoid, env)
evalAST env closure@(AstClosure _ _ _) = Right (closure, env)
evalAST env (AstSymbol s) =
    case lookup s env of
        Just v  -> Right (v, env)
        Nothing -> Left ("variable " ++ s ++ " is not bound")
evalAST env (Define name _ty val) =
    case val of
        AstLambda params body ->
            let updatedEnv = (name, AstClosure params body updatedEnv) : env
            in Right (AstVoid, updatedEnv)
        _ ->
            case evalAST env val of
                Right (v, env') -> Right (AstVoid, (name, v) : env')
                Left err        -> Left err
evalAST env (AstLambda params body) =
    Right (AstClosure params body env, env)
evalAST env (AstList xs) = evalSeq env xs
  where
    evalSeq e []      = Right (AstList [], e)
    evalSeq e [x]     = evalAST e x
    evalSeq e (x:xs') =
        case evalAST e x of
            Right (_, e') -> evalSeq e' xs'
            Left err      -> Left err
evalAST env (IfElse cond thenExpr elseExpr) =
    case evalAST env cond of
        Right (AstBool True,  env1) -> evalAST env1 thenExpr
        Right (AstBool False, env1) -> evalAST env1 elseExpr
        Right (_, _)                -> Left "if: condition must be a boolean"
        Left err                    -> Left err
evalAST env (Block stmts) = evalBlock env stmts
evalAST env (Call fnAst args) = evalCall env fnAst args
evalAST env (ClassDef _ _ _ _) = Right (AstVoid, env)  -- géré par le compilateur
evalAST _ other = Left ("Unsupported AST node: " ++ show other)

evalBlock :: Env -> [Ast] -> EvalResult
evalBlock env []      = Right (AstVoid, env)
evalBlock env [s]     = evalAST env s
evalBlock env (s:rest) =
    case evalAST env s of
        Right (_, env') -> evalBlock env' rest
        Left err        -> Left err

evalCall :: Env -> Ast -> [Ast] -> EvalResult
evalCall env (AstSymbol op) args = evalOpCall env op args
evalCall env fnAst args =
    case evalAST env fnAst of
        Right (AstClosure _ _ _, _) -> evalClosureCall env args fnAst
        Right (other, _)            -> Left ("attempt to apply non-procedure: " ++ show other)
        Left err                    -> Left err

evalClosureCall :: Env -> [Ast] -> Ast -> EvalResult
evalClosureCall env args closureAst =
    case evalAST env closureAst of
        Right (vc@(AstClosure params _ _), _) ->
            evalClosureCallChecked env args closureAst params vc
        _ -> Left "Invalid closure"

evalClosureCallChecked :: Env -> [Ast] -> Ast -> [String] -> Ast -> EvalResult
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
                        Left err       -> Left err
                _ -> Left "attempt to call non-procedure"
        Left err -> Left err

evalBuiltinOp :: Env -> String -> [Ast] -> EvalResult
evalBuiltinOp env op args =
    case evalArgs env args of
        Right (argVals, env') ->
            case evalOp op argVals of
                Right v  -> Right (v, env')
                Left err -> Left err
        Left err -> Left err

evalOpCall :: Env -> String -> [Ast] -> EvalResult
evalOpCall env "if" [cond, thenExpr, elseExpr] =
    case evalAST env cond of
        Right (AstBool True,  env1) -> evalAST env1 thenExpr
        Right (AstBool False, env1) -> evalAST env1 elseExpr
        Right (_, _)                -> Left "if: condition must be a boolean"
        Left err                    -> Left err
evalOpCall _ "if" _ = Left "if: bad syntax"
evalOpCall env "==" args =
    case evalArgs env args of
        Right ([a, b], env') -> Right (AstBool (a == b), env')
        Right (_, _)         -> Left "==: expected 2 arguments"
        Left err             -> Left err
evalOpCall env "<" args =
    case evalArgs env args of
        Right ([AstInt a, AstInt b], env')     -> Right (AstBool (a < b), env')
        Right ([AstFloat a, AstFloat b], env') -> Right (AstBool (a < b), env')
        Right ([_, _], _)                      -> Left "<: arguments must be numbers"
        Right (_, _)                           -> Left "<: expected 2 arguments"
        Left err                               -> Left err
evalOpCall env ">" args =
    case evalArgs env args of
        Right ([AstInt a, AstInt b], env')     -> Right (AstBool (a > b), env')
        Right ([AstFloat a, AstFloat b], env') -> Right (AstBool (a > b), env')
        Right ([_, _], _)                      -> Left ">: arguments must be numbers"
        Right (_, _)                           -> Left ">: expected 2 arguments"
        Left err                               -> Left err
evalOpCall env "<=" args =
    case evalArgs env args of
        Right ([AstInt a, AstInt b], env')     -> Right (AstBool (a <= b), env')
        Right ([AstFloat a, AstFloat b], env') -> Right (AstBool (a <= b), env')
        Right ([_, _], _)                      -> Left "<=: arguments must be numbers"
        Right (_, _)                           -> Left "<=: expected 2 arguments"
        Left err                               -> Left err
evalOpCall env ">=" args =
    case evalArgs env args of
        Right ([AstInt a, AstInt b], env')     -> Right (AstBool (a >= b), env')
        Right ([AstFloat a, AstFloat b], env') -> Right (AstBool (a >= b), env')
        Right ([_, _], _)                      -> Left ">=: arguments must be numbers"
        Right (_, _)                           -> Left ">=: expected 2 arguments"
        Left err                               -> Left err
evalOpCall env "peric" args =
    case evalArgs env args of
        Right ([AstString s], env') -> Right (AstString s, env')
        Right ([a], env')           -> Right (AstString (astToString a), env')
        Right (asList, env')        -> Right (AstString (concatMap astToString asList), env')
        Left err                    -> Left err
  where
    astToString (AstString s) = s
    astToString (AstInt n)    = show n
    astToString (AstFloat f)  = show f
    astToString (AstBool True)  = "1"
    astToString (AstBool False) = "0"
    astToString (AstChar c)   = [c]
    astToString other         = show other
evalOpCall env "string-interp" args =
    case evalArgs env args of
        Right (parts, env') -> Right (AstString (concatMap astToString parts), env')
        Left err            -> Left err
  where
    astToString (AstString s)   = s
    astToString (AstInt n)      = show n
    astToString (AstFloat f)    = show f
    astToString (AstBool True)  = "1"
    astToString (AstBool False) = "0"
    astToString (AstChar c)     = [c]
    astToString other           = show other
evalOpCall env "range" args =
    case evalArgs env args of
        Right ([AstInt _, AstInt _], env') -> Right (AstString "range", env')
        Right (_, _)                       -> Left "range: expected 2 integer arguments"
        Left err                           -> Left err
evalOpCall env op args =
    case lookup op env of
        Just (AstClosure _ _ _) -> evalClosureCall env args (AstSymbol op)
        Just _                  -> Left (op ++ " is not a procedure")
        Nothing                 -> evalBuiltinOp env op args

evalArgs :: Env -> [Ast] -> Either String ([Ast], Env)
evalArgs env [] = Right ([], env)
evalArgs env (x:xs) =
    case evalAST env x of
        Right (v, env1) ->
            case evalArgs env1 xs of
                Right (vs, env2) -> Right (v:vs, env2)
                Left err         -> Left err
        Left err -> Left err

evalOp :: String -> [Ast] -> Either String Ast
evalOp "+" [] = Right (AstInt 0)
evalOp "+" vals = case mapM getNumeric vals of
    Just nums -> Right (AstInt (sum nums))
    Nothing   -> Left "+: arguments must be numbers"
evalOp "*" [] = Right (AstInt 1)
evalOp "*" vals = case mapM getNumeric vals of
    Just nums -> Right (AstInt (product nums))
    Nothing   -> Left "*: arguments must be numbers"
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
  where isZero (AstInt y) = y == 0; isZero _ = False
evalOp "/" _ = Left "/: arguments must be integers"
evalOp "%" [AstInt _, AstInt 0] = Left "%: division by zero"
evalOp "%" [AstInt x, AstInt y] = Right (AstInt (mod x y))
evalOp "%" _ = Left "%: expected exactly 2 integer arguments"
evalOp "==" [a, b] = Right (AstBool (a == b))
evalOp op _ = Left ("unknown procedure: " ++ op)

getInt :: Ast -> Maybe Int
getInt (AstInt n) = Just n
getInt _          = Nothing

getFloat :: Ast -> Maybe Double
getFloat (AstFloat f) = Just f
getFloat (AstInt n)   = Just (fromIntegral n)
getFloat _            = Nothing

getNumeric :: Ast -> Maybe Int
getNumeric (AstInt n)   = Just n
getNumeric (AstFloat f) = Just (floor f)
getNumeric _            = Nothing