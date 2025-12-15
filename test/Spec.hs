{-
-- EPITECH PROJECT, 2025
-- test
-- File description:
-- main of the glory glados
-}
import Test.Hspec
import Lib (SExpr(..), Ast(..), sexprToAST, evalAST,
            parseSExprMultipleEither, defName, defValue)
import qualified Theshow.Parser as TSL
import qualified Paths_glados as P
import Data.Version (showVersion)
import Data.List (isSuffixOf)
import System.Environment (setEnv, unsetEnv)
import Data.Either (isLeft, isRight)

type Env = [(String, Ast)]

-- Helper to evaluate from empty environment
eval :: Ast -> Maybe Ast
eval a = case evalAST [] a of
    Right (res, _) -> Just res
    Left _ -> Nothing

-- Parse and evaluate a program string, returning the result
runProgram :: String -> Either String Ast
runProgram input = case parseSExprMultipleEither input of
    Left err -> Left err
    Right sexprs -> evalProgram [] sexprs

evalProgram :: Env -> [SExpr] -> Either String Ast
evalProgram _ [] = Left "empty program"
evalProgram env [s] = do
    ast <- sexprToAST s
    (res, _) <- evalAST env ast
    return res
evalProgram env (s:ss) = do
    ast <- sexprToAST s
    (_, env') <- evalAST env ast
    evalProgram env' ss

-- Helper to check result matches expected
shouldEvalTo :: String -> Ast -> Expectation
shouldEvalTo prog expected = runProgram prog `shouldBe` Right expected

-- Helper to check program fails
shouldFail :: String -> Expectation
shouldFail prog = runProgram prog `shouldSatisfy` isLeft
main :: IO ()
main = hspec $ do
    describe "sexprToAST" $ do
        it "converts SInt to AstInt" $
            sexprToAST (SInt 42) `shouldBe` Right (AstInt 42)
        it "converts SSymbol to AstSymbol" $
            sexprToAST (SSymbol "foo") `shouldBe` Right (AstSymbol "foo")
        it "converts SList [] to AstList []" $
            sexprToAST (SList []) `shouldBe` Right (AstList [])
        it "converts define form" $
            sexprToAST (SList [SSymbol "define", SSymbol "x", SInt 1])
                `shouldBe` Right (Define "x" Nothing (AstInt 1))
        it "returns Left for malformed define" $
            sexprToAST (SList [SSymbol "define", SSymbol "x"])
                `shouldSatisfy` isLeft
        it "converts function call" $
            sexprToAST (SList [SSymbol "+", SInt 1, SInt 2])
                `shouldBe` Right (Call (AstSymbol "+") [AstInt 1, AstInt 2])
        it "allows non-symbol function position" $
            sexprToAST (SList [SInt 1, SInt 2])
                `shouldBe` Right (Call (AstInt 1) [AstInt 2])
        it "returns Left when define name is not a symbol" $
            sexprToAST (SList [SSymbol "define", SInt 1, SInt 2])
                `shouldSatisfy` isLeft
        it "converts SBool to AstBool" $
            sexprToAST (SBool True) `shouldBe` Right (AstBool True)

    describe "evalAST" $ do
        it "evaluates AstBool True" $
            eval (AstBool True) `shouldBe` Just (AstBool True)
        it "evaluates AstBool False" $
            eval (AstBool False) `shouldBe` Just (AstBool False)
        it "evaluates Define" $
            eval (Define "x" Nothing (AstInt 42)) `shouldBe` Just AstVoid
        it "evaluates AstInt" $
            eval (AstInt 5) `shouldBe` Just (AstInt 5)
        it "evaluates AstSymbol (unbound)" $
            eval (AstSymbol "foo") `shouldBe` Nothing
        it "evaluates addition" $
            eval (Call (AstSymbol "+") [AstInt 1, AstInt 2])
                `shouldBe` Just (AstInt 3)
        it "evaluates multiplication" $
            eval (Call (AstSymbol "*") [AstInt 2, AstInt 3])
                `shouldBe` Just (AstInt 6)
        it "evaluates subtraction" $
            eval (Call (AstSymbol "-") [AstInt 5, AstInt 2])
                `shouldBe` Just (AstInt 3)
        it "evaluates division" $
            eval (Call (AstSymbol "div") [AstInt 8, AstInt 2])
                `shouldBe` Just (AstInt 4)
        it "returns Nothing for division by zero" $
            eval (Call (AstSymbol "div") [AstInt 8, AstInt 0])
                `shouldBe` Nothing
        it "returns Nothing for non-int args" $
            eval (Call (AstSymbol "+") [AstSymbol "foo"]) `shouldBe` Nothing
        it "returns Nothing for subtraction with no args" $
            eval (Call (AstSymbol "-") []) `shouldBe` Nothing
        it "addition with no args returns 0" $
            eval (Call (AstSymbol "+") []) `shouldBe` Just (AstInt 0)
        it "multiplication with no args returns 1" $
            eval (Call (AstSymbol "*") []) `shouldBe` Just (AstInt 1)
        it "addition with multiple args" $
            eval (Call (AstSymbol "+") [AstInt 1, AstInt 2, AstInt 3])
                `shouldBe` Just (AstInt 6)
        it "multiplication with multiple args" $
            eval (Call (AstSymbol "*") [AstInt 2, AstInt 3, AstInt 4])
                `shouldBe` Just (AstInt 24)
        it "subtraction with multiple args" $
            eval (Call (AstSymbol "-") [AstInt 10, AstInt 2, AstInt 3])
                `shouldBe` Just (AstInt 5)
        it "division with multiple args" $
            eval (Call (AstSymbol "div") [AstInt 24, AstInt 2, AstInt 3])
                `shouldBe` Just (AstInt 4)
        it "subtraction with single arg returns the arg" $
            eval (Call (AstSymbol "-") [AstInt 5]) `shouldBe` Just (AstInt 5)
        it "division with no args returns Nothing" $
            eval (Call (AstSymbol "div") []) `shouldBe` Nothing
        it "unknown operator returns Nothing" $
            eval (Call (AstSymbol "foo") [AstInt 1, AstInt 2])
                `shouldBe` Nothing
        it "Call with non-AstSymbol function returns Nothing" $
            eval (Call (AstInt 99) [AstInt 1]) `shouldBe` Nothing
        it "Call with nested failing arg returns Nothing" $
            eval (Call (AstSymbol "+") [Call (AstSymbol "bad") [AstInt 1]])
                `shouldBe` Nothing

    describe "Predicates and if" $ do
        it "eq? returns true for equal ints" $
            eval (Call (AstSymbol "eq?") [AstInt 1, AstInt 1])
                `shouldBe` Just (AstBool True)
        it "eq? returns false for different ints" $
            eval (Call (AstSymbol "eq?") [AstInt 1, AstInt 2])
                `shouldBe` Just (AstBool False)
        it "< returns true when first < second" $
            eval (Call (AstSymbol "<") [AstInt 1, AstInt 2])
                `shouldBe` Just (AstBool True)
        it "< returns false when first >= second" $
            eval (Call (AstSymbol "<") [AstInt 2, AstInt 1])
                `shouldBe` Just (AstBool False)
        it "if chooses then branch when condition true" $
            eval (Call (AstSymbol "if") [AstBool True, AstInt 1, AstInt 2])
                `shouldBe` Just (AstInt 1)
        it "if chooses else branch when condition false" $
            eval (Call (AstSymbol "if") [AstBool False, AstInt 1, AstInt 2])
                `shouldBe` Just (AstInt 2)
        it "if returns Nothing for non-bool condition" $
            eval (Call (AstSymbol "if") [AstInt 1, AstInt 1, AstInt 2])
                `shouldBe` Nothing
        it "eq? with wrong arity returns Nothing" $
            eval (Call (AstSymbol "eq?") [AstInt 1]) `shouldBe` Nothing
        it "< with non-int arg returns Nothing" $
            eval (Call (AstSymbol "<") [AstInt 1, AstSymbol "x"])
                `shouldBe` Nothing
        it "mod returns remainder when divisor non-zero" $
            eval (Call (AstSymbol "mod") [AstInt 5, AstInt 2])
                `shouldBe` Just (AstInt 1)
        it "mod returns Nothing when divisor is zero" $
            eval (Call (AstSymbol "mod") [AstInt 5, AstInt 0])
                `shouldBe` Nothing

    describe "Atoms Tests" $ do
        it "integer positive" $ "42" `shouldEvalTo` AstInt 42
        it "integer negative" $ "-42" `shouldEvalTo` AstInt (-42)
        it "integer zero" $ "0" `shouldEvalTo` AstInt 0
        it "boolean true" $ "#t" `shouldEvalTo` AstBool True
        it "boolean false" $ "#f" `shouldEvalTo` AstBool False
        it "symbol simple" $ "(define foo 42)\nfoo" `shouldEvalTo` AstInt 42

    describe "Builtin Functions Tests" $ do
        it "add simple" $ "(+ 2 3)" `shouldEvalTo` AstInt 5
        it "add negative" $ "(+ 2 -3)" `shouldEvalTo` AstInt (-1)
        it "add zero" $ "(+ 5 0)" `shouldEvalTo` AstInt 5
        it "sub simple" $ "(- 5 2)" `shouldEvalTo` AstInt 3
        it "sub negative" $ "(- 5 -2)" `shouldEvalTo` AstInt 7
        it "sub result negative" $ "(- 2 5)" `shouldEvalTo` AstInt (-3)
        it "mul simple" $ "(* 2 3)" `shouldEvalTo` AstInt 6
        it "mul negative" $ "(* 2 -3)" `shouldEvalTo` AstInt (-6)
        it "mul zero" $ "(* 5 0)" `shouldEvalTo` AstInt 0
        it "mul two negatives" $ "(* -2 -3)" `shouldEvalTo` AstInt 6
        it "div simple" $ "(div 10 2)" `shouldEvalTo` AstInt 5
        it "div truncate" $ "(div 10 3)" `shouldEvalTo` AstInt 3
        it "div negative dividend" $ "(div -10 2)" `shouldEvalTo` AstInt (-5)
        it "div negative divisor" $ "(div 10 -2)" `shouldEvalTo` AstInt (-5)
        it "mod simple" $ "(mod 10 3)" `shouldEvalTo` AstInt 1
        it "mod exact" $ "(mod 10 2)" `shouldEvalTo` AstInt 0
        it "eq equal int" $ "(eq? 5 5)" `shouldEvalTo` AstBool True
        it "eq diff int" $ "(eq? 5 6)" `shouldEvalTo` AstBool False
        it "eq bool true" $ "(eq? #t #t)" `shouldEvalTo` AstBool True
        it "eq bool false" $ "(eq? #f #f)" `shouldEvalTo` AstBool True
        it "eq diff bool" $ "(eq? #t #f)" `shouldEvalTo` AstBool False
        it "eq expressions" $ "(eq? (+ 1 2) (- 5 2))" `shouldEvalTo` AstBool True
        it "less true" $ "(< 1 5)" `shouldEvalTo` AstBool True
        it "less false" $ "(< 5 1)" `shouldEvalTo` AstBool False
        it "less equal" $ "(< 5 5)" `shouldEvalTo` AstBool False
        it "less negatives" $ "(< -5 -1)" `shouldEvalTo` AstBool True
        it "less expressions" $ "(< (+ 3 2) (- 3 2))" `shouldEvalTo` AstBool False
        it "nested arithmetic" $ "(+ 1 (* 2 (- 10 5)))" `shouldEvalTo` AstInt 11
        it "complex arithmetic" $
            "(+ (* 6 7) (- 10 (div 20 4)))" `shouldEvalTo` AstInt 47

    describe "Conditional (if) Tests" $ do
        it "if true" $ "(if #t 1 2)" `shouldEvalTo` AstInt 1
        it "if false" $ "(if #f 1 2)" `shouldEvalTo` AstInt 2
        it "if with comparison" $
            "(if (< 5 10) (* 3 7) (* 3 8))" `shouldEvalTo` AstInt 21
        it "if nested" $
            "(if #t (if #f 1 2) 3)" `shouldEvalTo` AstInt 2
        it "if with eq" $
            "(if (eq? 5 5) 100 200)" `shouldEvalTo` AstInt 100
        it "if complex branches" $
            "(if (< 1 2) (+ 10 20) (- 10 20))" `shouldEvalTo` AstInt 30
        it "if returns bool" $
            "(if (< 1 2) #t #f)" `shouldEvalTo` AstBool True
        it "if chain" $
            "(if #f 1 (if #t 2 3))" `shouldEvalTo` AstInt 2
        it "if deeply nested" $
            "(if #t (if #t (if #t (if #t 5 4) 3) 2) 1)"
                `shouldEvalTo` AstInt 5

    describe "Lambda Tests" $ do
        it "lambda immediate call" $
            "((lambda (a b) (+ a b)) 1 2)" `shouldEvalTo` AstInt 3
        it "lambda no args call" $
            "((lambda () 42))" `shouldEvalTo` AstInt 42
        it "lambda assigned" $
            "(define add (lambda (a b) (+ a b)))\n(add 3 4)"
                `shouldEvalTo` AstInt 7
        it "lambda nested" $
            "(define make-adder (lambda (x) (lambda (y) (+ x y))))\n\
            \(define add5 (make-adder 5))\n\
            \(add5 5)" `shouldEvalTo` AstInt 10
        it "lambda closure" $
            "(define x 10)\n\
            \(define add-to-x (lambda (y) (+ x y)))\n\
            \(add-to-x 5)" `shouldEvalTo` AstInt 15
        it "lambda shadowing" $
            "(define x 100)\n\
            \(define func (lambda (x) (+ x 2)))\n\
            \(func 5)" `shouldEvalTo` AstInt 7
        it "lambda many params" $
            "(define compute (lambda (a b c d e) \
            \(+ a (+ b (+ c (+ d e))))))\n\
            \(compute 1 2 3 4 40)" `shouldEvalTo` AstInt 50
        it "lambda curried call" $
            "(define curry-add (lambda (a) (lambda (b) (+ a b))))\n\
            \(define add5 (curry-add 5))\n\
            \(add5 7)" `shouldEvalTo` AstInt 12
        it "lambda as argument" $
            "(define apply-twice (lambda (f x) (f (f x))))\n\
            \(define double (lambda (x) (+ x x)))\n\
            \(apply-twice double 2)" `shouldEvalTo` AstInt 8
        it "lambda complex body" $
            "(define complex (lambda (a b) \
            \(if (< a b) (+ a b) (- a b))))\n\
            \(complex 100 10)" `shouldEvalTo` AstInt 90
        it "lambda returns bool" $
            "(define is-positive (lambda (x) (if (< 0 x) #t #f)))\n\
            \(is-positive 5)" `shouldEvalTo` AstBool True

    describe "Define/Binding Tests" $ do
        it "define simple" $
            "(define x 42)\nx" `shouldEvalTo` AstInt 42
        it "define expression" $
            "(define x (+ 3 7))\nx" `shouldEvalTo` AstInt 10
        it "define boolean true" $
            "(define b #t)\nb" `shouldEvalTo` AstBool True
        it "define boolean false" $
            "(define b #f)\nb" `shouldEvalTo` AstBool False
        it "define multiple" $
            "(define a 10)\n(define b 20)\n(+ a b)" `shouldEvalTo` AstInt 30
        it "define chained" $
            "(define a 10)\n(define b a)\n(define c (* b b))\nc"
                `shouldEvalTo` AstInt 100
        it "define named function" $
            "(define (add a b) (+ a b))\n(add 3 4)" `shouldEvalTo` AstInt 7
        it "define named function no args" $
            "(define (get-42) 42)\n(get-42)" `shouldEvalTo` AstInt 42
        it "define named function single" $
            "(define (square x) (* x x))\n(square 5)" `shouldEvalTo` AstInt 25
        it "define named function many" $
            "(define (sum3 a b c) (+ a (+ b c)))\n(sum3 5 5 5)"
                `shouldEvalTo` AstInt 15
        it "define redefine" $
            "(define x 100)\n(define x 200)\nx" `shouldEvalTo` AstInt 200
        it "define negative" $
            "(define x -42)\nx" `shouldEvalTo` AstInt (-42)
        it "define zero" $
            "(define x 0)\nx" `shouldEvalTo` AstInt 0
        it "define complex expr" $
            "(define x (+ (* 2 3) (- 20 5)))\nx" `shouldEvalTo` AstInt 21

    describe "Complex Programs Tests" $ do
        it "factorial" $
            "(define (fact x) \
            \(if (eq? x 1) 1 (* x (fact (- x 1)))))\n\
            \(fact 10)" `shouldEvalTo` AstInt 3628800
        it "factorial lambda" $
            "(define fact (lambda (n) \
            \(if (eq? n 0) 1 (* n (fact (- n 1))))))\n\
            \(fact 5)" `shouldEvalTo` AstInt 120
        it "greater than" $
            "(define (> a b) \
            \(if (eq? a b) #f (if (< a b) #f #t)))\n\
            \(> 10 5)" `shouldEvalTo` AstBool True
        it "fibonacci" $
            "(define (fib n) \
            \(if (< n 2) n (+ (fib (- n 1)) (fib (- n 2)))))\n\
            \(fib 10)" `shouldEvalTo` AstInt 55
        it "power" $
            "(define (pow b e) \
            \(if (eq? e 0) 1 (* b (pow b (- e 1)))))\n\
            \(pow 2 10)" `shouldEvalTo` AstInt 1024
        it "gcd" $
            "(define (gcd a b) \
            \(if (eq? b 0) a (gcd b (mod a b))))\n\
            \(gcd 48 18)" `shouldEvalTo` AstInt 6
        it "absolute value" $
            "(define (abs x) (if (< x 0) (- 0 x) x))\n\
            \(abs -42)" `shouldEvalTo` AstInt 42
        it "max" $
            "(define (max a b) (if (< a b) b a))\n\
            \(max 17 42)" `shouldEvalTo` AstInt 42
        it "min" $
            "(define (min a b) (if (< a b) a b))\n\
            \(min 17 42)" `shouldEvalTo` AstInt 17
        it "sum to n" $
            "(define (sum-to n) \
            \(if (eq? n 0) 0 (+ n (sum-to (- n 1)))))\n\
            \(sum-to 10)" `shouldEvalTo` AstInt 55
        it "is even" $
            "(define (is-even n) \
            \(eq? (mod n 2) 0))\n\
            \(is-even 10)" `shouldEvalTo` AstBool True
        it "is odd" $
            "(define (is-odd n) \
            \(eq? (mod n 2) 1))\n\
            \(is-odd 7)" `shouldEvalTo` AstBool True
        it "multiple functions" $
            "(define (double x) (* x 2))\n\
            \(define (quadruple x) (double (double x)))\n\
            \(quadruple 25)" `shouldEvalTo` AstInt 100
        it "factorial tail recursive" $
            "(define (fact-tr n acc) \
            \(if (eq? n 0) acc (fact-tr (- n 1) (* n acc))))\n\
            \(define (fact n) (fact-tr n 1))\n\
            \(fact 10)" `shouldEvalTo` AstInt 3628800
        it "higher order" $
            "(define (apply-twice f x) (f (f x)))\n\
            \(define (triple x) (* x 3))\n\
            \(apply-twice triple 8)" `shouldEvalTo` AstInt 72
        it "less or equal" $
            "(define (<= a b) (if (< a b) #t (eq? a b)))\n\
            \(<= 5 5)" `shouldEvalTo` AstBool True
        it "greater or equal" $
            "(define (>= a b) (if (< a b) #f #t))\n\
            \(>= 5 5)" `shouldEvalTo` AstBool True
        it "not equal" $
            "(define (!= a b) (if (eq? a b) #f #t))\n\
            \(!= 5 6)" `shouldEvalTo` AstBool True
        it "div mod verify" $
            "(define a 17)\n(define b 5)\n\
            \(eq? a (+ (* (div a b) b) (mod a b)))"
                `shouldEvalTo` AstBool True
        it "countdown" $
            "(define (countdown n) \
            \(if (eq? n 0) 0 (countdown (- n 1))))\n\
            \(countdown 100)" `shouldEvalTo` AstInt 0

    describe "Edge Cases Tests" $ do
        it "single value" $ "42" `shouldEvalTo` AstInt 42
        it "long symbol name" $
            "(define this-is-a-very-long-variable-name 42)\n\
            \this-is-a-very-long-variable-name" `shouldEvalTo` AstInt 42
        it "symbol special chars" $
            "(define foo-bar_baz 42)\nfoo-bar_baz" `shouldEvalTo` AstInt 42
        it "arithmetic identity" $
            "(+ (- 0 42) 42)" `shouldEvalTo` AstInt 0
        it "nested function calls" $
            "(+ (+ (+ (+ 1 2) 3) 4) 6)" `shouldEvalTo` AstInt 16
        it "large computation" $
            "(* 1000 1000)" `shouldEvalTo` AstInt 1000000
        it "zero operations" $
            "(+ 0 0)" `shouldEvalTo` AstInt 0
        it "multiply by one" $
            "(* 42 1)" `shouldEvalTo` AstInt 42
        it "subtract same" $
            "(- 42 42)" `shouldEvalTo` AstInt 0
        it "div by one" $
            "(div 42 1)" `shouldEvalTo` AstInt 42
        it "lambda ignore arg" $
            "((lambda (x) 42) 999)" `shouldEvalTo` AstInt 42
        it "recursion depth" $
            "(define (recurse n) \
            \(if (eq? n 0) 0 (recurse (- n 1))))\n\
            \(recurse 500)" `shouldEvalTo` AstInt 0
        it "bool var condition" $
            "(define cond #t)\n(if cond 1 2)" `shouldEvalTo` AstInt 1
        it "comments" $
            "; comment\n(define x 42) ; inline\n; more\nx"
                `shouldEvalTo` AstInt 42
        it "nested lambda call" $
            "(define make-adder (lambda (x) (lambda (y) (+ x y))))\n\
            \(define add5 (make-adder 5))\n\
            \(add5 10)" `shouldEvalTo` AstInt 15
        it "self apply" $
            "((lambda (f) (f 42)) (lambda (x) x))" `shouldEvalTo` AstInt 42
        it "triple nested arithmetic" $
            "(+ (* 10 (- 15 5)) (div 100 (+ 5 5)))" `shouldEvalTo` AstInt 110
        it "eq computed" $
            "(eq? (+ 20 22) (* 6 7))" `shouldEvalTo` AstBool True
        it "deep if nesting" $
            "(if #t (if #t (if #t (if #t (if #t (if #t 42 0) 0) 0) 0) 0) 0)"
                `shouldEvalTo` AstInt 42

    describe "Error Handling Tests" $ do
        it "unbound variable" $ shouldFail "foo"
        it "division by zero" $ shouldFail "(div 10 0)"
        it "modulo by zero" $ shouldFail "(mod 10 0)"
        it "wrong type arg plus" $ shouldFail "(+ 1 #t)"
        it "wrong type arg less" $ shouldFail "(< 1 #t)"
        it "call non procedure" $ shouldFail "(42 1 2)"
        it "define missing value" $ shouldFail "(define foo)"
        it "define missing symbol" $ shouldFail "(define)"
        it "lambda missing body" $ shouldFail "(lambda (a b))"
        it "lambda missing args" $ shouldFail "(lambda)"
        it "if missing else" $ shouldFail "(if #t 1)"
        it "if missing then" $ shouldFail "(if #t)"
        it "if missing condition" $ shouldFail "(if)"
        it "lambda too few args" $
            shouldFail "(define add (lambda (a b) (+ a b)))\n(add 1)"
        it "lambda too many args" $
            shouldFail "(define add (lambda (a b) (+ a b)))\n(add 1 2 3)"
        it "define number as symbol" $ shouldFail "(define 42 \"value\")"
        it "lambda non symbol param" $ shouldFail "(lambda (1 2) (+ 1 2))"
        it "nested unbound variable" $ shouldFail "(+ 1 (* 2 undefined_var))"
        it "missing close paren" $ shouldFail "(+ 1 2"
        it "extra close paren" $ shouldFail "(+ 1 2))"

    describe "List Parsing Tests" $ do
        it "list with spaces" $ "(+   1   2)" `shouldEvalTo` AstInt 3
        it "list with tabs" $ "(+\t1\t2)" `shouldEvalTo` AstInt 3
        it "list with newlines" $ "(+\n1\n2)" `shouldEvalTo` AstInt 3

    describe "Ast Eq and Show instances" $ do
        it "Ast Eq works for Define" $ do
            (Define "x" Nothing (AstInt 1) == Define "x" Nothing (AstInt 1)) `shouldBe` True
            (Define "x" Nothing (AstInt 1) == Define "y" Nothing (AstInt 1)) `shouldBe` False
        it "Ast Eq works for AstInt" $ do
            (AstInt 1 == AstInt 1) `shouldBe` True
            (AstInt 1 == AstInt 2) `shouldBe` False
        it "Ast Eq works for AstSymbol" $ do
            (AstSymbol "x" == AstSymbol "x") `shouldBe` True
            (AstSymbol "x" == AstSymbol "y") `shouldBe` False
        it "Ast Eq works for AstBool" $ do
            (AstBool True == AstBool True) `shouldBe` True
            (AstBool True == AstBool False) `shouldBe` False
        it "Ast Show works for all constructors" $ do
            show (Define "x" Nothing (AstInt 1)) `shouldSatisfy` (not . null)
            show (AstInt 42) `shouldSatisfy` (not . null)
            show (AstSymbol "foo") `shouldSatisfy` (not . null)
            show (AstBool True) `shouldSatisfy` (not . null)
            show (AstList []) `shouldSatisfy` (not . null)
            show (Call (AstSymbol "+") [AstInt 1]) `shouldSatisfy` (not . null)
        it "SExpr Show works for all constructors" $ do
            show (SInt 42) `shouldSatisfy` (not . null)
            show (SSymbol "foo") `shouldSatisfy` (not . null)
            show (SList [SInt 1]) `shouldSatisfy` (not . null)

    describe "Define field accessors" $ do
        it "defName accessor works" $
            defName (Define "myVar" Nothing (AstInt 42)) `shouldBe` "myVar"
        it "defValue accessor works" $
            defValue (Define "myVar" Nothing (AstInt 42)) `shouldBe` AstInt 42

    describe "Paths_glados coverage" $ do
        it "exposes package version" $
            showVersion P.version `shouldSatisfy` (not . null)
        it "returns non-empty directory paths" $ do
            bin <- P.getBinDir
            lib <- P.getLibDir
            dataDir <- P.getDataDir
            libexec <- P.getLibexecDir
            sysconf <- P.getSysconfDir
            dynlib <- P.getDynLibDir
            mapM_ (`shouldSatisfy` (not . null))
                [bin, lib, dataDir, libexec, sysconf, dynlib]
        it "getDataFileName appends file name" $ do
            fp <- P.getDataFileName "somefile.txt"
            fp `shouldSatisfy` ("somefile.txt" `isSuffixOf`)
        it "getDataFileName handles empty string" $ do
            fp <- P.getDataFileName ""
            fp `shouldSatisfy` (not . null)
        it "multiple calls to getBinDir" $ do
            bin1 <- P.getBinDir
            bin2 <- P.getBinDir
            bin1 `shouldBe` bin2
        it "version has correct structure" $
            show P.version `shouldSatisfy` (not . null)
        it "getDataFileName uses trailing slash dir correctly" $ do
            setEnv "glados_datadir" "/tmp/"
            fp <- P.getDataFileName "file.txt"
            unsetEnv "glados_datadir"
            fp `shouldBe` "/tmp/file.txt"

    -- ========================================================================
    -- TSLang Parser Tests
    -- ========================================================================

    describe "Basic Atoms" $ do
        it "parses positive integer" $
            TSL.parseSExprEither "42" `shouldBe` Right (SInt 42)
        it "parses negative integer" $
            TSL.parseSExprEither "-42" `shouldBe` Right (SInt (-42))
        it "parses zero" $
            TSL.parseSExprEither "0" `shouldBe` Right (SInt 0)
        it "parses large positive integer" $
            TSL.parseSExprEither "1000000" `shouldBe` Right (SInt 1000000)
        it "parses large negative integer" $
            TSL.parseSExprEither "-1000000" `shouldBe` Right (SInt (-1000000))
        it "parses integer with explicit positive sign" $
            TSL.parseSExprEither "+42" `shouldBe` Right (SInt 42)

        it "parses positive float" $
            TSL.parseSExprEither "3.14" `shouldBe` Right (SList [SSymbol "float", SSymbol "3.14"])
        it "parses negative float" $
            TSL.parseSExprEither "-3.14" `shouldBe` Right (SList [SSymbol "float", SSymbol "-3.14"])
        it "parses float with positive sign" $
            TSL.parseSExprEither "+3.14" `shouldBe` Right (SList [SSymbol "float", SSymbol "+3.14"])

        it "parses simple string" $
            TSL.parseSExprEither "\"hello\"" `shouldBe` Right (SList [SSymbol "string", SSymbol "hello"])
        it "parses empty string" $
            TSL.parseSExprEither "\"\"" `shouldBe` Right (SList [SSymbol "string", SSymbol ""])
        it "parses string with spaces" $
            TSL.parseSExprEither "\"hello world\"" `shouldBe` Right (SList [SSymbol "string", SSymbol "hello world"])

        it "parses simple symbol" $
            TSL.parseSExprEither "foo" `shouldBe` Right (SSymbol "foo")
        it "parses symbol with underscore" $
            TSL.parseSExprEither "foo_bar" `shouldBe` Right (SSymbol "foo_bar")
        it "parses symbol with numbers" $
            TSL.parseSExprEither "var1" `shouldBe` Right (SSymbol "var1")
        it "parses symbol starting with uppercase" $
            TSL.parseSExprEither "Personne" `shouldBe` Right (SSymbol "Personne")

    describe "Expressions" $ do
        -- Supported arithmetic operators (* and /)
        it "parses multiplication" $
            TSL.parseSExprEither "2 * 3" `shouldBe` Right (SList [SSymbol "*", SInt 2, SInt 3])
        it "parses division" $
            TSL.parseSExprEither "10 / 2" `shouldBe` Right (SList [SSymbol "/", SInt 10, SInt 2])
        it "parses chained multiplication" $
            TSL.parseSExprEither "2 * 3 * 4" `shouldBe`
                Right (SList [SSymbol "*", SList [SSymbol "*", SInt 2, SInt 3], SInt 4])
        it "parses chained division" $
            TSL.parseSExprEither "24 / 4 / 2" `shouldBe`
                Right (SList [SSymbol "/", SList [SSymbol "/", SInt 24, SInt 4], SInt 2])
        it "parses mixed mul and div" $
            TSL.parseSExprEither "2 * 6 / 3" `shouldBe`
                Right (SList [SSymbol "/", SList [SSymbol "*", SInt 2, SInt 6], SInt 3])

    describe "Variable Definitions (eric)" $ do
        it "parses variable definition without value" $
            TSL.parseSExprEither "eric x -> int" `shouldBe`
                Right (SList [SSymbol "define", SSymbol "x", SSymbol "int"])
        it "parses variable definition with string type" $
            TSL.parseSExprEither "eric name -> string" `shouldBe`
                Right (SList [SSymbol "define", SSymbol "name", SSymbol "string"])
        it "parses variable definition with float type" $
            TSL.parseSExprEither "eric pi -> float" `shouldBe`
                Right (SList [SSymbol "define", SSymbol "pi", SSymbol "float"])
        it "parses variable definition with custom type" $
            TSL.parseSExprEither "eric p -> Personne" `shouldBe`
                Right (SList [SSymbol "define", SSymbol "p", SSymbol "Personne"])

    describe "Assignments" $ do
        it "parses simple assignment" $
            TSL.parseSExprEither "x = 5" `shouldBe`
                Right (SList [SSymbol "assign", SSymbol "x", SInt 5])
        it "parses assignment with mul expression" $
            TSL.parseSExprEither "x = y * 2" `shouldBe`
                Right (SList [SSymbol "assign", SSymbol "x",
                       SList [SSymbol "*", SSymbol "y", SInt 2]])
        it "parses array element assignment" $
            TSL.parseSExprEither "arr[0] = 10" `shouldBe`
                Right (SList [SSymbol "assign",
                       SList [SSymbol "array-access", SSymbol "arr", SInt 0],
                       SInt 10])
        it "parses member assignment" $
            TSL.parseSExprEither "p.name = \"Alice\"" `shouldBe`
                Right (SList [SSymbol "assign",
                       SList [SSymbol "member-access", SSymbol "p", SSymbol "name"],
                       SList [SSymbol "string", SSymbol "Alice"]])

    describe "Array Access" $ do
        it "parses simple array access" $
            TSL.parseSExprEither "arr[0]" `shouldBe`
                Right (SList [SSymbol "array-access", SSymbol "arr", SInt 0])
        it "parses array access with variable index" $
            TSL.parseSExprEither "arr[i]" `shouldBe`
                Right (SList [SSymbol "array-access", SSymbol "arr", SSymbol "i"])
        it "parses nested array access" $
            TSL.parseSExprEither "arr[0][1]" `shouldBe`
                Right (SList [SSymbol "array-access",
                       SList [SSymbol "array-access", SSymbol "arr", SInt 0],
                       SInt 1])

    describe "Member Access" $ do
        it "parses simple member access" $
            TSL.parseSExprEither "p.name" `shouldBe`
                Right (SList [SSymbol "member-access", SSymbol "p", SSymbol "name"])
        it "parses chained member access" $
            TSL.parseSExprEither "a.b.c" `shouldBe`
                Right (SList [SSymbol "member-access",
                       SList [SSymbol "member-access", SSymbol "a", SSymbol "b"],
                       SSymbol "c"])
        it "parses array access on member" $
            TSL.parseSExprEither "p.items[0]" `shouldBe`
                Right (SList [SSymbol "array-access",
                       SList [SSymbol "member-access", SSymbol "p", SSymbol "items"],
                       SInt 0])

    describe "Pointers" $ do
        it "parses address-of operator" $
            TSL.parseSExprEither "&x" `shouldBe`
                Right (SList [SSymbol "addr-of", SSymbol "x"])
        it "parses dereference operator" $
            TSL.parseSExprEither "*ptr" `shouldBe`
                Right (SList [SSymbol "deref", SSymbol "ptr"])

    describe "Type Annotations" $ do
        it "parses simple type" $
            TSL.parseSExprEither "eric x -> int" `shouldSatisfy` isRight
        it "parses array type" $
            TSL.parseSExprEither "eric arr -> int[]" `shouldBe`
                Right (SList [SSymbol "define", SSymbol "arr",
                       SList [SSymbol "array-type", SSymbol "int"]])
        it "parses pointer type" $
            TSL.parseSExprEither "eric ptr -> int*" `shouldBe`
                Right (SList [SSymbol "define", SSymbol "ptr",
                       SList [SSymbol "pointer-type", SSymbol "int"]])
        it "parses custom type (struct)" $
            TSL.parseSExprEither "eric p -> Personne" `shouldBe`
                Right (SList [SSymbol "define", SSymbol "p", SSymbol "Personne"])

    describe "If Statements (erif)" $ do
        it "parses simple if statement with mul" $
            TSL.parseSExprEither "erif (x * 2):" `shouldSatisfy` isRight
        it "parses if with assignment body" $
            TSL.parseSExprEither "erif (x):\n    y = 1" `shouldSatisfy` isRight
        it "parses if with variable condition" $
            TSL.parseSExprEither "erif (flag):" `shouldSatisfy` isRight

    describe "While Loops (darius)" $ do
        it "parses simple while loop" $
            TSL.parseSExprEither "darius (x):" `shouldSatisfy` isRight
        it "parses while with mul condition" $
            TSL.parseSExprEither "darius (x * 2):" `shouldSatisfy` isRight

    describe "For Loops (aer)" $ do
        it "parses simple for loop" $
            TSL.parseSExprEither "aer i in range(0, 10):" `shouldSatisfy` isRight
        it "parses for loop with print body" $
            TSL.parseSExprEither "aer i in range(0, 5):\n    peric(\"test\")" `shouldSatisfy` isRight
        it "parses for loop with variable bounds" $
            TSL.parseSExprEither "aer i in range(start, end):" `shouldSatisfy` isRight

    describe "Function Definitions (Deschodt)" $ do
        it "parses function with no parameters" $
            TSL.parseSExprEither "Deschodt main() -> int" `shouldSatisfy` isRight
        it "parses function named Eric (main function)" $
            TSL.parseSExprEither "Deschodt Eric() -> int" `shouldSatisfy` isRight
        it "parses function with parameters" $
            TSL.parseSExprEither "Deschodt add(a -> int, b -> int) -> int" `shouldSatisfy` isRight
        it "parses function with void return type" $
            TSL.parseSExprEither "Deschodt print_hello() -> void" `shouldSatisfy` isRight
        it "parses function with pointer parameter" $
            TSL.parseSExprEither "Deschodt modify(ptr -> int*) -> void" `shouldSatisfy` isRight

    describe "Function Calls" $ do
        it "parses function call with no arguments" $
            TSL.parseSExprEither "main()" `shouldBe`
                Right (SList [SSymbol "call", SSymbol "main"])
        it "parses function call with one argument" $
            TSL.parseSExprEither "print(42)" `shouldBe`
                Right (SList [SSymbol "call", SSymbol "print", SInt 42])
        it "parses function call with multiple arguments" $
            TSL.parseSExprEither "add(1, 2)" `shouldBe`
                Right (SList [SSymbol "call", SSymbol "add", SInt 1, SInt 2])
        it "parses function call with variable arguments" $
            TSL.parseSExprEither "compute(x, y)" `shouldBe`
                Right (SList [SSymbol "call", SSymbol "compute", SSymbol "x", SSymbol "y"])
        it "parses function call with address-of argument" $
            TSL.parseSExprEither "modify(&x)" `shouldBe`
                Right (SList [SSymbol "call", SSymbol "modify",
                       SList [SSymbol "addr-of", SSymbol "x"]])

    describe "Return Statements (deschodt)" $ do
        it "parses return with integer" $
            TSL.parseSExprEither "deschodt 0" `shouldBe`
                Right (SList [SSymbol "return", SInt 0])
        it "parses return with mul expression" $
            TSL.parseSExprEither "deschodt x * y" `shouldBe`
                Right (SList [SSymbol "return", SList [SSymbol "*", SSymbol "x", SSymbol "y"]])
        it "parses return with variable" $
            TSL.parseSExprEither "deschodt result" `shouldBe`
                Right (SList [SSymbol "return", SSymbol "result"])

    describe "Print Statements (peric)" $ do
        it "parses simple print" $
            TSL.parseSExprEither "peric(\"Hello\")" `shouldBe`
                Right (SList [SSymbol "print", SList [SSymbol "string", SSymbol "Hello"]])
        it "parses print with interpolation syntax" $
            TSL.parseSExprEither "peric(\"x = {x}\")" `shouldBe`
                Right (SList [SSymbol "print", SList [SSymbol "string", SSymbol "x = {x}"]])
        it "parses print with empty string" $
            TSL.parseSExprEither "peric(\"\")" `shouldBe`
                Right (SList [SSymbol "print", SList [SSymbol "string", SSymbol ""]])

    describe "Structs (destruct)" $ do
        it "parses simple struct" $
            TSL.parseSExprEither "destruct Personne:" `shouldBe`
                Right (SList [SSymbol "struct", SSymbol "Personne"])
        it "parses struct with one field" $
            TSL.parseSExprEither "destruct Point:\n    x -> int" `shouldBe`
                Right (SList [SSymbol "struct", SSymbol "Point",
                       SList [SSymbol "x", SSymbol "int"]])
        it "parses struct with multiple fields" $
            TSL.parseSExprEither "destruct Personne:\n    nom -> string\n    age -> int" `shouldBe`
                Right (SList [SSymbol "struct", SSymbol "Personne",
                       SList [SSymbol "nom", SSymbol "string"],
                       SList [SSymbol "age", SSymbol "int"]])

    describe "Enums (desnum)" $ do
        it "parses simple enum" $
            TSL.parseSExprEither "desnum Color:" `shouldBe`
                Right (SList [SSymbol "enum", SSymbol "Color"])
        it "parses enum with values" $
            TSL.parseSExprEither "desnum Jour:\n    Lundi\n    Mardi\n    Mercredi" `shouldBe`
                Right (SList [SSymbol "enum", SSymbol "Jour",
                       SSymbol "Lundi", SSymbol "Mardi", SSymbol "Mercredi"])

    describe "Comments (desnote)" $ do
        it "parses line comment syntax" $
            TSL.parseSExprEither "desnote this is a comment" `shouldSatisfy` isLeft
        it "parses code with comment at end" $
            TSL.parseSExprEither "42" `shouldBe` Right (SInt 42)

    describe "Multiple Statements" $ do
        it "parses multiple variable declarations" $
            TSL.parseSExprMultipleEither "eric x -> int\neric y -> int" `shouldSatisfy` isRight
        it "parses function with print body" $
            TSL.parseSExprMultipleEither "Deschodt Eric() -> int\n    peric(\"test\")\n    deschodt 0" `shouldSatisfy` isRight

    describe "Complex Programs" $ do
        it "parses hello world program" $
            TSL.parseSExprMultipleEither "Deschodt Eric() -> int\n    peric(\"Salut, monde !\")\n    deschodt 0" `shouldSatisfy` isRight
        it "parses simple variable declaration" $
            TSL.parseSExprMultipleEither "Deschodt Eric() -> int\n    eric x -> int\n    deschodt 0" `shouldSatisfy` isRight
        it "parses struct definition and usage" $
            TSL.parseSExprMultipleEither "destruct Personne:\n    nom -> string\n    age -> int" `shouldSatisfy` isRight
        it "parses enum definition" $
            TSL.parseSExprMultipleEither "desnum Jour:\n    Lundi\n    Mardi" `shouldSatisfy` isRight
        it "parses for loop with body" $
            TSL.parseSExprMultipleEither "aer i in range(0, 5):\n    peric(\"i\")" `shouldSatisfy` isRight
        it "parses while loop with variable" $
            TSL.parseSExprMultipleEither "darius (x):\n    peric(\"loop\")" `shouldSatisfy` isRight
        it "parses function with return" $
            TSL.parseSExprMultipleEither "Deschodt add(a -> int, b -> int) -> int\n    deschodt a" `shouldSatisfy` isRight

    describe "Edge Cases" $ do
        it "handles leading whitespace" $
            TSL.parseSExprEither "42" `shouldBe` Right (SInt 42)
        it "handles tabs" $
            TSL.parseSExprEither "\t42" `shouldBe` Right (SInt 42)
        it "parses deeply nested expressions" $
            TSL.parseSExprEither "((((1))))" `shouldSatisfy` isRight
        it "parses complex member chain with array" $
            TSL.parseSExprEither "obj.items[0].value" `shouldSatisfy` isRight
        it "parses parenthesized integer" $
            TSL.parseSExprEither "(42)" `shouldBe` Right (SInt 42)

    describe "Error Cases" $ do
        it "fails on unclosed parenthesis" $
            TSL.parseSExprEither "(1 + 2" `shouldSatisfy` isLeft
        it "fails on unclosed string" $
            TSL.parseSExprEither "\"hello" `shouldSatisfy` isLeft
        it "fails on invalid character" $
            TSL.parseSExprEither "@invalid" `shouldSatisfy` isLeft
        it "fails on empty input" $
            TSL.parseSExprEither "" `shouldSatisfy` isLeft
        it "fails on unclosed array access" $
            TSL.parseSExprEither "arr[0" `shouldSatisfy` isLeft
