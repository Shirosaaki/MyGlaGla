{-
-- EPITECH PROJECT, 2025
-- VM module
-- File description:
-- Virtual Machine for executing bytecode
-}

module VM
  ( VMValue(..)
  , VMState(..)
  , runVM
  , execBytecode
  , decodeProgram
  , runELFFile
  , loadProgramFromELF
  , initVM
  ) where

import Bytecode
import Data.Int (Int32)
import Data.Word (Word16, Word32)
import qualified Data.Map.Strict as Map
import qualified Data.ByteString as BS
import qualified Bytecode as BC
import System.IO ()
import Control.Exception (try, SomeException(..))
import qualified Data.ByteString.Lazy as BSL()

-- Runtime values
data VMValue
  = VMInt Int32
  | VMBool Bool
  | VMString String
  | VMClosure Int32 Int32 [VMValue]  -- addr, arity, captured env
  | VMVoid
  deriving (Show, Eq)

-- Call frame
data CallFrame = CallFrame
  { returnAddress :: Int
  , savedLocals   :: [VMValue]
  } deriving (Show)

-- VM state
data VMState = VMState
  { stack    :: [VMValue]
  , pc       :: Int
  , callStack :: [CallFrame]
  , globals  :: Map.Map String VMValue
  , locals   :: [VMValue]
  , program  :: [Instruction]
  , halted   :: Bool
  , outputs  :: [String]
  } deriving (Show)

-- Initialise la VM avec une liste d'instructions
initVM :: [Instruction] -> VMState
initVM instrs = VMState
  { stack    = []
  , pc       = 0
  , callStack = []
  , globals  = Map.empty
  , locals   = []
  , program  = instrs
  , halted   = False
  , outputs  = []
  }

-- Exécute un programme et renvoie le résultat du sommet de pile + les sorties PRINT
runVM :: [Instruction] -> (Either String VMValue, [String])
runVM instrs = execBytecode (initVM instrs)

-- Récupère le résultat final
getResult :: VMState -> (Either String VMValue, [String])
getResult state =
  let out = outputs state
  in case stack state of
       (v:_) -> (Right v, out)
       []    -> (Right VMVoid, out)

-- Boucle principale de la VM
execBytecode :: VMState -> (Either String VMValue, [String])
execBytecode state
  | halted state = getResult state
  | pc state < 0 || pc state >= length (program state) =
      (Left "PC out of bounds", outputs state)
  | otherwise =
      case step state (program state !! pc state) of
        Left err      -> (Left err, outputs state)
        Right newState -> execBytecode newState

-- Exécution d'une instruction
step :: VMState -> Instruction -> Either String VMState
step state (PUSH n) =
  Right state { stack = VMInt n : stack state, pc = pc state + 1 }

step state PUSH_TRUE =
  Right state { stack = VMBool True : stack state, pc = pc state + 1 }

step state PUSH_FALSE =
  Right state { stack = VMBool False : stack state, pc = pc state + 1 }

step state POP =
  case stack state of
    (_:rest) -> Right state { stack = rest, pc = pc state + 1 }
    []       -> Left "Stack underflow on POP"

step state ADD =
  case stack state of
    (VMInt b : VMInt a : rest) ->
      Right state { stack = VMInt (a + b) : rest, pc = pc state + 1 }
    _ -> Left "Type error in ADD"

step state SUB =
  case stack state of
    (VMInt b : VMInt a : rest) ->
      Right state { stack = VMInt (a - b) : rest, pc = pc state + 1 }
    _ -> Left "Type error in SUB"

step state MUL =
  case stack state of
    (VMInt b : VMInt a : rest) ->
      Right state { stack = VMInt (a * b) : rest, pc = pc state + 1 }
    _ -> Left "Type error in MUL"

step state DIV =
  case stack state of
    (VMInt b : VMInt a : rest) ->
      if b == 0
        then Left "Division by zero"
        else Right state
               { stack = VMInt (a `div` b) : rest
               , pc    = pc state + 1
               }
    _ -> Left "Type error in DIV"

step state BC.MOD =
  case stack state of
    (VMInt b : VMInt a : rest) ->
      if b == 0
        then Left "Modulo by zero"
        else Right state
               { stack = VMInt (a `mod` b) : rest
               , pc    = pc state + 1
               }
    _ -> Left "Type error in MOD"

step state BC.LT =
  case stack state of
    (VMInt b : VMInt a : rest) ->
      Right state { stack = VMBool (a < b) : rest, pc = pc state + 1 }
    _ -> Left "Type error in LT"

step state BC.EQ =
  case stack state of
    (b : a : rest) ->
      Right state { stack = VMBool (a == b) : rest, pc = pc state + 1 }
    _ -> Left "Stack underflow in EQ"

step state (JUMP addr) =
  let newPc = fromIntegral addr
  in if newPc >= 0 && newPc < length (program state)
       then Right state { pc = newPc }
       else Left "Jump address out of bounds"

step state (JUMP_IF_FALSE addr) =
  case stack state of
    (VMBool False : rest) ->
      let newPc = fromIntegral addr
      in if newPc >= 0 && newPc < length (program state)
           then Right state { stack = rest, pc = newPc }
           else Left "Jump address out of bounds"
    (VMBool True : rest) ->
      Right state { stack = rest, pc = pc state + 1 }
    _ -> Left "Type error in JUMP_IF_FALSE"

step state (CALL addr) =
  case stack state of
    (VMClosure closureAddr nparams capturedEnv : args) ->
      callClosure state closureAddr nparams capturedEnv args
    _ ->
      callFunction state addr

step state RET =
  case callStack state of
    (frame : rest) ->
      case stack state of
        (retVal : stackRest) ->
          let newState = returnFromCall state frame rest retVal
          in Right newState { stack = retVal : stackRest }
        [] -> Left "Stack underflow on RET"
    [] ->
      Right state { halted = True }

step state (LOAD_VAR idx) =
  let index = fromIntegral idx
  in if index >= 0 && index < length (locals state)
       then Right state
              { stack = (locals state !! index) : stack state
              , pc    = pc state + 1
              }
       else Left "Variable index out of bounds"

step state (STORE_VAR idx) =
  case stack state of
    (val : rest) -> storeVariable state (fromIntegral idx) val rest
    []           -> Left "Stack underflow on STORE_VAR"

step state (LOAD_GLOBAL name) =
  case Map.lookup name (globals state) of
    Just val ->
      Right state
        { stack = val : stack state
        , pc    = pc state + 1
        }
    Nothing ->
      Left ("Undefined global variable: " ++ name)

step state (STORE_GLOBAL name) =
  case stack state of
    (val : rest) ->
      Right state
        { stack   = rest
        , globals = Map.insert name val (globals state)
        , pc      = pc state + 1
        }
    [] -> Left "Stack underflow on STORE_GLOBAL"

step state (MAKE_CLOSURE addr nparams) =
  let closure = VMClosure addr nparams (locals state)
  in Right state
       { stack = closure : stack state
       , pc    = pc state + 1
       }

step state HALT =
  Right state { halted = True }

step state (LOAD_CONST s) =
  Right state { stack = VMString s : stack state, pc = pc state + 1 }

step state PRINT =
  case stack state of
    (val : rest) -> doPrint state val rest
    []           -> Left "Stack underflow on PRINT"

-- Helpers pour les closures / appels

setupClosureCall :: VMState -> Int32 -> [VMValue] -> [VMValue] -> VMState
setupClosureCall state closureAddr capturedEnv args =
  let frame     = CallFrame (pc state + 1) (locals state)
      newLocals = reverse args ++ capturedEnv
  in state
       { pc        = fromIntegral closureAddr
       , callStack = frame : callStack state
       , locals    = newLocals
       }

callClosure :: VMState -> Int32 -> Int32 -> [VMValue] -> [VMValue] -> Either String VMState
callClosure state closureAddr nparams capturedEnv args =
  if length args < fromIntegral nparams
    then Left "Not enough arguments for closure call"
    else
      let (actualArgs, rest) = splitAt (fromIntegral nparams) args
          newState           = setupClosureCall state closureAddr capturedEnv actualArgs
      in Right newState { stack = rest }

callFunction :: VMState -> Int32 -> Either String VMState
callFunction state addr =
  let newPc = fromIntegral addr
  in if newPc >= 0 && newPc < length (program state)
       then
         let frame = CallFrame (pc state + 1) (locals state)
         in Right state
              { pc        = newPc
              , callStack = frame : callStack state
              }
       else Left "Call address out of bounds"

returnFromCall :: VMState -> CallFrame -> [CallFrame] -> VMValue -> VMState
returnFromCall state frame rest _retVal =
  state
    { pc        = returnAddress frame
    , callStack = rest
    , locals    = savedLocals frame
    }

updateLocal :: Int -> VMValue -> [VMValue] -> [VMValue]
updateLocal index val localsList =
  take index localsList ++ [val] ++ drop (index + 1) localsList

storeVariable :: VMState -> Int -> VMValue -> [VMValue] -> Either String VMState
storeVariable state index val rest =
  if index >= 0 && index < length (locals state)
    then Right state
           { stack  = rest
           , locals = updateLocal index val (locals state)
           , pc     = pc state + 1
           }
    else Left "Variable index out of bounds"

printValue :: VMValue -> Maybe String
printValue (VMString s) = Just s
printValue (VMInt n)    = Just (show n)
printValue (VMBool b)   = Just (if b then "#t" else "#f")
printValue _            = Nothing

doPrint :: VMState -> VMValue -> [VMValue] -> Either String VMState
doPrint state val rest =
  case printValue val of
    Just output ->
      Right state
        { stack   = rest
        , pc      = pc state + 1
        , outputs = outputs state ++ [output]
        }
    Nothing ->
      Left "Unsupported type for PRINT"

--------------------------------------------------------------------------------
-- Décodeur de programme binaire -> [Instruction]
--------------------------------------------------------------------------------

decodeProgram :: BS.ByteString -> Either String [Instruction]
decodeProgram bs = go bs []
  where
    go b acc
      | BS.null b = Right (reverse acc)
      | otherwise =
          case BS.uncons b of
            Nothing -> Right (reverse acc)
            Just (op, rest) ->
              case decodeOpcode op of
                Nothing -> Left ("Unknown opcode: " ++ show op)
                Just decodeInstr ->
                  case decodeInstr rest of
                    Nothing -> Left "Truncated bytecode"
                    Just (instr, rest') -> go rest' (instr : acc)

--------------------------------------------------------------------------------
-- ELF File Loading
--------------------------------------------------------------------------------

-- Simplified ELF parsing - extract .text or .glados section
parseELFSections :: BS.ByteString -> Either String BS.ByteString
parseELFSections bs
  | BS.length bs < 52 = Left "ELF file too small"
  | otherwise =
      let magic = BS.take 4 bs
      in if magic /= BS.pack [0x7F, 0x45, 0x4C, 0x46]
           then Left "Invalid ELF magic number"
           else extractTextSection bs

-- Extract .text section from ELF
extractTextSection :: BS.ByteString -> Either String BS.ByteString
extractTextSection bs =
  let -- Read section header offset (at offset 32, 4 bytes)
      sectionHeaderOffset = readWord32LE bs 32
      -- Read number of sections (at offset 48, 2 bytes)
      sectionCount = fromIntegral (readWord16LE bs 48)
      -- Read section header size (at offset 46, 2 bytes)
      sectionHeaderSize = fromIntegral (readWord16LE bs 46)
  in searchSections bs sectionHeaderOffset sectionCount sectionHeaderSize 0

-- Search for .text section
searchSections :: BS.ByteString -> Word32 -> Int -> Int -> Int -> Either String BS.ByteString
searchSections bs offset count headerSize idx
  | idx >= count = Left "No .text section found in ELF"
  | otherwise =
      let sectionOffset = fromIntegral offset + (idx * headerSize)
          -- Section offset is at +32 in section header
          sectDataOffset = fromIntegral (readWord32LE bs (sectionOffset + 32))
          -- Section size is at +36 in section header
          sectSize = fromIntegral (readWord32LE bs (sectionOffset + 36))
      in if sectDataOffset > 0 && sectSize > 0 && sectDataOffset + sectSize <= BS.length bs
           then Right (BS.take sectSize (BS.drop sectDataOffset bs))
           else searchSections bs offset count headerSize (idx + 1)

-- Read 32-bit little-endian word from ByteString at offset
readWord32LE :: BS.ByteString -> Int -> Word32
readWord32LE bs offset
  | offset + 4 > BS.length bs = 0
  | otherwise =
      let bytes = BS.unpack (BS.take 4 (BS.drop offset bs))
      in fromIntegral (bytes !! 0) +
         fromIntegral (bytes !! 1) * 256 +
         fromIntegral (bytes !! 2) * 65536 +
         fromIntegral (bytes !! 3) * 16777216

-- Read 16-bit little-endian word from ByteString at offset
readWord16LE :: BS.ByteString -> Int -> Word16
readWord16LE bs offset
  | offset + 2 > BS.length bs = 0
  | otherwise =
      let bytes = BS.unpack (BS.take 2 (BS.drop offset bs))
      in fromIntegral (bytes !! 0) +
         fromIntegral (bytes !! 1) * 256

-- Load program from ELF file
loadProgramFromELF :: FilePath -> IO (Either String [Instruction])
loadProgramFromELF filePath = do
  result <- try (BS.readFile filePath) :: IO (Either SomeException BS.ByteString)
  case result of
    Left err -> return $ Left ("Failed to read ELF file: " ++ show err)
    Right fileContent -> do
      case parseELFSections fileContent of
        Left err -> return $ Left ("Failed to parse ELF: " ++ err)
        Right bytecodeSection -> 
          return $ decodeProgram bytecodeSection

-- Execute ELF file and return result
runELFFile :: FilePath -> IO (Either String VMValue, [String])
runELFFile filePath = do
  progResult <- loadProgramFromELF filePath
  case progResult of
    Left err -> return (Left err, [])
    Right instrs -> return $ runVM instrs
