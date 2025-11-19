{-
-- EPITECH PROJECT, 2025
-- test
-- File description:
-- main of the glory glados
-}
import Test.Hspec
import Lib (SExpr(..), Ast(..), sexprToAST, evalAST)

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

	describe "evalAST" $ do
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
		it "returns Nothing for non-int args" $ do
			evalAST (Call (AstSymbol "+") [AstSymbol "foo"]) `shouldBe` Nothing
