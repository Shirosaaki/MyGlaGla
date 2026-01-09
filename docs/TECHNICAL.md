# Technical Documentation

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Project Structure](#project-structure)
- [Core Components](#core-components)
- [Development Setup](#development-setup)
- [Contributing Guidelines](#contributing-guidelines)
- [Code Style](#code-style)
- [Testing](#testing)
- [Build System](#build-system)

---

## Architecture Overview

GLADOS is a compiler and interpreter for TheShowLang (TSL), a custom programming language. The project is written in Haskell and follows a multi-stage compilation pipeline:

```
Source Code → Parser → AST → Compiler/Evaluator → Bytecode → VM
```

### Key Features

- **Dual Parser Support**: TheShow and Lisp syntax
- **Type System**: Basic type inference with optional type annotations
- **Execution Modes**:
  - Interactive REPL console
  - Batch compilation to LLVM IR
  - Bytecode compilation and VM execution
- **Language Features**: Variables, functions, lambdas, control flow, arrays, structs, pointers

---

## Project Structure

```
.
├── app/                    # Application entry point
│   └── Main.hs            # CLI interface and mode dispatcher
├── src/                   # Core library source code
│   ├── AST.hs            # Abstract Syntax Tree definitions
│   ├── Bytecode.hs       # Bytecode instruction set
│   ├── Compiler.hs       # LLVM IR compiler
│   ├── Console.hs        # Interactive REPL
│   ├── Loader.hs         # Bytecode loader/disassembler
│   ├── Parser.hs         # Parser dispatcher
│   ├── VM.hs             # Virtual Machine
│   ├── Lib.hs            # Library entry point
│   ├── Lisp/
│   │   └── Parser.hs     # Lisp syntax parser
│   └── Theshow/
│       └── Parser.hs     # TheShow syntax parser
├── test/                  # Test suite
│   ├── Spec.hs           # Test entry point
│   └── files_test/       # Test files
├── examples/              # Example TSL programs
├── docs/                  # Documentation
├── tools/                 # Development tools
├── package.yaml          # Stack package configuration
└── glados.cabal          # Generated cabal file
```

---

## Core Components

### 1. Parser (`src/Parser.hs`, `src/Theshow/Parser.hs`, `src/Lisp/Parser.hs`)

**Purpose**: Convert source code text into S-expressions

**Key Functions**:
- `parseSExpr :: String -> Maybe SExpr` - Parse single expression
- `parseSExprMultiple :: String -> Maybe [SExpr]` - Parse multiple expressions
- `setUseLisp :: Bool -> IO ()` - Switch between TheShow and Lisp parsers

**Implementation**:
- Uses Megaparsec for parsing
- Runtime parser selection via `IORef`
- Both parsers produce the same `SExpr` data type

**Example Flow**:
```haskell
-- TheShow syntax
"(define x 42)" → SList [SSymbol "define", SSymbol "x", SInt 42]

-- Lisp syntax (with -l flag)
"(define x 42)" → SList [SSymbol "define", SSymbol "x", SInt 42]
```

### 2. AST (`src/AST.hs`)

**Purpose**: Define and evaluate the Abstract Syntax Tree

**Key Types**:

```haskell
data SExpr = SInt Int | SFloat Double | SBool Bool | SString String 
           | SChar Char | SSymbol String | SList [SExpr]

data Ast = Define String (Maybe Type) Ast
         | AstInt Int | AstFloat Double | AstBool Bool
         | Call Ast [Ast]
         | AstLambda [String] Ast
         | IfElse Ast Ast Ast
         | While Ast Ast
         | For String Ast Ast
         | ArrayAccess Ast Ast
         -- ... and more
```

**Key Functions**:
- `sexprToAST :: SExpr -> Env -> Either String Ast` - Convert S-expression to AST
- `evalAST :: Ast -> Env -> EvalResult` - Evaluate AST in given environment

**Environment (`Env`)**:
- Type alias: `type Env = Map.Map String Ast`
- Stores variable bindings and function definitions
- Passed through evaluation recursively

### 3. Compiler (`src/Compiler.hs`)

**Purpose**: Compile AST to LLVM IR (work in progress)

**Key Functions**:
- `compileModuleLLVM :: Ast -> String` - Generate LLVM IR
- `compileToLL :: a -> b -> IO ()` - Write LLVM IR to file
- `compileToObject :: String -> String -> IO ()` - Compile to object file

**Current Status**: Stub implementation, LLVM compilation not fully implemented

**Type Analysis**:
- `collectVarTypes :: Ast -> Map.Map String Type -> Map.Map String Type`
- Performs simple type inference
- Identifies variable types from assignments and definitions

### 4. Bytecode (`src/Bytecode.hs`)

**Purpose**: Define bytecode instruction set

**Instruction Set**:

```haskell
data Instruction
    = PUSH Int32        -- Push value to stack
    | POP               -- Pop from stack
    | ADD | SUB | MUL | DIV | MOD  -- Arithmetic
    | LT | EQ           -- Comparisons
    | JUMP Int32        -- Unconditional jump
    | JUMP_IF_FALSE Int32  -- Conditional jump
    | CALL Int32        -- Function call
    | RET               -- Return from function
    | LOAD_VAR Int32    -- Load variable
    | STORE_VAR Int32   -- Store variable
    | PRINT             -- Output
    | HALT              -- Stop execution
```

**Serialization**:
- `serializeInstruction :: Instruction -> BS.ByteString`
- `deserializeInstruction :: BS.ByteString -> Maybe Instruction`
- Binary format for bytecode files

### 5. Virtual Machine (`src/VM.hs`)

**Purpose**: Execute bytecode instructions

**VM State**:

```haskell
data VMState = VMState
    { stack :: [VMValue]
    , pc :: Int                    -- Program counter
    , callStack :: [CallFrame]
    , globals :: Map.Map String VMValue
    , locals :: [VMValue]
    , program :: [Instruction]
    , halted :: Bool
    , outputs :: [String]
    }

data VMValue
    = VMInt Int32 | VMBool Bool | VMString String
    | VMClosure Int32 Int32 [VMValue]
    | VMVoid
```

**Execution**:
- `runVM :: [Instruction] -> VMState` - Initialize and run VM
- `execBytecode :: VMState -> VMState` - Execute single step
- Stack-based architecture

### 6. Console (`src/Console.hs`)

**Purpose**: Interactive REPL for TheShowLang

**Key Functions**:
- `runConsole :: IO ()` - Start interactive mode
- `runBatch :: [SExpr] -> IO ()` - Batch execute expressions

**Features**:
- Uses Haskeline for line editing
- Persistent environment across expressions
- Error handling and display

---

## Development Setup

### Prerequisites

- **GHC**: Glasgow Haskell Compiler (>= 8.10)
- **Stack**: Haskell build tool
- **Make**: Build automation

### Installation

```bash
# Clone repository
git clone git@github.com:LaTableSurGit/GlaGla.git
cd GlaGla

# Setup Haskell stack
stack setup

# Build project
make build

# Or use stack directly
stack build
```

### Running

```bash
# Interactive REPL
./glados

# Execute file
./glados < examples/example1.tslang

# Compile to LLVM IR
./glados -S output.ll < input.tslang

# Execute bytecode
./glados -x bytecode.bc

# Use Lisp syntax
./glados -l < lisp_file.lisp
```

---

## Contributing Guidelines

### Getting Started

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/your-feature`
3. **Read the code style guide**: See [coding_style/TSL-style.md](../coding_style/TSL-style.md)
4. **Make your changes**
5. **Add tests** for new functionality
6. **Run tests**: `make run_test`
7. **Check style**: `./tools/tsl_style_checker.sh`
8. **Commit with clear messages**
9. **Push and create a Pull Request**

### Areas for Contribution

#### High Priority

- **LLVM Compiler Backend**: Complete the LLVM IR generation in `Compiler.hs`
- **Type Inference**: Improve type system in AST evaluator
- **Standard Library**: Add built-in functions (math, string manipulation, I/O)
- **Error Messages**: Better error reporting with line numbers and context
- **Bytecode Optimizer**: Implement bytecode optimization passes

#### Medium Priority

- **Debugger**: Interactive debugger for bytecode VM
- **Package System**: Module import/export mechanism
- **Memory Management**: Garbage collection for VM
- **JIT Compilation**: Just-in-time compilation for hot code paths

#### Documentation

- **API Documentation**: Haddock comments for all modules
- **Language Tutorial**: Beginner-friendly TSL tutorials
- **Example Programs**: More complex example programs
- **Architecture Diagrams**: Visual representation of compilation pipeline

### Adding New Features

#### Adding a New AST Node

1. **Define the node** in `src/AST.hs`:
   ```haskell
   data Ast = ...
            | YourNewNode String Ast
            | ...
   ```

2. **Add parsing logic** in `src/Theshow/Parser.hs` and/or `src/Lisp/Parser.hs`

3. **Add evaluation** in `src/AST.hs` in `evalAST` function:
   ```haskell
   evalAST (YourNewNode name expr) env = do
       -- Your evaluation logic
       evalAST expr env
   ```

4. **Add bytecode compilation** (optional) in `src/Bytecode.hs`

5. **Add tests** in `test/Spec.hs`

#### Adding a New Instruction

1. **Define instruction** in `src/Bytecode.hs`:
   ```haskell
   data Instruction = ...
                    | YOUR_INSTRUCTION Int32
                    | ...
   ```

2. **Add serialization**:
   ```haskell
   serializeInstruction YOUR_INSTRUCTION val = ...
   deserializeInstruction ... = YOUR_INSTRUCTION <$> ...
   ```

3. **Implement execution** in `src/VM.hs`:
   ```haskell
   step state@VMState{...} =
       case program !! pc of
           YOUR_INSTRUCTION val -> ...
   ```

---

## Code Style

### Haskell Style Guidelines

Follow the [TSL Style Guide](../coding_style/TSL-style.md) for detailed rules. Key points:

#### Formatting

```haskell
-- Function names: camelCase
evalExpression :: Ast -> Env -> EvalResult

-- Type names: PascalCase
data MyCustomType = Constructor1 | Constructor2

-- Constants: UPPER_CASE (if truly constant)
maxStackSize :: Int
maxStackSize = 1024

-- Indentation: 4 spaces
function :: Int -> String
function x =
    let result = x + 1
    in show result
```

#### Documentation

```haskell
-- | Brief description of function
--
-- Detailed explanation if needed
--
-- Example:
-- >>> myFunction 5
-- 10
myFunction :: Int -> Int
myFunction x = x * 2
```

#### Module Structure

```haskell
{-
-- EPITECH PROJECT, 2025
-- Module Name
-- File description:
-- Brief description
-}

module ModuleName (
    -- * Exported types
    MyType(..),
    
    -- * Exported functions
    myFunction,
    myOtherFunction
) where

import qualified Data.Map as Map
import Control.Monad (when)

-- Implementation
```

### TheShowLang Style

For TSL example programs:

```tslang
; Comments use semicolons
; Functions defined with define
(define add (lambda (x y) (+ x y)))

; Variables
(define pi 3.14159)

; Control flow
(if (> x 0)
    (print "positive")
    (print "non-positive"))
```

---

## Testing

### Running Tests

```bash
# Run all tests
make run_test

# Run with coverage
make test_coverage

# Run specific test
stack test --ta "-m \"pattern\""
```

### Test Structure

Tests are in `test/Spec.hs` using Hspec framework:

```haskell
import Test.Hspec

main :: IO ()
main = hspec $ do
    describe "Parser" $ do
        it "parses integers" $ do
            parseSExpr "42" `shouldBe` Just (SInt 42)
        
        it "parses lists" $ do
            parseSExpr "(1 2 3)" `shouldBe` 
                Just (SList [SInt 1, SInt 2, SInt 3])
    
    describe "Evaluator" $ do
        it "evaluates addition" $ do
            let env = Map.empty
            evalAST (Call (AstSymbol "+") [AstInt 1, AstInt 2]) env
                `shouldReturn` Right (AstInt 3)
```

### Adding Tests

1. **Unit tests**: Test individual functions in isolation
2. **Integration tests**: Test complete compilation pipeline
3. **Example tests**: Run all example files and verify output
4. **Property tests**: Use QuickCheck for property-based testing (future)

### Test Files

Example test files in `test/files_test/`:
- `basic_arithmetic.tsl`
- `control_flow.tsl`
- `functions.tsl`
- etc.

---

## Build System

### Makefile Targets

```bash
# Build executable
make build          # Equivalent to: stack build --copy-bins

# Clean build artifacts
make clean          # Remove .stack-work/
make fclean         # clean + remove executable

# Testing
make run_test       # Run test suite
make test_coverage  # Generate coverage report

# Style checking
make style_check    # Run TSL style checker
```

### Stack Configuration

**package.yaml**: Main configuration
- Dependencies
- Build flags
- Executables and libraries
- Test suites

**stack.yaml**: Stack resolver configuration
- GHC version
- Package snapshot
- Extra dependencies

### Dependencies

Core libraries (from `package.yaml`):

```yaml
dependencies:
  - base >= 4.7 && < 5
  - megaparsec          # Parsing
  - containers          # Map, Set
  - haskeline           # REPL
  - process             # External commands
  - mtl                 # Monad transformers
  - bytestring          # Binary data
  - filepath            # Path manipulation
```

Test dependencies:
```yaml
  - hspec               # Testing framework
```

---

## Debugging

### GHCi REPL

```bash
# Start GHCi with project loaded
stack ghci

# Load specific module
:load src/Parser.hs

# Type checking
:type parseSExpr
:info SExpr

# Reload after changes
:reload
```

### Debugging Techniques

1. **Trace Debugging**:
   ```haskell
   import Debug.Trace
   
   myFunction x = trace ("x = " ++ show x) (x + 1)
   ```

2. **Print Debugging in IO**:
   ```haskell
   do
       putStrLn $ "Debug: " ++ show value
       -- continue
   ```

3. **Bytecode Disassembly**:
   ```bash
   ./glados -d bytecode.bc  # Disassemble bytecode
   ```

4. **VM State Inspection**: Modify `VM.hs` to print state after each instruction

---

## Performance Considerations

### Profiling

```bash
# Build with profiling
stack build --profile

# Run with profiling
stack exec -- glados +RTS -p

# View profile
cat glados.prof
```

### Optimization Tips

1. **Use strict data structures** for large maps/lists
2. **Avoid repeated string concatenation** - use `Builder`
3. **Lazy vs Strict evaluation** - understand when each is appropriate
4. **Tail recursion** - ensure recursive functions are tail-recursive

---

## Future Roadmap

### Version 1.0
- [ ] Complete LLVM backend
- [ ] Full type inference
- [ ] Standard library
- [ ] Comprehensive test coverage (>80%)

### Version 2.0
- [ ] Package/module system
- [ ] Garbage collection
- [ ] Optimizing compiler
- [ ] IDE integration (LSP)

### Long Term
- [ ] JIT compilation
- [ ] Native code generation
- [ ] Concurrent execution
- [ ] Self-hosting compiler

---

## Getting Help

- **Issues**: Open an issue on GitHub
- **Documentation**: Check [docs/](.) directory
- **Examples**: See [examples/](../examples/) directory
- **Code Style**: [coding_style/TSL-style.md](../coding_style/TSL-style.md)

## License

BSD-3-Clause - See [LICENSE](../LICENSE)
