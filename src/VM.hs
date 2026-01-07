{-
-- EPITECH PROJECT, 2025
-- VM module
-- File description:
-- Virtual Machine for executing bytecode
-}

module VM (VMValue(..), VMState(..), runVM, execBytecode) where

import Bytecode
import Data.Int (Int32)
import qualified Data.Map.Strict as Map
import qualified Bytecode as BC

data VMValue
    = VMInt Int32
    | VMBool Bool
    | VMString String
    | VMClosure Int32 Int32 [VMValue]
    | VMVoid
    deriving (Show, Eq)

data VMState = VMState
    { stack :: [VMValue]
    , pc :: Int
    , callStack :: [CallFrame]
    , globals :: Map.Map String VMValue
    , locals :: [VMValue]
    , program :: [Instruction]
    , halted :: Bool
    , outputs :: [String]
    } deriving (Show)

data CallFrame = CallFrame
    { returnAddress :: Int
    , savedLocals :: [VMValue]
    } deriving (Show)

initVM :: [Instruction] -> VMState
initVM instrs = VMState
    { stack = []
    , pc = 0
    , callStack = []
    , globals = Map.empty
    , locals = []
    , program = instrs
    , halted = False
    , outputs = []
    }

runVM :: [Instruction] -> (Either String VMValue, [String])
runVM instrs = execBytecode (initVM instrs)

getResult :: VMState -> (Either String VMValue, [String])
getResult state = 
    let out = outputs state
    in case stack state of
        (v:_) -> (Right v, out)
        [] -> (Right VMVoid, out)

execBytecode :: VMState -> (Either String VMValue, [String])
execBytecode state
    | halted state = getResult state
    | pc state >= length (program state) = 
        (Left "PC out of bounds", outputs state)
    | otherwise = 
        case step state (program state !! pc state) of
            Left err -> (Left err, outputs state)
            Right newState -> execBytecode newState

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
        [] -> Left "Stack underflow on POP"

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
                    , pc = pc state + 1 
                    }
        _ -> Left "Type error in DIV"

step state BC.MOD =
    case stack state of
        (VMInt b : VMInt a : rest) ->
            if b == 0
                then Left "Modulo by zero"
                else Right state 
                    { stack = VMInt (a `mod` b) : rest
                    , pc = pc state + 1 
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
        _ -> callFunction state addr

step state RET =
    case callStack state of
        (frame : rest) ->
            case stack state of
                (retVal : stackRest) ->
                    let newState = returnFromCall state frame rest retVal
                    in Right newState { stack = retVal : stackRest }
                [] -> Left "Stack underflow on RET"
        [] -> Right state { halted = True }

step state (LOAD_VAR idx) =
    let index = fromIntegral idx
    in if index >= 0 && index < length (locals state)
        then Right state 
            { stack = (locals state !! index) : stack state
            , pc = pc state + 1
            }
        else Left "Variable index out of bounds"

step state (STORE_VAR idx) =
    case stack state of
        (val : rest) -> storeVariable state (fromIntegral idx) val rest
        [] -> Left "Stack underflow on STORE_VAR"

step state (LOAD_GLOBAL name) =
    case Map.lookup name (globals state) of
        Just val -> Right state 
            { stack = val : stack state
            , pc = pc state + 1
            }
        Nothing -> Left ("Undefined global variable: " ++ name)

step state (STORE_GLOBAL name) =
    case stack state of
        (val : rest) ->
            Right state 
                { stack = rest
                , globals = Map.insert name val (globals state)
                , pc = pc state + 1
                }
        [] -> Left "Stack underflow on STORE_GLOBAL"
        

step state (MAKE_CLOSURE addr nparams) =
    let closure = VMClosure addr nparams (locals state)
    in Right state 
        { stack = closure : stack state
        , pc = pc state + 1
        }

step state HALT =
    Right state { halted = True }

step state (LOAD_CONST s) =
    Right state { stack = VMString s : stack state, pc = pc state + 1 }
step state PRINT =
    case stack state of
        (val : rest) -> doPrint state val rest
        [] -> Left "Stack underflow on PRINT"

-- Helper functions moved below so all `step` equations are contiguous

setupClosureCall :: VMState -> Int32 -> [VMValue] -> [VMValue] -> VMState
setupClosureCall state closureAddr capturedEnv args =
    let frame = CallFrame (pc state + 1) (locals state)
        newLocals = reverse args ++ capturedEnv
    in state 
        { pc = fromIntegral closureAddr
        , callStack = frame : callStack state
        , locals = newLocals
        }

callClosure :: VMState -> Int32 -> Int32 -> [VMValue] -> [VMValue] -> Either String VMState
callClosure state closureAddr nparams capturedEnv args =
    if length args < fromIntegral nparams
        then Left "Not enough arguments for closure call"
        else
            let (actualArgs, rest) = splitAt (fromIntegral nparams) args
                newState = setupClosureCall state closureAddr 
                                            capturedEnv actualArgs
            in Right newState { stack = rest }

callFunction :: VMState -> Int32 -> Either String VMState
callFunction state addr =
    let newPc = fromIntegral addr
    in if newPc >= 0 && newPc < length (program state)
        then 
            let frame = CallFrame (pc state + 1) (locals state)
            in Right state 
                { pc = newPc
                , callStack = frame : callStack state
                }
        else Left "Call address out of bounds"

returnFromCall :: VMState -> CallFrame -> [CallFrame] -> VMValue -> VMState
returnFromCall state frame rest retVal =
    state 
        { pc = returnAddress frame
        , callStack = rest
        , locals = savedLocals frame
        }

updateLocal :: Int -> VMValue -> [VMValue] -> [VMValue]
updateLocal index val localsList =
    take index localsList ++ [val] ++ drop (index + 1) localsList

storeVariable :: VMState -> Int -> VMValue -> [VMValue] -> Either String VMState
storeVariable state index val rest =
    if index >= 0 && index < length (locals state)
        then Right state 
            { stack = rest
            , locals = updateLocal index val (locals state)
            , pc = pc state + 1
            }
        else Left "Variable index out of bounds"

printValue :: VMValue -> Maybe String
printValue (VMString s) = Just s
printValue (VMInt n) = Just (show n)
printValue (VMBool b) = Just (if b then "#t" else "#f")
printValue _ = Nothing

doPrint :: VMState -> VMValue -> [VMValue] -> Either String VMState
doPrint state val rest =
    case printValue val of
        Just output -> 
            Right state 
                { stack = rest
                , pc = pc state + 1
                , outputs = outputs state ++ [output]
                }
        Nothing -> Left "Unsupported type for PRINT"

