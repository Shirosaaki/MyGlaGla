{-
-- EPITECH PROJECT, 2025
-- Test bytecode generator
-- File description:
-- Generate a simple .o file for testing
-}

import Bytecode
import Loader
import qualified Bytecode as BC

-- Simple program: PUSH 2, PUSH 3, ADD, HALT
-- Expected result: 5
simpleAdd :: [Instruction]
simpleAdd = 
    [ PUSH 2
    , PUSH 3
    , ADD
    , HALT
    ]

-- Program with multiplication: PUSH 4, PUSH 5, MUL, HALT
-- Expected result: 20
simpleMul :: [Instruction]
simpleMul = 
    [ PUSH 4
    , PUSH 5
    , MUL
    , HALT
    ]

-- Program with comparison: PUSH 3, PUSH 5, LT, HALT
-- Expected result: #t (true)
simpleLT :: [Instruction]
simpleLT = 
    [ PUSH 3
    , PUSH 5
    , BC.LT
    , HALT
    ]

-- Complex arithmetic: (2 + 3) * 4 = 20
complexArith :: [Instruction]
complexArith = 
    [ PUSH 2
    , PUSH 3
    , ADD
    , PUSH 4
    , MUL
    , HALT
    ]

main :: IO ()
main = do
    putStrLn "Generating test bytecode files..."
    
    saveBytecodeFile "test_add.o" simpleAdd
    putStrLn "Created test_add.o (2 + 3)"
    
    saveBytecodeFile "test_mul.o" simpleMul
    putStrLn "Created test_mul.o (4 * 5)"
    
    saveBytecodeFile "test_lt.o" simpleLT
    putStrLn "Created test_lt.o (3 < 5)"
    
    saveBytecodeFile "test_complex.o" complexArith
    putStrLn "Created test_complex.o ((2 + 3) * 4)"
    
    putStrLn "\nDisassembly of test_add.o:"
    putStrLn $ disassemble simpleAdd
    
    putStrLn "Done!"
