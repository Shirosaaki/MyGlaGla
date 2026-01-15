{-
-- EPITECH PROJECT, 2025
-- Loader module
-- File description:
-- Load and save bytecode from/to .o files
-}

module Loader (loadBytecodeFile, saveBytecodeFile, disassemble) where

import Bytecode
import qualified Data.ByteString as BS
import Data.Word (Word8)
import Data.Int (Int32)
import Data.Bits ((.&.))

-- Magic number for .o files: "GLO\0"
magicNumber :: [Word8]
magicNumber = [0x47, 0x4C, 0x4F, 0x00]

-- Version number
versionNumber :: Word8
versionNumber = 0x01

-- Load bytecode from a .o file
loadBytecodeFile :: FilePath -> IO (Either String [Instruction])
loadBytecodeFile path = do
    contents <- BS.readFile path
    return $ parseBytecodeFile contents

-- Parse bytecode from ByteString
parseBytecodeFile :: BS.ByteString -> Either String [Instruction]
parseBytecodeFile bs =
    if BS.take 4 bs /= BS.pack magicNumber
        then Left "Invalid file format: bad magic number"
        else parseVersion (BS.drop 4 bs)

parseVersion :: BS.ByteString -> Either String [Instruction]
parseVersion bs
    | BS.null bs = Left "Unexpected end of file: no version"
    | BS.head bs /= versionNumber = Left "Unsupported version"
    | otherwise = parseInstructions (BS.tail bs) []

decodeAndParse :: Word8 -> BS.ByteString -> Either String (Instruction, BS.ByteString)
decodeAndParse opcode bs = do
    decoder <- maybe (Left $ "Unknown opcode: 0x" ++ showHex opcode) 
                     Right 
                     (decodeOpcode opcode)
    maybe (Left "Failed to decode instruction") 
          Right 
          (decoder bs)

-- Parse all instructions
parseInstructions :: BS.ByteString -> [Instruction] -> Either String [Instruction]
parseInstructions bs acc
    | BS.null bs = Right (reverse acc)
    | otherwise = do
        (instr, rest) <- decodeAndParse (BS.head bs) (BS.tail bs)
        parseInstructions rest (instr : acc)

-- Helper to show hex
showHex :: Word8 -> String
showHex w = 
    let h = fromIntegral w :: Int
        toHexDigit n = "0123456789ABCDEF" !! n
    in [toHexDigit (h `div` 16), toHexDigit (h `mod` 16)]

-- Save bytecode to a .o file
saveBytecodeFile :: FilePath -> [Instruction] -> IO ()
saveBytecodeFile path instrs =
    let encoded = encodeBytecodeFile instrs
    in BS.writeFile path encoded

-- Encode bytecode to ByteString
encodeBytecodeFile :: [Instruction] -> BS.ByteString
encodeBytecodeFile instrs =
    let magic = BS.pack magicNumber
        version = BS.singleton versionNumber
        code = BS.concat (map encodeInstruction instrs)
    in BS.concat [magic, version, code]

encodeWithInt32 :: Instruction -> Int32 -> BS.ByteString
encodeWithInt32 instr n = BS.cons (opcodeOf instr) (encodeInt32 n)

encodeWithString :: Instruction -> String -> BS.ByteString
encodeWithString instr s = BS.cons (opcodeOf instr) (encodeString s)

-- Encode a single instruction
encodeInstruction :: Instruction -> BS.ByteString
encodeInstruction (PUSH n) = encodeWithInt32 (PUSH n) n
encodeInstruction (JUMP addr) = encodeWithInt32 (JUMP addr) addr
encodeInstruction (JUMP_IF_FALSE addr) = 
    encodeWithInt32 (JUMP_IF_FALSE addr) addr
encodeInstruction (CALL addr) = encodeWithInt32 (CALL addr) addr
encodeInstruction (LOAD_VAR idx) = encodeWithInt32 (LOAD_VAR idx) idx
encodeInstruction (STORE_VAR idx) = encodeWithInt32 (STORE_VAR idx) idx
encodeInstruction (LOAD_GLOBAL name) = 
    encodeWithString (LOAD_GLOBAL name) name
encodeInstruction (STORE_GLOBAL name) = 
    encodeWithString (STORE_GLOBAL name) name
encodeInstruction (LOAD_CONST s) = encodeWithString (LOAD_CONST s) s
encodeInstruction (MAKE_CLOSURE addr nparams) = 
    BS.cons (opcodeOf (MAKE_CLOSURE addr nparams)) 
            (BS.append (encodeInt32 addr) (encodeInt32 nparams))
encodeInstruction instr = BS.singleton (opcodeOf instr)

-- Encode Int32 as 4 bytes (big-endian)
encodeInt32 :: Int32 -> BS.ByteString
encodeInt32 n =
    let n' = fromIntegral n :: Int
        n'' = if n' < 0 then n' + 2^(32::Int) else n'
        b0 = fromIntegral ((n'' `div` (2^(24::Int))) .&. 0xFF)
        b1 = fromIntegral (((n'' `div` (2^(16::Int))) .&. 0xFF))
        b2 = fromIntegral (((n'' `div` (2^(8::Int))) .&. 0xFF))
        b3 = fromIntegral (n'' .&. 0xFF)
    in BS.pack [b0, b1, b2, b3]

-- Encode String as length-prefixed bytes
encodeString :: String -> BS.ByteString
encodeString s =
    let len = fromIntegral (length s) :: Int32
        strBytes = BS.pack (map (toEnum . fromEnum) s)
    in BS.append (encodeInt32 len) strBytes

-- Disassemble bytecode to human-readable format
disassemble :: [Instruction] -> String
disassemble instrs = unlines $ zipWith formatInstr [0..] instrs
  where
    formatInstr :: Int -> Instruction -> String
    formatInstr addr instr = 
        let addrStr = padLeft 6 (show addr)
            instrStr = show instr
        in addrStr ++ ": " ++ instrStr
    
    padLeft :: Int -> String -> String
    padLeft n s = replicate (n - length s) ' ' ++ s
