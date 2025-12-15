{-
-- EPITECH PROJECT, 2025
-- Bytecode module
-- File description:
-- Bytecode instruction set definition
-}

module Bytecode where

import Data.Word (Word8)
import Data.Int (Int32)
import qualified Data.ByteString as BS
import Prelude hiding (LT, EQ)

data Instruction
    = PUSH Int32
    | POP
    | ADD
    | SUB
    | MUL
    | DIV
    | MOD
    | LT
    | EQ
    | JUMP Int32
    | JUMP_IF_FALSE Int32
    | CALL Int32
    | RET
    | LOAD_VAR Int32
    | STORE_VAR Int32
    | LOAD_GLOBAL String
    | STORE_GLOBAL String
    | MAKE_CLOSURE Int32 Int32
    | PUSH_TRUE
    | PUSH_FALSE
    | HALT
    deriving (Show, Eq)

data BytecodeProgram = BytecodeProgram
    { instructions :: [Instruction]
    , constants :: [Int32]
    , globalNames :: [String]
    } deriving (Show, Eq)

opcodeOf :: Instruction -> Word8
opcodeOf (PUSH _) = 0x01
opcodeOf POP = 0x02
opcodeOf ADD = 0x03
opcodeOf SUB = 0x04
opcodeOf MUL = 0x05
opcodeOf DIV = 0x06
opcodeOf MOD = 0x07
opcodeOf LT = 0x08
opcodeOf EQ = 0x09
opcodeOf (JUMP _) = 0x0A
opcodeOf (JUMP_IF_FALSE _) = 0x0B
opcodeOf (CALL _) = 0x0C
opcodeOf RET = 0x0D
opcodeOf (LOAD_VAR _) = 0x0E
opcodeOf (STORE_VAR _) = 0x0F
opcodeOf (LOAD_GLOBAL _) = 0x10
opcodeOf (STORE_GLOBAL _) = 0x11
opcodeOf (MAKE_CLOSURE _ _) = 0x12
opcodeOf PUSH_TRUE = 0x13
opcodeOf PUSH_FALSE = 0x14
opcodeOf HALT = 0xFF

decodeOpcode :: Word8 -> Maybe (BS.ByteString -> Maybe (Instruction, BS.ByteString))
decodeOpcode 0x01 = Just decodePUSH
decodeOpcode 0x02 = Just $ \bs -> Just (POP, bs)
decodeOpcode 0x03 = Just $ \bs -> Just (ADD, bs)
decodeOpcode 0x04 = Just $ \bs -> Just (SUB, bs)
decodeOpcode 0x05 = Just $ \bs -> Just (MUL, bs)
decodeOpcode 0x06 = Just $ \bs -> Just (DIV, bs)
decodeOpcode 0x07 = Just $ \bs -> Just (MOD, bs)
decodeOpcode 0x08 = Just $ \bs -> Just (LT, bs)
decodeOpcode 0x09 = Just $ \bs -> Just (EQ, bs)
decodeOpcode 0x0A = Just decodeJUMP
decodeOpcode 0x0B = Just decodeJUMP_IF_FALSE
decodeOpcode 0x0C = Just decodeCALL
decodeOpcode 0x0D = Just $ \bs -> Just (RET, bs)
decodeOpcode 0x0E = Just decodeLOAD_VAR
decodeOpcode 0x0F = Just decodeSTORE_VAR
decodeOpcode 0x10 = Just decodeLOAD_GLOBAL
decodeOpcode 0x11 = Just decodeSTORE_GLOBAL
decodeOpcode 0x12 = Just decodeMAKE_CLOSURE
decodeOpcode 0x13 = Just $ \bs -> Just (PUSH_TRUE, bs)
decodeOpcode 0x14 = Just $ \bs -> Just (PUSH_FALSE, bs)
decodeOpcode 0xFF = Just $ \bs -> Just (HALT, bs)
decodeOpcode _ = Nothing

decodePUSH :: BS.ByteString -> Maybe (Instruction, BS.ByteString)
decodePUSH bs = do
    (val, rest) <- decodeInt32 bs
    Just (PUSH val, rest)

decodeJUMP :: BS.ByteString -> Maybe (Instruction, BS.ByteString)
decodeJUMP bs = do
    (addr, rest) <- decodeInt32 bs
    Just (JUMP addr, rest)

decodeJUMP_IF_FALSE :: BS.ByteString -> Maybe (Instruction, BS.ByteString)
decodeJUMP_IF_FALSE bs = do
    (addr, rest) <- decodeInt32 bs
    Just (JUMP_IF_FALSE addr, rest)

decodeCALL :: BS.ByteString -> Maybe (Instruction, BS.ByteString)
decodeCALL bs = do
    (addr, rest) <- decodeInt32 bs
    Just (CALL addr, rest)

decodeLOAD_VAR :: BS.ByteString -> Maybe (Instruction, BS.ByteString)
decodeLOAD_VAR bs = do
    (idx, rest) <- decodeInt32 bs
    Just (LOAD_VAR idx, rest)

decodeSTORE_VAR :: BS.ByteString -> Maybe (Instruction, BS.ByteString)
decodeSTORE_VAR bs = do
    (idx, rest) <- decodeInt32 bs
    Just (STORE_VAR idx, rest)

decodeLOAD_GLOBAL :: BS.ByteString -> Maybe (Instruction, BS.ByteString)
decodeLOAD_GLOBAL bs = do
    (name, rest) <- decodeString bs
    Just (LOAD_GLOBAL name, rest)

decodeSTORE_GLOBAL :: BS.ByteString -> Maybe (Instruction, BS.ByteString)
decodeSTORE_GLOBAL bs = do
    (name, rest) <- decodeString bs
    Just (STORE_GLOBAL name, rest)

decodeMAKE_CLOSURE :: BS.ByteString -> Maybe (Instruction, BS.ByteString)
decodeMAKE_CLOSURE bs = do
    (addr, rest1) <- decodeInt32 bs
    (nparams, rest2) <- decodeInt32 rest1
    Just (MAKE_CLOSURE addr nparams, rest2)

decodeInt32 :: BS.ByteString -> Maybe (Int32, BS.ByteString)
decodeInt32 bs
    | BS.length bs >= 4 = 
        let bytes = BS.unpack (BS.take 4 bs)
            val = fromIntegral (bytes !! 0) * 256^3 +
                  fromIntegral (bytes !! 1) * 256^2 +
                  fromIntegral (bytes !! 2) * 256 +
                  fromIntegral (bytes !! 3)
            val' = if val > 2^31 - 1 then val - 2^32 else val
        in Just (fromIntegral val', BS.drop 4 bs)
    | otherwise = Nothing

decodeString :: BS.ByteString -> Maybe (String, BS.ByteString)
decodeString bs = do
    (len, rest) <- decodeInt32 bs
    if BS.length rest >= fromIntegral len
        then Just (map (toEnum . fromEnum) (BS.unpack (BS.take (fromIntegral len) rest)), 
                   BS.drop (fromIntegral len) rest)
        else Nothing
