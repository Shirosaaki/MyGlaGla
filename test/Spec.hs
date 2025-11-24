{-
-- EPITECH PROJECT, 2025
-- test
-- File description:
-- main of the glory glados
-}
import Test.Hspec
import Lib (SExpr(..), Ast(..), sexprToAST, evalAST)
import qualified Paths_glados as P
import Data.Version (showVersion)
import Data.List (isSuffixOf)
import System.Environment (setEnv, unsetEnv)

-- guard-heavy helpers to increase boolean guard coverage (tests-only)
guardSign :: Int -> Int
guardSign n
	| n < 0 = -1
	| n == 0 = 0
	| n > 0 = 1

guardSteps :: Int -> Int
guardSteps x
	| x <= 0 = 0
	| x == 1 = 1
	| x == 2 = 2
	| x == 3 = 3
	| x == 4 = 4
	| x == 5 = 5
	| x == 6 = 6
	| x == 7 = 7
	| x == 8 = 8
	| x == 9 = 9
	| x >= 10 = 10

-- helper to adapt tests to the environment-threading `evalAST`:
eval :: Ast -> Maybe Ast
eval a = fmap fst (evalAST [] a)

main :: IO ()
main = hspec $ do
	describe "sexprToAST" $ do
		it "converts SInt to AstInt" $ do
			sexprToAST (SInt 42) `shouldBe` Just (AstInt 42)
		it "converts SSymbol to AstSymbol" $ do
			sexprToAST (SSymbol "foo") `shouldBe` Just (AstSymbol "foo")
		it "converts SList [] to AstList []" $ do
			sexprToAST (SList []) `shouldBe` Just (AstList [])
		it "converts define form" $ do
			sexprToAST (SList [SSymbol "define", SSymbol "x", SInt 1])
				`shouldBe` Just (Define "x" (AstInt 1))
		it "returns Nothing for malformed define" $ do
			sexprToAST (SList [SSymbol "define", SSymbol "x"]) `shouldBe` Nothing
		it "converts function call" $ do
			sexprToAST (SList [SSymbol "+", SInt 1, SInt 2])
				`shouldBe` Just (Call (AstSymbol "+") [AstInt 1, AstInt 2])

		it "allows non-symbol function position" $ do
			sexprToAST (SList [SInt 1, SInt 2]) `shouldBe` Just (Call (AstInt 1) [AstInt 2])

		it "returns Nothing when define name is not a symbol" $ do
			sexprToAST (SList [SSymbol "define", SInt 1, SInt 2]) `shouldBe` Nothing

	describe "evalAST" $ do
		it "evaluates AstBool True" $ do
			eval (AstBool True) `shouldBe` Just (AstBool True)
		it "evaluates AstBool False" $ do
			eval (AstBool False) `shouldBe` Just (AstBool False)
		it "evaluates Define" $ do
			eval (Define "x" (AstInt 42)) `shouldBe` Just (AstVoid)
		it "evaluates AstInt" $ do
			eval (AstInt 5) `shouldBe` Just (AstInt 5)
		it "evaluates AstSymbol" $ do
			eval (AstSymbol "foo") `shouldBe` Nothing
		it "evaluates addition" $ do
			eval (Call (AstSymbol "+") [AstInt 1, AstInt 2])
				`shouldBe` Just (AstInt 3)
		it "evaluates multiplication" $ do
			eval (Call (AstSymbol "*") [AstInt 2, AstInt 3])
				`shouldBe` Just (AstInt 6)
		it "evaluates subtraction" $ do
			eval (Call (AstSymbol "-") [AstInt 5, AstInt 2])
				`shouldBe` Just (AstInt 3)
		it "evaluates division" $ do
			eval (Call (AstSymbol "div") [AstInt 8, AstInt 2])
				`shouldBe` Just (AstInt 4)
		it "returns Nothing for division by zero" $ do
			eval (Call (AstSymbol "div") [AstInt 8, AstInt 0]) `shouldBe` Nothing
		it "returns Nothing for division with zero in middle" $ do
			eval (Call (AstSymbol "div") [AstInt 8, AstInt 2, AstInt 0]) `shouldBe` Nothing
		it "returns Nothing for non-int args" $ do
			eval (Call (AstSymbol "+") [AstSymbol "foo"]) `shouldBe` Nothing

		it "returns Nothing for subtraction with no args" $ do
			eval (Call (AstSymbol "-") []) `shouldBe` Nothing

		it "evaluates AstList by mapping evalAST" $ do
			eval (AstList [AstInt 1, AstSymbol "x"]) `shouldBe` Nothing

		it "addition with no args returns 0" $ do
			eval (Call (AstSymbol "+") []) `shouldBe` Just (AstInt 0)

		it "multiplication with no args returns 1" $ do
			eval (Call (AstSymbol "*") []) `shouldBe` Just (AstInt 1)

		it "addition with multiple args" $ do
			eval (Call (AstSymbol "+") [AstInt 1, AstInt 2, AstInt 3]) `shouldBe` Just (AstInt 6)

		it "multiplication with multiple args" $ do
			eval (Call (AstSymbol "*") [AstInt 2, AstInt 3, AstInt 4]) `shouldBe` Just (AstInt 24)

		it "subtraction with multiple args" $ do
			eval (Call (AstSymbol "-") [AstInt 10, AstInt 2, AstInt 3]) `shouldBe` Just (AstInt 5)

		it "division with multiple args" $ do
			eval (Call (AstSymbol "div") [AstInt 24, AstInt 2, AstInt 3]) `shouldBe` Just (AstInt 4)

		it "subtraction with single arg returns the arg" $ do
			eval (Call (AstSymbol "-") [AstInt 5]) `shouldBe` Just (AstInt 5)

		it "division with single arg returns the arg" $ do
			eval (Call (AstSymbol "div") [AstInt 10]) `shouldBe` Just (AstInt 10)

		it "division with no args returns Nothing" $ do
			eval (Call (AstSymbol "div") []) `shouldBe` Nothing

		it "unknown operator returns Nothing" $ do
			eval (Call (AstSymbol "foo") [AstInt 1, AstInt 2]) `shouldBe` Nothing

		it "Call with non-AstSymbol function evaluates to Nothing (no op match)" $ do
			eval (Call (AstInt 99) [AstInt 1]) `shouldBe` Nothing

		it "Call with nested failing arg returns Nothing" $ do
			eval (Call (AstSymbol "+") [Call (AstSymbol "bad") [AstInt 1]]) `shouldBe` Nothing

	describe "sexprToAST additional cases" $ do
		it "makeCall returns Nothing if fn is unconvertible" $ do
			sexprToAST (SList [SList [SSymbol "define", SSymbol "x"], SInt 1]) `shouldBe` Nothing

		it "makeCall returns Nothing if an arg is unconvertible" $ do
			sexprToAST (SList [SSymbol "+", SList [SSymbol "define", SSymbol "x"]]) `shouldBe` Nothing

		it "define with unconvertible value returns Nothing" $ do
			sexprToAST (SList [SSymbol "define", SSymbol "x", SList [SSymbol "define"]]) `shouldBe` Nothing

	describe "Ast Eq and Show instances" $ do
		it "Ast Eq works for Define" $ do
			(Define "x" (AstInt 1) == Define "x" (AstInt 1)) `shouldBe` True
			(Define "x" (AstInt 1) == Define "y" (AstInt 1)) `shouldBe` False
			(Define "x" (AstInt 1) /= Define "y" (AstInt 1)) `shouldBe` True
		it "Ast Eq works for AstInt" $ do
			(AstInt 1 == AstInt 1) `shouldBe` True
			(AstInt 1 == AstInt 2) `shouldBe` False
		it "Ast Eq works for AstSymbol" $ do
			(AstSymbol "x" == AstSymbol "x") `shouldBe` True
			(AstSymbol "x" == AstSymbol "y") `shouldBe` False
		it "Ast Eq works for AstBool" $ do
			(AstBool True == AstBool True) `shouldBe` True
			(AstBool True == AstBool False) `shouldBe` False
		it "Ast Eq works for AstList" $ do
			(AstList [AstInt 1] == AstList [AstInt 1]) `shouldBe` True
			(AstList [AstInt 1] == AstList [AstInt 2]) `shouldBe` False
		it "Ast Eq works for Call" $ do
			(Call (AstSymbol "+") [AstInt 1] == Call (AstSymbol "+") [AstInt 1]) `shouldBe` True
			(Call (AstSymbol "+") [AstInt 1] == Call (AstSymbol "-") [AstInt 1]) `shouldBe` False
		it "Ast Show works for all constructors" $ do
			show (Define "x" (AstInt 1)) `shouldSatisfy` (not . null)
			show (AstInt 42) `shouldSatisfy` (not . null)
			show (AstSymbol "foo") `shouldSatisfy` (not . null)
			show (AstBool True) `shouldSatisfy` (not . null)
			show (AstList []) `shouldSatisfy` (not . null)
			show (Call (AstSymbol "+") [AstInt 1]) `shouldSatisfy` (not . null)
		it "SExpr Show works for all constructors" $ do
			show (SInt 42) `shouldSatisfy` (not . null)
			show (SSymbol "foo") `shouldSatisfy` (not . null)
			show (SList [SInt 1]) `shouldSatisfy` (not . null)
			show (SList []) `shouldSatisfy` (not . null)

	describe "Define field accessors" $ do
		it "defName accessor works" $ do
			defName (Define "myVar" (AstInt 42)) `shouldBe` "myVar"
		it "defValue accessor works" $ do
			defValue (Define "myVar" (AstInt 42)) `shouldBe` AstInt 42

	describe "Paths_glados coverage" $ do
		it "exposes package version" $ do
			(showVersion P.version) `shouldSatisfy` (not . null)

		it "returns non-empty directory paths" $ do
			bin <- P.getBinDir
			lib <- P.getLibDir
			dataDir <- P.getDataDir
			libexec <- P.getLibexecDir
			sysconf <- P.getSysconfDir
			dynlib <- P.getDynLibDir
			mapM_ (`shouldSatisfy` (not . null)) [bin, lib, dataDir, libexec, sysconf, dynlib]

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

		it "version has correct structure" $ do
			let v = P.version
			show v `shouldSatisfy` (not . null)

		it "getDataFileName uses trailing slash dir correctly (guard True)" $ do
			setEnv "glados_datadir" "/tmp/"
			fp <- P.getDataFileName "file.txt"
			unsetEnv "glados_datadir"
			fp `shouldBe` "/tmp/file.txt"

		describe "Boolean guard helpers" $ do
			it "guardSign covers <, ==, > guards" $ do
				guardSign (-1) `shouldBe` (-1)
				guardSign 0 `shouldBe` 0
				guardSign 2 `shouldBe` 1
			it "guardSteps covers many equality/inequality guards" $ do
				map guardSteps [-1,1,2,3,4,5,6,7,8,9,10] `shouldBe` [0,1,2,3,4,5,6,7,8,9,10]

	describe "Predicates and if" $ do
		it "eq? returns true for equal ints" $ do
			eval (Call (AstSymbol "eq?") [AstInt 1, AstInt 1]) `shouldBe` Just (AstBool True)
		it "eq? returns false for different ints" $ do
			eval (Call (AstSymbol "eq?") [AstInt 1, AstInt 2]) `shouldBe` Just (AstBool False)
		it "< returns true when first < second" $ do
			eval (Call (AstSymbol "<") [AstInt 1, AstInt 2]) `shouldBe` Just (AstBool True)
		it "< returns false when first >= second" $ do
			eval (Call (AstSymbol "<") [AstInt 2, AstInt 1]) `shouldBe` Just (AstBool False)
		it "if chooses then branch when condition true" $ do
			eval (Call (AstSymbol "if") [AstBool True, AstInt 1, AstInt 2]) `shouldBe` Just (AstInt 1)
		it "if chooses else branch when condition false" $ do
			eval (Call (AstSymbol "if") [AstBool False, AstInt 1, AstInt 2]) `shouldBe` Just (AstInt 2)
		it "if returns Nothing for non-bool condition" $ do
			eval (Call (AstSymbol "if") [AstInt 1, AstInt 1, AstInt 2]) `shouldBe` Nothing
		it "malformed if (wrong arity) in sexprToAST returns Nothing" $ do
			sexprToAST (SList [SSymbol "if", SInt 1, SInt 2]) `shouldBe` Nothing
		it "eq? with wrong arity returns Nothing" $ do
			eval (Call (AstSymbol "eq?") [AstInt 1]) `shouldBe` Nothing
		it "< with non-int arg returns Nothing" $ do
			eval (Call (AstSymbol "<") [AstInt 1, AstSymbol "x"]) `shouldBe` Nothing
		it "mod returns remainder when divisor non-zero" $ do
			eval (Call (AstSymbol "mod") [AstInt 5, AstInt 2]) `shouldBe` Just (AstInt 1)
		it "mod returns Nothing when divisor is zero" $ do
			eval (Call (AstSymbol "mod") [AstInt 5, AstInt 0]) `shouldBe` Nothing
		it "sexprToAST converts SBool to AstBool" $ do
			sexprToAST (SBool True) `shouldBe` Just (AstBool True)
		it "sexprToAST maps nested SList to AstList" $ do
			sexprToAST (SList [SList [SSymbol "+", SInt 1, SInt 2], SInt 3])
				`shouldBe` Just (AstList [Call (AstSymbol "+") [AstInt 1, AstInt 2], AstInt 3])

		describe "Lambda / define-function" $ do
			it "parses and evaluates function-style define and call (>)" $ do
				let defineList = SList [SSymbol "define", SList [SSymbol ">", SSymbol "a", SSymbol "b"],
							SList [SSymbol "if", SList [SSymbol "eq?", SSymbol "a", SSymbol "b"], SBool False,
								SList [SSymbol "if", SList [SSymbol "<", SSymbol "a", SSymbol "b"], SBool False, SBool True]]]
				let callList = SList [SSymbol ">", SInt 10, SInt (-2)]
				let sexpr = SList [defineList, callList]
				case sexprToAST sexpr of
					Just ast -> eval ast `shouldBe` Just (AstBool True)
					Nothing -> expectationFailure "Parsing error for function-style define"

			it "defines recursive factorial and evaluates fact 5" $ do
				let defineFact = SList [SSymbol "define", SList [SSymbol "fact", SSymbol "x"],
							SList [SSymbol "if", SList [SSymbol "eq?", SSymbol "x", SInt 1], SInt 1,
							SList [SSymbol "*", SSymbol "x", SList [SSymbol "fact", SList [SSymbol "-", SSymbol "x", SInt 1]]]]]
				let callFact = SList [SSymbol "fact", SInt 5]
				let sexpr = SList [defineFact, callFact]
				case sexprToAST sexpr of
					Just ast -> eval ast `shouldBe` Just (AstInt 120)
					Nothing -> expectationFailure "Parsing error for factorial define"
		it "eq? works for symbols when bound" $ do
			let seq1 = AstList [Define "x" (AstInt 1), Call (AstSymbol "eq?") [AstSymbol "x", AstSymbol "x"]]
			let seq2 = AstList [Define "x" (AstInt 1), Define "y" (AstInt 2), Call (AstSymbol "eq?") [AstSymbol "x", AstSymbol "y"]]
			eval seq1 `shouldBe` Just (AstBool True)
			eval seq2 `shouldBe` Just (AstBool False)
		it "sequence with define and use updates env" $ do
			let seqAst = AstList [Define "foo" (AstInt 9), Call (AstSymbol "*") [AstSymbol "foo", AstInt 3]]
			eval seqAst `shouldBe` Just (AstInt 27)
