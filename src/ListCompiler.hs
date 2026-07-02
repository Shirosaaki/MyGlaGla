module ListCompiler
  ( inferValTag
  , emitListPush
  , emitTaggedPair
  , listRuntimeBuiltins
  , listErrorStrings
  ) where

import AST (Ast(..), Type(..))
import qualified Data.Map.Strict as Map

listRuntimeBuiltins :: [String]
listRuntimeBuiltins =
  [ "list_new", "list_push", "list_prepend", "list_insert_after_nth"
  , "list_get_at", "list_get_tag_at", "list_len", "list_is_empty", "list_contains"
  , "list_remove_nth_val", "list_remove_at_idx", "list_remove_after_val"
  , "list_to_string", "val_to_string"
  , "map_new", "map_put", "map_get", "map_remove", "map_contains"
  , "str_len", "str_contains", "str_split", "darkness_print", "val_eq"
  ]

listErrorStrings :: [String]
listErrorStrings =
  [ "List error: element not found\n"
  , "List error: index out of bounds\n"
  , "Map error: key not found\n"
  ]

inferValTag :: Map.Map String Type -> Ast -> Int
inferValTag _ (AstInt _) = 0
inferValTag _ (AstFloat _) = 1
inferValTag _ (AstString _) = 2
inferValTag _ (AstChar _) = 3
inferValTag _ (AstSymbol "nothing") = 4
inferValTag vt (AstSymbol s) =
  case Map.lookup s vt of
    Just TInt            -> 0
    Just TFloat          -> 1
    Just TString         -> 2
    Just TChar           -> 3
    Just (TCustom "list") -> 6
    Just (TCustom "map")  -> 7
    Just (TCustom _)      -> 5
    _                     -> 0
inferValTag _ (Call (AstSymbol "list-at") _) = 0
inferValTag _ (Call (AstSymbol "map-at") _)  = 0
inferValTag _ (Call (AstSymbol "str-split") _) = 6
inferValTag _ _ = 0

-- | After evaluating an expression into %rax, set %rsi=tag and %rdx=data.
emitTaggedPair :: Map.Map String Type -> Ast -> [String]
emitTaggedPair vt ast =
  let tag = inferValTag vt ast
  in ["movq $" ++ show tag ++ ", %rsi", "movq %rax, %rdx"]

-- | Push one evaluated item onto list at stack offset listOff.
emitListPush :: Int -> Ast -> Map.Map String Int -> [(String, Int)] -> Map.Map String Type -> [String] -> (Ast -> Map.Map String Int -> [(String, Int)] -> Map.Map String Type -> [String] -> [String]) -> [String]
emitListPush listOff item locals labels vt fns evalAsm =
  evalAsm item locals labels vt fns ++
  emitTaggedPair vt item ++
  [ "movq -" ++ show listOff ++ "(%rbp), %rdi"
  , "call list_push"
  , "movq %rax, -" ++ show listOff ++ "(%rbp)"
  ]
