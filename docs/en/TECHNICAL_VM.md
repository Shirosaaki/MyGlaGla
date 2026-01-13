# Virtual Machine - Technical Documentation

## Table of Contents

- [Overview](#overview)
- [VM Architecture](#vm-architecture)
- [Bytecode Format](#bytecode-format)
- [Instruction Set](#instruction-set)
- [Execution Model](#execution-model)
- [Memory Management](#memory-management)
- [Call Stack and Functions](#call-stack-and-functions)
- [Implementation Details](#implementation-details)
- [Performance Considerations](#performance-considerations)

---

## Overview

The GLaDOS Virtual Machine (VM) is a stack-based interpreter designed to execute compiled bytecode from the TheShowLang (TSL) compiler. It provides an efficient execution environment with support for:

- **Basic arithmetic and comparison operations**
- **Control flow with conditional and unconditional jumps**
- **Function calls with closures and captured environments**
- **Local and global variable management**
- **String and constant handling**
- **Output operations (PRINT)**

The VM is implemented in Haskell and is tightly integrated with the bytecode compiler backend.

### Key Design Principles

1. **Stack-Based Architecture**: All operations use a stack for operand passing
2. **Simple Instruction Set**: Minimal, orthogonal set of instructions
3. **Closure Support**: First-class functions with lexical scoping
4. **Type Safety**: Haskell's type system ensures memory safety

---

## VM Architecture

### Core Components

#### 1. VMValue Type

Represents runtime values in the VM:

```haskell
data VMValue
  = VMInt Int32              -- 32-bit signed integers
  | VMBool Bool              -- Boolean values (#t, #f)
  | VMString String          -- String literals
  | VMClosure Int32 Int32 [VMValue]  -- Closures with captured environment
  | VMVoid                   -- Unit/void value
  deriving (Show, Eq)
```

#### 2. CallFrame Structure

Manages function call context:

```haskell
data CallFrame = CallFrame
  { returnAddress :: Int
  , savedLocals   :: [VMValue]
  } deriving (Show)
```

Each call frame stores:
- **returnAddress**: Program counter to resume after function returns
- **savedLocals**: Local variable state before the call

#### 3. VMState Type

Complete execution state:

```haskell
data VMState = VMState
  { stack     :: [VMValue]              -- Operand stack
  , pc        :: Int                    -- Program counter
  , callStack :: [CallFrame]            -- Call frames for function returns
  , globals   :: Map.Map String VMValue -- Global variables
  , locals    :: [VMValue]              -- Local variables (current frame)
  , program   :: [Instruction]          -- Bytecode instructions
  , halted    :: Bool                   -- Execution halted flag
  , outputs   :: [String]               -- Accumulated output
  } deriving (Show)
```

---

## Bytecode Format

### Binary Format Structure

Bytecode files (`.o` extension) use the following structure:

```
┌─────────────────────────────────────────┐
│ Magic Number: "GLO\0" (4 bytes)         │
├─────────────────────────────────────────┤
│ Version: 0x01 (1 byte)                  │
├─────────────────────────────────────────┤
│ Instructions (variable length)          │
│   [Opcode] [Operands] [Opcode] ...      │
├─────────────────────────────────────────┤
│ HALT (0xFF) instruction at end          │
└─────────────────────────────────────────┘
```

### Instruction Encoding

Each instruction starts with a one-byte opcode followed by zero or more operands:

- **Zero-operand instructions**: 1 byte (e.g., ADD, POP)
- **Int32 operands**: 4 bytes in little-endian format (e.g., PUSH, JUMP)
- **String operands**: 4-byte length prefix + string data (e.g., LOAD_GLOBAL)

### ELF File Loading

For ELF files, the VM extracts the `.text` section:

1. Validates ELF magic number (0x7F 0x45 0x4C 0x46)
2. Locates section headers
3. Extracts `.text` section containing bytecode
4. Decodes instructions from extracted section

---

## Instruction Set

### Complete Instruction Reference

| Opcode | Instruction       | Operands | Stack Effect | Description |
|--------|-------------------|----------|--------------|-------------|
| 0x01   | PUSH              | Int32    | → [n]        | Push integer constant |
| 0x02   | POP               | none     | [v] →        | Discard top of stack |
| 0x03   | ADD               | none     | [b,a] → [a+b]| Add two integers |
| 0x04   | SUB               | none     | [b,a] → [a-b]| Subtract integers |
| 0x05   | MUL               | none     | [b,a] → [a*b]| Multiply integers |
| 0x06   | DIV               | none     | [b,a] → [a/b]| Integer division (b≠0) |
| 0x07   | MOD               | none     | [b,a] → [a%b]| Modulo operation (b≠0) |
| 0x08   | LT                | none     | [b,a] → [a<b]| Less than comparison |
| 0x09   | EQ                | none     | [b,a] → [a==b]| Equality comparison |
| 0x0A   | JUMP              | Int32    | (pc)         | Unconditional jump to address |
| 0x0B   | JUMP_IF_FALSE     | Int32    | [v] →        | Jump if top is #f |
| 0x0C   | CALL              | Int32    | (stack)      | Call function at address |
| 0x0D   | RET               | none     | [v] → v      | Return from function |
| 0x0E   | LOAD_VAR          | Int32    | → [v]        | Load local variable |
| 0x0F   | STORE_VAR         | Int32    | [v] →        | Store to local variable |
| 0x10   | LOAD_GLOBAL       | String   | → [v]        | Load global variable |
| 0x11   | STORE_GLOBAL      | String   | [v] →        | Store global variable |
| 0x12   | MAKE_CLOSURE      | Int32 Int32 | → [closure] | Create closure with captured env |
| 0x13   | PUSH_TRUE         | none     | → [#t]       | Push boolean true |
| 0x14   | PUSH_FALSE        | none     | → [#f]       | Push boolean false |
| 0x15   | PRINT             | none     | [v] →        | Print value and store output |
| 0x16   | LOAD_CONST        | String   | → [s]        | Load string constant |
| 0xFF   | HALT              | none     | (halts)      | Stop execution |

### Type Constraints

The VM enforces type correctness on operations:

- **Arithmetic operations (ADD, SUB, MUL, DIV, MOD)**: Both operands must be `VMInt`
- **Comparisons (LT, EQ)**: Operands must be compatible types
- **Conditional jumps (JUMP_IF_FALSE)**: Operand must be `VMBool`
- **Type errors** result in `Left String` error with description

---

## Execution Model

### Stack-Based Operation

The VM operates on a LIFO (Last In, First Out) stack. Most operations pop operands from the top and push results back:

```
Example: Computing (2 + 3) * 4

Initial:        []
PUSH 2:         [2]
PUSH 3:         [2, 3]
ADD:            [5]
PUSH 4:         [5, 4]
MUL:            [20]
```

### Program Counter and Sequencing

Instructions execute sequentially unless a control flow instruction is encountered:

- **Normal flow**: PC increments by instruction size
- **JUMP addr**: PC set directly to `addr`
- **JUMP_IF_FALSE addr**: Conditional branch based on top of stack
- **CALL addr**: Jump with call frame pushed
- **RET**: Pop call frame and jump to return address

### Execution Loop

```haskell
execBytecode :: VMState -> (Either String VMValue, [String])
execBytecode state
  | halted state = getResult state
  | pc out of bounds = error "PC out of bounds"
  | otherwise = case step state (program !! pc) of
      Left err      → return error
      Right newState → execBytecode newState
```

The execution continues until:
1. `HALT` instruction is executed
2. An error occurs
3. Program counter goes out of bounds

### Step Function

The `step` function implements each instruction:

```haskell
step :: VMState → Instruction → Either String VMState
```

Returns:
- **Left msg**: Error condition
- **Right state**: Updated VM state ready for next instruction

---

## Memory Management

### Stack

The operand stack stores `VMValue` items:
- Grows/shrinks dynamically as values are pushed/popped
- Stack underflow on POP/arithmetic operations returns error
- No fixed size limit

### Local Variables

Local variables are stored in a list indexed by variable ID:

```haskell
LOAD_VAR 0    -- Load first local variable
STORE_VAR 1   -- Store to second local variable
```

Access is bounds-checked; invalid indices produce errors.

### Global Variables

Global variables use a `Map.Map String VMValue` for name-based lookup:

```haskell
LOAD_GLOBAL "x"    -- Load global variable "x"
STORE_GLOBAL "y"   -- Store to global "y"
```

Undefined global reads produce "Undefined global variable" error.

### Constant Pool

String constants use `LOAD_CONST` instruction:

```haskell
LOAD_CONST "Hello, World!"
PRINT
```

### Memory Layout Example

```
Frame 1 (outer function)
├─ locals = [100, "hello"]
├─ callStack = []
└─ stack = [42]

Frame 2 (after function call)
├─ locals = [10, 20, 30]      (new frame's locals)
├─ callStack = [CallFrame {returnAddress: 50, savedLocals: [100, "hello"]}]
└─ stack = [42, ...]
```

---

## Call Stack and Functions

### Function Call Mechanism

#### CALL Instruction

```haskell
CALL addr  -- Call function at address addr
```

Execution:
1. Create `CallFrame` with current PC+1 (return address) and current locals
2. Push frame onto `callStack`
3. Set PC to `addr`
4. Continue execution

#### RET Instruction

```haskell
RET  -- Return from function
```

Execution:
1. Pop top call frame
2. Restore return address from frame
3. Restore locals from frame
4. Set PC to return address
5. Keep return value on stack

### Closure Support

#### MAKE_CLOSURE Instruction

Creates a closure with captured environment:

```haskell
MAKE_CLOSURE addr nparams
```

Creates `VMClosure addr nparams capturedEnv` where:
- **addr**: Bytecode address of function code
- **nparams**: Number of parameters
- **capturedEnv**: Current local variables (lexical scope)

#### Closure Call

When calling a closure:
1. Arguments are taken from stack
2. New local variables = arguments + captured environment
3. Function executes with combined locals
4. Return pops frame and restores caller's locals

### Example: Closure with Captured Variables

```
PUSH 100           -- outer value
STORE_VAR 0        -- locals = [100]
PUSH 5             -- nparams
PUSH 10            -- function address
MAKE_CLOSURE       -- capture locals = [100]
                   -- stack = [VMClosure(10, 5, [VMInt 100])]

CALL addr          -- call closure
                   -- new locals = [args...] + [100]
                   -- can access captured 100
```

---

## Implementation Details

### Error Handling

The VM uses `Either String` for error propagation:

```haskell
step :: VMState → Instruction → Either String VMState
```

Common error cases:
- **Stack underflow**: Not enough operands
- **Type error**: Wrong operand types for operation
- **Division by zero**: DIV/MOD with zero divisor
- **Out of bounds**: Jump/variable access outside bounds
- **Undefined variable**: Global variable doesn't exist

### Output Handling

The PRINT instruction accumulates output:

```haskell
outputs :: [String]  -- accumulated output strings
```

Output is preserved throughout execution and returned as second element of result tuple:

```haskell
runVM :: [Instruction] → (Either String VMValue, [String])
```

### Instruction Decoding

Binary bytecode decoding:

```haskell
decodeProgram :: ByteString → Either String [Instruction]
decodeProgram bs = go bs []
  where
    go b acc
      | null b = Right (reverse acc)
      | otherwise = case decodeOpcode (first byte) of
          Just decoder → decoder rest
          Nothing → Left "Unknown opcode"
```

Each instruction decoder:
- Takes remaining `ByteString`
- Parses opcode-specific operands
- Returns `(Instruction, remainingBytes)` or error

### String Encoding

Strings use length-prefixed format:

```
[Length: 4 bytes LE] [UTF-8 string data]

Example: "Hi" → 02 00 00 00 48 69
         ^length  ^"H"  ^"i"
```

### Int32 Encoding

All integer operands use 32-bit little-endian:

```
1234 → 0xD2 0x04 0x00 0x00  (in memory/file)
```

---

## Performance Considerations

### Optimization Opportunities

1. **Instruction Caching**: Pre-parse instructions to avoid repeated decoding
2. **Bytecode Optimization**:
   - Constant folding
   - Dead code elimination
   - Jump target inlining
3. **Stack Machine Optimizations**:
   - Register allocation for frequently used values
   - Stack frame pooling
4. **JIT Compilation**: Compile hot code paths to native

### Current Limitations

- **No tail call optimization**: Recursive functions may overflow call stack
- **Linear search for instructions**: No instruction cache
- **String copying**: All string operations involve memory copies
- **No garbage collection**: Closures retain captured environment

### Benchmarking

Typical performance metrics:
- Simple arithmetic: ~10-100 μs
- Function call overhead: ~1 μs per frame
- PRINT operation: ~10 μs per call

---

## Integration with Compiler

### Bytecode Generation Flow

```
TSL Source
    ↓
Parser (Theshow/Lisp syntax)
    ↓
AST (Abstract Syntax Tree)
    ↓
Compiler (AST → Instructions)
    ↓
Bytecode.hs (serialize to binary)
    ↓
.o file (bytecode)
    ↓
VM.hs (execBytecode)
    ↓
Result + Output
```

### Compilation to Bytecode

The compiler translates AST nodes to instructions:

```haskell
-- Example: (+ 2 3) compiles to:
PUSH 2
PUSH 3
ADD
```

---

## Debugging and Troubleshooting

### Runtime Error Messages

The VM provides detailed error messages:

```
"Stack underflow on POP"
"Type error in ADD"
"Division by zero"
"Jump address out of bounds"
"Undefined global variable: x"
```

### Bytecode Disassembly

The Loader module provides disassembly:

```bash
glados -d program.o
```

Produces human-readable bytecode format.

### Testing

Unit tests for VM operations in `test/Spec.hs`:
- Arithmetic operations
- Control flow
- Function calls
- Variable management
- Closure handling

---

## Future Extensions

1. **Type annotations in bytecode**: Better error messages
2. **Garbage collection**: For closure environments
3. **Module system**: Multiple bytecode files
4. **Debugger**: Step execution, breakpoints
5. **Memory profiling**: Track allocation patterns

---

## References

- [Bytecode Module](../src/Bytecode.hs)
- [VM Module](../src/VM.hs)
- [Loader Module](../src/Loader.hs)
- [Main Application](../app/Main.hs)
