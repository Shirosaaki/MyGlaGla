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
			evalAST (AstBool True) `shouldBe` Just (AstBool True)
		it "evaluates AstBool False" $ do
			evalAST (AstBool False) `shouldBe` Just (AstBool False)
		it "evaluates Define" $ do
			evalAST (Define "x" (AstInt 42)) `shouldBe` Just (Define "x" (AstInt 42))
		it "evaluates AstInt" $ do
			evalAST (AstInt 5) `shouldBe` Just (AstInt 5)
		it "evaluates AstSymbol" $ do
			evalAST (AstSymbol "foo") `shouldBe` Just (AstSymbol "foo")
		it "evaluates addition" $ do
			evalAST (Call (AstSymbol "+") [AstInt 1, AstInt 2])
				`shouldBe` Just (AstInt 3)
		it "evaluates multiplication" $ do
			evalAST (Call (AstSymbol "*") [AstInt 2, AstInt 3])
				`shouldBe` Just (AstInt 6)
		it "evaluates subtraction" $ do
			evalAST (Call (AstSymbol "-") [AstInt 5, AstInt 2])
				`shouldBe` Just (AstInt 3)
		it "evaluates division" $ do
			evalAST (Call (AstSymbol "/") [AstInt 8, AstInt 2])
				`shouldBe` Just (AstInt 4)
		it "returns Nothing for division by zero" $ do
			evalAST (Call (AstSymbol "/") [AstInt 8, AstInt 0]) `shouldBe` Nothing
		it "returns Nothing for division with zero in middle" $ do
			evalAST (Call (AstSymbol "/") [AstInt 8, AstInt 2, AstInt 0]) `shouldBe` Nothing
		it "returns Nothing for non-int args" $ do
			evalAST (Call (AstSymbol "+") [AstSymbol "foo"]) `shouldBe` Nothing

		it "returns Nothing for subtraction with no args" $ do
			evalAST (Call (AstSymbol "-") []) `shouldBe` Nothing

		it "evaluates AstList by mapping evalAST" $ do
			evalAST (AstList [AstInt 1, AstSymbol "x"]) `shouldBe` Just (AstList [AstInt 1, AstSymbol "x"])

		it "addition with no args returns 0" $ do
			evalAST (Call (AstSymbol "+") []) `shouldBe` Just (AstInt 0)

		it "multiplication with no args returns 1" $ do
			evalAST (Call (AstSymbol "*") []) `shouldBe` Just (AstInt 1)

		it "addition with multiple args" $ do
			evalAST (Call (AstSymbol "+") [AstInt 1, AstInt 2, AstInt 3]) `shouldBe` Just (AstInt 6)

		it "multiplication with multiple args" $ do
			evalAST (Call (AstSymbol "*") [AstInt 2, AstInt 3, AstInt 4]) `shouldBe` Just (AstInt 24)

		it "subtraction with multiple args" $ do
			evalAST (Call (AstSymbol "-") [AstInt 10, AstInt 2, AstInt 3]) `shouldBe` Just (AstInt 5)

		it "division with multiple args" $ do
			evalAST (Call (AstSymbol "/") [AstInt 24, AstInt 2, AstInt 3]) `shouldBe` Just (AstInt 4)

		it "subtraction with single arg returns the arg" $ do
			evalAST (Call (AstSymbol "-") [AstInt 5]) `shouldBe` Just (AstInt 5)

		it "division with single arg returns the arg" $ do
			evalAST (Call (AstSymbol "/") [AstInt 10]) `shouldBe` Just (AstInt 10)

		it "division with no args returns Nothing" $ do
			evalAST (Call (AstSymbol "/") []) `shouldBe` Nothing

		it "unknown operator returns Nothing" $ do
			evalAST (Call (AstSymbol "foo") [AstInt 1, AstInt 2]) `shouldBe` Nothing

		it "Call with non-AstSymbol function evaluates to Nothing (no op match)" $ do
			evalAST (Call (AstInt 99) [AstInt 1]) `shouldBe` Nothing

		it "Call with nested failing arg returns Nothing" $ do
			evalAST (Call (AstSymbol "+") [Call (AstSymbol "bad") [AstInt 1]]) `shouldBe` Nothing

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
