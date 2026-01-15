{-
-- EPITECH PROJECT, 2025
-- ELF Loader module
-- File description:
-- ELF file parser and x86-64 executable loader
-}

module ELFLoader
  ( loadAndExecuteELF
  , parseELFFile
  , ELFFile(..)
  , ELFSection(..)
  ) where

import qualified Data.ByteString as BS
import Data.Word (Word8, Word16, Word32, Word64)
import Data.Bits ((.|.), shiftL)
import Data.List()
import Control.Exception (try, SomeException(..))
import System.Process (callCommand)
import System.Exit()

-- ELF Section representation
data ELFSection = ELFSection
  { sectionName    :: String
  , sectionOffset  :: Word64
  , sectionSize    :: Word64
  , sectionFlags   :: Word64
  , sectionData    :: BS.ByteString
  } deriving (Show, Eq)

-- ELF File representation (64-bit)
data ELFFile = ELFFile
  { elfMagic       :: [Word8]
  , elfClass       :: Word8          -- 1 = 32-bit, 2 = 64-bit
  , elfData        :: Word8          -- 1 = little-endian, 2 = big-endian
  , elfOSABI       :: Word8
  , elfType        :: Word16
  , elfMachine     :: Word16
  , elfEntry       :: Word64
  , elfSectionHeaderOffset :: Word64
  , elfSectionHeaderSize   :: Word16
  , elfSectionHeaderCount  :: Word16
  , elfSectionNameIndex    :: Word16
  , elfSections    :: [ELFSection]
  } deriving (Show, Eq)

-- Load and execute ELF file
loadAndExecuteELF :: FilePath -> IO (Either String Int)
loadAndExecuteELF filePath = do
  result <- try (BS.readFile filePath) :: IO (Either SomeException BS.ByteString)
  case result of
    Left err -> return $ Left ("Failed to read ELF file: " ++ show err)
    Right fileContent ->
      case parseELFFile fileContent of
        Left err -> return $ Left ("Failed to parse ELF: " ++ err)
        Right elf -> executeELF filePath elf

-- Parse ELF file
parseELFFile :: BS.ByteString -> Either String ELFFile
parseELFFile bs
  | BS.length bs < 64 = Left "ELF file too small"
  | otherwise =
      let magic = BS.unpack (BS.take 4 bs)
          elfMagic' = [0x7F, 0x45, 0x4C, 0x46]
      in if magic /= elfMagic'
           then Left "Invalid ELF magic number"
           else parseELFHeader bs

-- Parse ELF header (64-bit little-endian)
parseELFHeader :: BS.ByteString -> Either String ELFFile
parseELFHeader bs =
  let magic' = BS.unpack (BS.take 4 bs)
      elfClass' = BS.index bs 4
      elfData' = BS.index bs 5
      elfOSABI' = BS.index bs 7
      
      -- Validate format
      isValid = elfClass' == 2 && elfData' == 1  -- 64-bit, little-endian
  in if not isValid
       then Left "Only 64-bit little-endian ELF files supported"
       else
         let elfType' = readWord16LE bs 16
             elfMachine' = readWord16LE bs 18
             elfEntry' = readWord64LE bs 32
             elfSectionHeaderOffset' = readWord64LE bs 40
             elfSectionHeaderSize' = readWord16LE bs 58
             elfSectionHeaderCount' = readWord16LE bs 60
             elfSectionNameIndex' = readWord16LE bs 62
             
             sections = parseSectionHeaders bs elfSectionHeaderOffset' elfSectionHeaderCount' elfSectionHeaderSize'
         in Right $ ELFFile
              { elfMagic = magic'
              , elfClass = elfClass'
              , elfData = elfData'
              , elfOSABI = elfOSABI'
              , elfType = elfType'
              , elfMachine = elfMachine'
              , elfEntry = elfEntry'
              , elfSectionHeaderOffset = elfSectionHeaderOffset'
              , elfSectionHeaderSize = elfSectionHeaderSize'
              , elfSectionHeaderCount = elfSectionHeaderCount'
              , elfSectionNameIndex = elfSectionNameIndex'
              , elfSections = sections
              }

-- Parse section headers
parseSectionHeaders :: BS.ByteString -> Word64 -> Word16 -> Word16 -> [ELFSection]
parseSectionHeaders bs offset count size =
  [parseSection bs (offset + fromIntegral (i :: Integer) * fromIntegral size) | i <- [0..fromIntegral count - 1]]

-- Parse a single section header (64-bit)
parseSection :: BS.ByteString -> Word64 -> ELFSection
parseSection bs offset =
  let offset' = fromIntegral offset
      _nameIdx = readWord32LE bs (offset' + 0)
      _sectionType = readWord32LE bs (offset' + 4)
      sectionFlags' = readWord64LE bs (offset' + 8)
      _sectionAddr = readWord64LE bs (offset' + 16)
      sectionOffset' = readWord64LE bs (offset' + 24)
      sectionSize' = readWord64LE bs (offset' + 32)
      sectionData' = if fromIntegral sectionOffset' + fromIntegral sectionSize' <= BS.length bs
                    then BS.take (fromIntegral sectionSize') (BS.drop (fromIntegral sectionOffset') bs)
                    else BS.empty
  in ELFSection
       { sectionName = ""  -- Name lookup requires string table
       , sectionOffset = sectionOffset'
       , sectionSize = sectionSize'
       , sectionFlags = sectionFlags'
       , sectionData = sectionData'
       }

-- Execute ELF file by linking and running
executeELF :: FilePath -> ELFFile -> IO (Either String Int)
executeELF filePath elf = do
  case elfMachine elf of
    62 -> executeX86_64ELF filePath elf  -- EM_X86_64
    _ -> return $ Left ("Unsupported architecture: " ++ show (elfMachine elf))

-- Execute x86-64 ELF file
executeX86_64ELF :: FilePath -> ELFFile -> IO (Either String Int)
executeX86_64ELF objFile _ = do
  -- Link the object file into an executable using GCC
  let exePath = "/tmp/glados_prog"
  
  -- Use GCC to link, which will handle all the library dependencies and relocations
  result <- try (callCommand $ 
    "gcc -o " ++ exePath ++ " " ++ objFile ++ 
    " -no-pie 2>/dev/null") 
    :: IO (Either SomeException ())
  
  case result of
    Left _ -> do
      -- Fallback: try with ld and minimal linking
      result2 <- try (callCommand $ 
        "ld -o " ++ exePath ++ " " ++ objFile ++ 
        " -lc -dynamic-linker /lib64/ld-linux-x86-64.so.2 2>/dev/null") 
        :: IO (Either SomeException ())
      case result2 of
        Left err -> return $ Left ("Linking failed: " ++ show err)
        Right () -> executeProgram exePath
    Right () -> executeProgram exePath

-- Execute the linked program
executeProgram :: FilePath -> IO (Either String Int)
executeProgram exePath = do
  result <- try (callCommand exePath) :: IO (Either SomeException ())
  case result of
    Left err -> return $ Left ("Execution failed: " ++ show err)
    Right () -> return $ Right 0

-- Helper: Read 16-bit little-endian
readWord16LE :: BS.ByteString -> Int -> Word16
readWord16LE bs offset
  | offset + 2 > BS.length bs = 0
  | otherwise =
      let b0 = fromIntegral (BS.index bs offset) :: Word16
          b1 = fromIntegral (BS.index bs (offset + 1)) :: Word16
      in b0 .|. (b1 `shiftL` 8)

-- Helper: Read 32-bit little-endian
readWord32LE :: BS.ByteString -> Int -> Word32
readWord32LE bs offset
  | offset + 4 > BS.length bs = 0
  | otherwise =
      let b0 = fromIntegral (BS.index bs offset) :: Word32
          b1 = fromIntegral (BS.index bs (offset + 1)) :: Word32
          b2 = fromIntegral (BS.index bs (offset + 2)) :: Word32
          b3 = fromIntegral (BS.index bs (offset + 3)) :: Word32
      in b0 .|. (b1 `shiftL` 8) .|. (b2 `shiftL` 16) .|. (b3 `shiftL` 24)

-- Helper: Read 64-bit little-endian
readWord64LE :: BS.ByteString -> Int -> Word64
readWord64LE bs offset
  | offset + 8 > BS.length bs = 0
  | otherwise =
      let low = readWord32LE bs offset
          high = readWord32LE bs (offset + 4)
      in fromIntegral low .|. (fromIntegral high `shiftL` 32)


