module Generated.FilesSpec (spec) where

import Test.Hspec
import Lib (parseSExprMultiple, sexprToAST, evalAST, Ast(..))

runFile :: FilePath -> IO (Maybe Ast)
runFile fp = do
    src <- readFile fp
    case parseSExprMultiple src of
        Nothing -> return Nothing
        Just sexprs ->
            case mapM sexprToAST sexprs of
                Nothing -> return Nothing
                Just asts ->
                    case evalAST [] (AstList asts) of
                        Just (res, _) -> return (Just res)
                        Nothing -> return Nothing

spec :: Spec
spec = describe "Files in test/files" $ do
    it "simple_add.scm => 3" $ do
        r <- runFile "test/files/simple_add.scm"
        r `shouldBe` Just (AstInt 3)

    it "if_test.scm => 1" $ do
        r <- runFile "test/files/if_test.scm"
        r `shouldBe` Just (AstInt 1)

    it "lambda_test.scm => 3" $ do
        r <- runFile "test/files/lambda_test.scm"
        r `shouldBe` Just (AstInt 3)

    it "factorial.scm => 3628800" $ do
        r <- runFile "test/files/factorial.scm"
        r `shouldBe` Just (AstInt 3628800)

    it "error.scm => Nothing (unbound identifier)" $ do
        r <- runFile "test/files/error.scm"
        r `shouldBe` Nothing
