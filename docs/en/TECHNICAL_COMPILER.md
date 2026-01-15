# Compiler - Technical Documentation

## Table of Contents

- [Overview](#overview)
- [Compiler Architecture](#compiler-architecture)
- [Compilation Pipeline](#compilation-pipeline)
- [Abstract Syntax Tree (AST)](#abstract-syntax-tree-ast)
- [Type System](#type-system)
- [Parser Integration](#parser-integration)
- [Code Analysis & Optimization](#code-analysis--optimization)
- [Code Generation Backends](#code-generation-backends)
- [Memory Management](#memory-management)
- [Built-in Functions](#built-in-functions)
- [Error Handling](#error-handling)
- [Usage Examples](#usage-examples)
- [Performance Considerations](#performance-considerations)

---

## Overview

The GLaDOS Compiler is a multi-backend compiler for the TheShowLang (TSL) programming language. It transforms source code written in TSL into executable code through multiple compilation targets:

- **Bytecode Target**: Generates bytecode for the GLaDOS Virtual Machine
- **x86-64 Assembly**: Native code generation for Linux systems
- **LLVM IR** (planned): For advanced optimizations

The compiler is implemented in Haskell and provides strong type safety, comprehensive error reporting, and multiple optimization passes.

### Key Features

1. **Multi-Target Compilation**: Support for VM bytecode and native x86-64 assembly
2. **Type Inference**: Automatic type deduction for variables and expressions
3. **Optimization Passes**: Constant folding, dead code elimination, global constant inlining
4. **Closure Support**: First-class functions with lexical scoping
5. **Rich Type System**: Integers, floats, strings, booleans, arrays, structs
6. **Detailed Error Messages**: Precise error reporting with variable/function names

---

## Compiler Architecture

### Core Modules

```
┌─────────────────────────────────────────────────┐
│                  Source Code                    │
│              (TheShow/Lisp Syntax)              │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────┐
│              Parser (Parser.hs)                 │
│  - Theshow.Parser (default)                     │
│  - Lisp.Parser (alternative)                    │
└────────────────────┬────────────────────────────┘
                     │
                     ▼ produces SExpr
┌─────────────────────────────────────────────────┐
│           SExpr → AST (AST.hs)                  │
│  - sexprToAST function                          │
│  - Converts S-expressions to typed AST          │
└────────────────────┬────────────────────────────┘
                     │
                     ▼ produces Ast
┌─────────────────────────────────────────────────┐
│          Compiler Analysis (Compiler.hs)        │
│  - collectVarTypes                              │
│  - collectFunctionNames                         │
│  - collectGlobalConsts                          │
│  - inlineGlobalConsts                           │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
          ┌──────────┴──────────┐
          │                     │
          ▼                     ▼
┌──────────────────┐  ┌──────────────────┐
│  Bytecode Gen    │  │  x86-64 ASM Gen  │
│ (Bytecode.hs)    │  │  (Compiler.hs)   │
│                  │  │                  │
│ .o bytecode file │  │  .o object file  │
└──────────────────┘  └──────────────────┘
          │                     │
          ▼                     ▼
┌──────────────────┐  ┌──────────────────┐
│  VM Execution    │  │  Native Exec     │
│    (VM.hs)       │  │  (via linker)    │
└──────────────────┘  └──────────────────┘
```

### Module Responsibilities

| Module | Purpose |
|--------|---------|
| **Parser.hs** | Selects between TheShow and Lisp parsers, converts source to SExpr |
| **Theshow.Parser** | Parses TheShow syntax (default) |
| **Lisp.Parser** | Parses Lisp S-expression syntax |
| **AST.hs** | Defines AST types, converts SExpr to Ast, contains evaluator |
| **Compiler.hs** | Main compilation logic, analysis, bytecode/assembly generation |
| **Bytecode.hs** | Bytecode instruction definitions and serialization |
| **VM.hs** | Bytecode execution engine |
| **Loader.hs** | Loads and decodes bytecode files, saves bytecode |

---

## Compilation Pipeline

### Complete Compilation Flow

```
1. Source File (.tslang)
        ↓
2. Parser Selection (TheShow/Lisp)
        ↓
3. Lexical Analysis → Tokens
        ↓
4. Syntactic Analysis → SExpr
        ↓
5. Semantic Analysis → AST
        ↓
6. Type Collection & Inference
        ↓
7. Optimization Passes
   - Global constant inlining
   - Dead code elimination
   - Constant folding
        ↓
8. Code Generation
   ├─→ Bytecode (.o for VM)
   └─→ Assembly (.s → .o for native)
        ↓
9. Output
   ├─→ VM Execution
   └─→ Linking & Native Execution
```

### Compilation Phases

#### Phase 1: Parsing

**Input**: Source code string  
**Output**: `[SExpr]` (S-expression list)

```haskell
-- Parser.hs - Runtime parser selection
parseSExprMultipleEither :: String -> Either String [SExpr]
```

The parser converts raw source code into S-expressions. Two parsers are available:

- **TheShow Parser** (default): Custom syntax for TSL
- **Lisp Parser**: Traditional Lisp S-expression syntax

Example:
```
Source:   fun add(x: int, y: int) int { return x + y }
SExpr:    (fun add ((x int) (y int)) int ((return (+ x y))))
```

#### Phase 2: AST Construction

**Input**: `[SExpr]`  
**Output**: `Ast`

```haskell
-- AST.hs
sexprToAST :: SExpr -> Either String Ast
```

Converts S-expressions to a strongly-typed Abstract Syntax Tree:

- Validates syntax structure
- Constructs AST nodes with proper types
- Reports syntax errors with context

Example:
```haskell
SExpr: (fun "add" [(x int) (y int)] int [(return (+ x y))])
AST:   Define "add" Nothing 
         (AstLambda ["x", "y"] 
           (Block [Return (Call (AstSymbol "+") [AstSymbol "x", AstSymbol "y"])]))
```

#### Phase 3: Type Analysis

**Input**: `Ast`  
**Output**: `Map.Map String Type` (variable type map)

```haskell
collectVarTypes :: Ast -> Map.Map String Type -> Map.Map String Type
```

Analyzes the AST to collect type information:

- Explicit type declarations from `Define` nodes
- Type inference from assignments and expressions
- Special handling for arrays, strings, and structs

Example:
```haskell
AST:  Define "x" (Just TInt) (AstInt 42)
      Define "name" Nothing (AstString "Alice")
      
Types: {"x" -> TInt, "name" -> TString}
```

#### Phase 4: Optimization

Multiple optimization passes transform the AST:

**Global Constant Inlining**:
```haskell
collectGlobalConsts :: Ast -> Map.Map String Ast
inlineGlobalConsts :: Map.Map String Ast -> Ast -> Ast
```

Replaces references to compile-time constant globals with their values:

```
Before: eric PI: float = 3.14159
        eric area: float = PI * r * r

After:  eric area: float = 3.14159 * r * r
```

**Variable Shadowing**: Properly handles scope with lexical shadowing in functions and loops.

#### Phase 5: Code Generation

Two backends generate different output formats:

**Bytecode Backend**:
```haskell
astToInstructions :: Ast -> [Instruction]
compileToBytecodeFile :: FilePath -> Ast -> IO ()
```

**Assembly Backend**:
```haskell
emitASM :: Ast -> String
compileToObject :: FilePath -> Ast -> IO ()
```

---

## Abstract Syntax Tree (AST)

### AST Node Types

The `Ast` data type represents all language constructs:

```haskell
data Ast
  -- Definitions and Variables
  = Define String (Maybe Type) Ast          -- Variable/function definition
  | AstSymbol String                         -- Variable reference
  | Assign String Ast                        -- Variable assignment
  
  -- Literals
  | AstInt Int                              -- Integer literal
  | AstFloat Double                          -- Float literal
  | AstBool Bool                            -- Boolean literal
  | AstString String                         -- String literal
  | AstChar Char                            -- Character literal
  | AstVoid                                 -- Void/unit value
  
  -- Functions and Closures
  | AstLambda [String] Ast                  -- Lambda/function (params, body)
  | AstClosure [String] Ast Env             -- Closure with captured environment
  | Call Ast [Ast]                          -- Function call
  | Return Ast                              -- Return statement
  
  -- Control Flow
  | IfElse Ast Ast Ast                      -- if-then-else
  | While Ast Ast                           -- while loop
  | For String Ast Ast                      -- for loop (var, range, body)
  | Break                                   -- Break statement
  | Continue                                -- Continue statement
  
  -- Collections
  | AstList [Ast]                           -- List of expressions
  | Block [Ast]                             -- Statement block
  | ArrayAccess Ast Ast                     -- array[index]
  | ArrayAssign String Ast Ast              -- array[index] = value
  
  -- Structures
  | Struct String [(String, Type)]          -- Struct definition
  | StructFieldAssign String String Ast     -- struct.field = value
  | TypedVar String Type Ast                -- Typed variable declaration
  
  deriving (Show, Eq)
```

### AST Construction Examples

#### Simple Expression
```
Source:  42
SExpr:   (SInt 42)
AST:     AstInt 42
```

#### Function Call
```
Source:  peric(x + 10)
SExpr:   (call peric (+ x (SInt 10)))
AST:     Call (AstSymbol "peric") 
           [Call (AstSymbol "+") [AstSymbol "x", AstInt 10]]
```

#### Function Definition
```
Source:  fun factorial(n: int) int {
           if n <= 1 { return 1 }
           return n * factorial(n - 1)
         }
         
AST:     Define "factorial" Nothing
           (AstLambda ["n"]
             (Block [
               IfElse (Call (AstSymbol "<=") [AstSymbol "n", AstInt 1])
                 (Block [Return (AstInt 1)])
                 (Block []),
               Return (Call (AstSymbol "*") [
                 AstSymbol "n",
                 Call (AstSymbol "factorial") [
                   Call (AstSymbol "-") [AstSymbol "n", AstInt 1]
                 ]
               ])
             ]))
```

### S-Expression Format

S-expressions are the intermediate representation between source and AST:

```haskell
data SExpr
  = SInt Int
  | SFloat Double
  | SBool Bool
  | SString String
  | SChar Char
  | SSymbol String
  | SList [SExpr]
  deriving (Show, Eq)
```

### Key AST Patterns

#### Variable Declaration
```haskell
-- eric name: type = value
Define "name" (Just type) value
```

#### Function Definition
```haskell
-- fun name(params) returnType { body }
Define "name" Nothing (AstLambda params body)
```

#### Control Structures
```haskell
-- if condition { then } else { otherwise }
IfElse condition thenBlock elseBlock

-- while condition { body }
While condition body

-- for var in range { body }
For "var" rangeExpr body
```

---

## Type System

### Type Definitions

```haskell
data Type
  = TInt              -- 32-bit signed integer
  | TFloat            -- Double-precision float
  | TBool             -- Boolean (true/false)
  | TString           -- String (null-terminated)
  | TChar             -- Single character
  | TVoid             -- Void/unit type
  | TCustom String    -- Custom types (arrays, structs)
  deriving (Show, Eq)
```

### Type Inference Rules

The compiler infers types based on:

1. **Explicit Declarations**:
   ```
   eric x: int = 42         → x: TInt
   eric name: string = ""   → name: TString
   ```

2. **Literal Types**:
   ```
   42       → TInt
   3.14     → TFloat
   "hello"  → TString
   'c'      → TChar
   true     → TBool
   ```

3. **Expression Types**:
   ```
   x + y    → TInt (if both x, y are TInt)
   x + "!"  → TString (if either is TString)
   x < y    → TBool
   ```

4. **Function Return Types**:
   ```
   fun add(x: int, y: int) int { return x + y }
   → add: (int, int) -> int
   ```

5. **Assignment Inference**:
   ```
   assign x (renaud "file.txt")  → x: TString
   assign arr (array-type int)   → arr: TCustom "int[]"
   ```

### Type Checking

Type errors are detected during compilation:

```haskell
-- Valid:
eric x: int = 42
assign x 100

-- Error: Type mismatch
eric x: int = 42
assign x "string"  -- Compilation error
```

### Array Types

Arrays use custom type notation:

```haskell
-- Array declaration
eric numbers: int[] = ...  → TCustom "int[]"

-- Array access type rules
numbers[0]    → TInt
string[0]     → TChar
```

### String Handling

Strings are special-cased for concatenation and interpolation:

```haskell
-- String concatenation via + operator
"hello" + " world"  → TString

-- Type-aware formatting
"Number: " + x      → TString (converts x to string)
```

---

## Parser Integration

### Parser Selection

The compiler supports two parsers via runtime flag:

```haskell
-- Parser.hs
setUseLisp :: Bool -> IO ()

-- Default: TheShow Parser
parseSExprMultipleEither :: String -> Either String [SExpr]

-- Using Lisp Parser
setUseLisp True
parseSExprMultipleEither :: String -> Either String [SExpr]
```

### TheShow Syntax (Default)

TheShow provides C-like syntax:

```c
// Variable declaration
eric x: int = 42

// Function definition
fun add(x: int, y: int) int {
  return x + y
}

// Control structures
if x < 10 {
  peric("Small")
} else {
  peric("Large")
}

// Loops
for i in range(0, 10) {
  peric(i)
}

while x > 0 {
  assign x (x - 1)
}
```

### Lisp Syntax (Alternative)

Traditional S-expression syntax:

```lisp
; Variable declaration
(eric x int 42)

; Function definition
(fun add ((x int) (y int)) int
  ((return (+ x y))))

; Control structures
(if (< x 10)
  ((peric "Small"))
  ((peric "Large")))

; Loops
(aer i (range 0 10)
  ((peric i)))

(darius (> x 0)
  ((assign x (- x 1))))
```

### Parser Output: S-Expressions

Both parsers produce the same S-expression format:

```haskell
-- Input (TheShow):  fun add(x: int, y: int) int { return x + y }
-- Input (Lisp):     (fun add ((x int) (y int)) int ((return (+ x y))))
-- Output:
SList [
  SSymbol "fun",
  SSymbol "add",
  SList [SList [SSymbol "x", SSymbol "int"],
         SList [SSymbol "y", SSymbol "int"]],
  SSymbol "int",
  SList [SList [SSymbol "return",
                SList [SSymbol "+", SSymbol "x", SSymbol "y"]]]
]
```

---

## Code Analysis & Optimization

### Variable Type Collection

```haskell
collectVarTypes :: Ast -> Map.Map String Type -> Map.Map String Type
```

Traverses the AST to build a complete type map:

**Process**:
1. Scan all `Define` nodes for explicit type annotations
2. Infer types from assignments and expressions
3. Handle special cases (built-in functions, array types)
4. Recursively analyze function bodies

**Example**:
```haskell
Input AST:
  Block [
    Define "x" (Just TInt) (AstInt 10),
    Assign "result" (Call (AstSymbol "renaud") [AstString "data.txt"]),
    For "i" range body
  ]

Output Types:
  Map.fromList [
    ("x", TInt),
    ("result", TString),  -- inferred from renaud
    ("i", TInt)            -- inferred from for loop
  ]
```

### Function Name Collection

```haskell
collectFunctionNames :: Ast -> [String]
```

Extracts all function definitions for call validation:

```haskell
Input:
  Block [
    Define "factorial" Nothing (AstLambda ...),
    Define "fib" Nothing (AstLambda ...),
    Define "x" (Just TInt) (AstInt 42)
  ]

Output: ["factorial", "fib"]
```

### Local Variable Mapping

```haskell
buildLocalMap :: Ast -> Map.Map String Type -> Map.Map String Int
```

Creates stack offset map for local variables:

**Algorithm**:
1. Collect all local variable names
2. Calculate required size for each variable:
   - Regular variables: 8 bytes
   - Arrays: 4096 bytes (default)
   - Special cases (e.g., "memo"): custom size
3. Assign stack offsets from RBP

**Example**:
```haskell
Local variables: ["x", "y", "buffer"]
Types: {"x" -> TInt, "y" -> TInt, "buffer" -> TCustom "int[]"}

Local map:
  {"x" -> 8, "y" -> 16, "buffer" -> 4112}
  
Stack layout:
  RBP - 8:    x
  RBP - 16:   y
  RBP - 4112: buffer (array, 4096 bytes)
```

### Global Constant Inlining

**Collection Phase**:
```haskell
collectGlobalConsts :: Ast -> Map.Map String Ast
```

Identifies compile-time constants:
- Integer literals
- Character literals
- Boolean literals

**Inlining Phase**:
```haskell
inlineGlobalConsts :: Map.Map String Ast -> Ast -> Ast
```

Replaces variable references with literal values:

```haskell
-- Before optimization
Define "PI" Nothing (AstFloat 3.14159)
Define "TWO_PI" Nothing (Call (AstSymbol "*") [AstInt 2, AstSymbol "PI"])
Call (AstSymbol "calculate") [AstSymbol "TWO_PI"]

-- After optimization
Define "PI" Nothing (AstFloat 3.14159)
Define "TWO_PI" Nothing (Call (AstSymbol "*") [AstInt 2, AstFloat 3.14159])
Call (AstSymbol "calculate") [Call (AstSymbol "*") [AstInt 2, AstFloat 3.14159]]
```

**Scope Handling**: The inliner respects lexical scope and variable shadowing:

```haskell
-- Global constant
Define "x" Nothing (AstInt 10)

-- Function that shadows x
Define "foo" Nothing (AstLambda ["x"] 
  (Call (AstSymbol "peric") [AstSymbol "x"]))

-- x inside foo is NOT inlined (parameter shadows global)
```

### String Collection

```haskell
collectStrings :: Ast -> Map.Map String Type -> [String]
```

Extracts all string literals for data section:

```haskell
Input:
  Block [
    AstString "Hello",
    Call (AstSymbol "peric") [AstString "World"],
    Call (AstSymbol "renaud") [AstString "file.txt"]
  ]

Output: ["Hello", "World", "file.txt"]
```

---

## Code Generation Backends

### Bytecode Backend

Generates bytecode for the GLaDOS Virtual Machine.

#### Instruction Generation

```haskell
astToInstructions :: Ast -> [Instruction]
```

**Compilation Rules**:

| AST Node | Bytecode |
|----------|----------|
| `AstInt n` | `PUSH n` |
| `AstBool True` | `PUSH_TRUE` |
| `AstBool False` | `PUSH_FALSE` |
| `AstString s` | `LOAD_CONST s` |
| `AstSymbol v` | `LOAD_VAR idx` or `LOAD_GLOBAL v` |
| `Assign n v` | `[v code] STORE_VAR idx` or `STORE_GLOBAL n` |
| `Call (AstSymbol "+") [a,b]` | `[a code] [b code] ADD` |
| `Call (AstSymbol "-") [a,b]` | `[a code] [b code] SUB` |
| `Call (AstSymbol "*") [a,b]` | `[a code] [b code] MUL` |
| `Call (AstSymbol "/") [a,b]` | `[a code] [b code] DIV` |
| `Call (AstSymbol "<") [a,b]` | `[a code] [b code] LT` |
| `Call (AstSymbol "==") [a,b]` | `[a code] [b code] EQ` |
| `IfElse c t e` | `[c code] JUMP_IF_FALSE L1 [t code] JUMP L2 L1: [e code] L2:` |
| `Return v` | `[v code] RET` |
| `Block xs` | `[concat all xs code]` |

#### Bytecode Example

```
Source:
  fun add(x: int, y: int) int {
    return x + y
  }

Bytecode:
  add:
    LOAD_VAR 0      ; load x
    LOAD_VAR 1      ; load y
    ADD             ; x + y
    RET             ; return result
    
  main:
    PUSH 5
    PUSH 7
    CALL add
    PRINT
    HALT
```

#### File Generation

```haskell
compileToBytecodeFile :: FilePath -> Ast -> IO ()
```

Creates `.o` bytecode file:
1. Convert AST to instructions
2. Append `HALT` instruction
3. Serialize to binary format (see VM documentation)
4. Write to file

**Binary Format**:
```
[Magic: "GLO\0"] [Version: 0x01] [Instructions...] [HALT]
```

### x86-64 Assembly Backend

Generates native x86-64 assembly for Linux systems.

#### Assembly Generation Pipeline

```haskell
emitASM :: Ast -> String
```

**Process**:
1. **Optimization**: Inline global constants
2. **Analysis**: Collect types, functions, strings
3. **Data Section**: Emit string constants
4. **Text Section**: Emit functions and main
5. **Built-ins**: Append built-in function implementations

#### Data Section

String literals are emitted as global labels:

```asm
.globl LC0
LC0: .string "Hello, World!"

.globl LC1
LC1: .string "Enter a number: "
```

#### Function Prologue/Epilogue

**Function Structure**:
```asm
function_name:
    pushq %rbp                  ; Save frame pointer
    movq %rsp, %rbp            ; Setup new frame
    subq $SIZE, %rsp           ; Allocate stack space
    
    ; [Parameter setup]
    ; [Function body]
    
.Lret_function_name:
    leave                       ; Restore stack
    ret                         ; Return to caller
```

**Stack Frame Calculation**:
```haskell
-- Calculate maximum offset
maxOffset = maximum (Map.elems localMap)

-- Align to 16 bytes (System V ABI requirement)
allocSize = ((maxOffset + 31) `div` 16) * 16
```

#### Register Usage

**Parameter Passing** (System V AMD64 ABI):
- 1st parameter: `%rdi`
- 2nd parameter: `%rsi`
- 3rd parameter: `%rdx`
- 4th parameter: `%rcx`
- 5th parameter: `%r8`
- 6th parameter: `%r9`
- Additional parameters: stack

**Return Value**: `%rax`

**Scratch Registers**: `%rax`, `%rcx`, `%rdx`, `%r8-r11`

**Preserved Registers**: `%rbx`, `%rbp`, `%r12-r15`

#### Expression Compilation

```haskell
exprToASM :: Ast -> Map.Map String Int -> [(String, Int)] 
          -> Map.Map String Type -> [String] -> [String]
```

**Integer Literal**:
```asm
; AstInt 42
movq $42, %rax
```

**Variable Load**:
```asm
; AstSymbol "x" (offset -8)
movq -8(%rbp), %rax
```

**Arithmetic Operations**:
```asm
; Call (AstSymbol "+") [x, y]
movq -8(%rbp), %rax    ; load x
pushq %rax             ; save x
movq -16(%rbp), %rax   ; load y
movq %rax, %rdx        ; y -> rdx
popq %rax              ; restore x
addq %rdx, %rax        ; x + y
```

**String Concatenation**:
```asm
; "hello" + " world"
leaq LC0(%rip), %rax    ; load "hello"
pushq %rax
leaq LC1(%rip), %rax    ; load " world"
movq %rax, %rsi
popq %rdi
call str_concat         ; built-in concat
```

**Comparison**:
```asm
; x < y
movq -8(%rbp), %rax     ; load x
pushq %rax
movq -16(%rbp), %rax    ; load y
movq %rax, %rdx
popq %rax
cmpq %rdx, %rax         ; compare
setl %al                ; set if less
movzbq %al, %rax        ; zero-extend to 64-bit
```

**Array Access**:
```asm
; arr[i] where arr is at offset -4112, i is at offset -8
movq -8(%rbp), %rax     ; load i
pushq %rax              ; save i
leaq -4112(%rbp), %rdx  ; address of arr
popq %rcx               ; restore i
movq (%rdx, %rcx, 8), %rax  ; arr[i] (8-byte elements)
```

**Function Call**:
```asm
; factorial(5)
movq $5, %rax           ; evaluate argument
pushq %rax              ; save on stack
popq %rdi               ; load to parameter register
movb $0, %al            ; no vector args
call factorial          ; call function
```

#### Statement Compilation

```haskell
stmtToASM :: Ast -> Int -> [(String, Int)] -> Map.Map String Int 
          -> String -> Maybe String -> Maybe String 
          -> Map.Map String Type -> Map.Map String Int -> [String]
          -> (Int, [String], Map.Map String Int)
```

**Variable Definition**:
```asm
; eric x: int = 42
movq $42, %rax
movq %rax, -8(%rbp)
```

**Assignment**:
```asm
; assign x (x + 1)
movq -8(%rbp), %rax    ; load x
pushq %rax
movq $1, %rax
movq %rax, %rdx
popq %rax
addq %rdx, %rax        ; x + 1
movq %rax, -8(%rbp)    ; store result
```

**If-Else**:
```asm
; if x < 10 { ... } else { ... }
movq -8(%rbp), %rax    ; load x
pushq %rax
movq $10, %rax
movq %rax, %rdx
popq %rax
cmpq %rdx, %rax        ; compare x < 10
setl %al
movzbq %al, %rax
cmpq $0, %rax
je .L_else_1           ; jump if false
    ; [then block code]
    jmp .L_end_1
.L_else_1:
    ; [else block code]
.L_end_1:
```

**For Loop**:
```asm
; for i in range(0, 10) { peric(i) }
movq $0, %rax          ; start value
movq %rax, -8(%rbp)    ; initialize i
.L_s_1:                ; loop start
    movq -8(%rbp), %rax ; load i
    pushq %rax
    movq $10, %rax      ; end value
    movq %rax, %rdx
    popq %rax
    cmpq %rdx, %rax     ; i < end?
    setl %al
    movzbq %al, %rax
    cmpq $0, %rax
    je .L_e_1           ; exit if false
    
    ; [loop body]
    
.L_inc_1:              ; continue target
    movq -8(%rbp), %rax
    incq %rax           ; i++
    movq %rax, -8(%rbp)
    jmp .L_s_1
.L_e_1:                ; break target
```

**While Loop**:
```asm
; while x > 0 { assign x (x - 1) }
.L_w_s1:               ; loop start
    movq -8(%rbp), %rax ; load x
    pushq %rax
    movq $0, %rax
    movq %rax, %rdx
    popq %rax
    cmpq %rdx, %rax     ; x > 0?
    setg %al
    movzbq %al, %rax
    cmpq $0, %rax
    je .L_w_e1          ; exit if false
    
    ; [loop body]
    
    jmp .L_w_s1
.L_w_e1:               ; exit
```

#### Main Function Generation

```haskell
emitText :: Ast -> [(String, Int)] -> Map.Map String Type -> [String] -> String
```

The main function is automatically generated:

1. **Prologue**: Stack allocation
2. **Initialization**: Zero-initialize arrays
3. **Body**: Execute top-level statements
4. **Eric Call**: If `Eric` function exists and not explicitly called
5. **Epilogue**: Stack cleanup and return

```asm
.text
.globl main
main:
    pushq %rbp
    movq %rsp, %rbp
    subq $4096, %rsp       ; allocate stack
    
    ; [initialize arrays if needed]
    movq $512, %rcx        ; array size in quadwords
    xorq %rax, %rax
    leaq -4096(%rbp), %rdi
    rep stosq              ; zero-fill
    
    ; [main body statements]
    
    ; [automatic Eric() call if applicable]
    
.Lreturn:
    addq $4096, %rsp       ; deallocate
    popq %rbp
    ret
```

---

## Memory Management

### Stack Layout

The compiler uses stack-based memory management for local variables:

```
High Address
┌─────────────────┐
│  Return Address │
├─────────────────┤  ← RBP (frame pointer)
│  Previous RBP   │
├─────────────────┤
│  Local Var 1    │  RBP - 8
├─────────────────┤
│  Local Var 2    │  RBP - 16
├─────────────────┤
│  Array Buffer   │  RBP - 4112
│  (4096 bytes)   │
├─────────────────┤  ← RSP (stack pointer)
│  ...            │
Low Address
```

### Variable Storage

**Regular Variables** (8 bytes):
- Integers: 64-bit signed
- Pointers: 64-bit addresses
- Booleans: 64-bit (0 or 1)

**Arrays**:
- Default size: 4096 bytes (512 quadwords)
- Stored inline in stack frame
- Accessed via base pointer + offset

**Strings**:
- Heap-allocated via `malloc`
- Pointer stored in stack
- Managed by built-in functions

### String Memory

**String Literals**:
- Stored in `.rodata` section
- Immutable
- Referenced by address

**String Variables**:
```c
// Definition with allocation
eric message: string = "Hello"

Assembly:
  leaq LC0(%rip), %rax      ; string literal
  pushq %rax
  movq %rax, %rdi
  call strlen
  incq %rax                 ; +1 for null terminator
  movq %rax, %rdi
  call malloc               ; allocate buffer
  movq %rax, -8(%rbp)       ; store pointer
  movq -8(%rbp), %rdi
  popq %rsi
  call strcpy               ; copy string
```

**String Concatenation**:
```c
assign result (str1 + str2)

Assembly:
  ; [load str1 to %rdi]
  ; [load str2 to %rsi]
  call str_concat           ; allocates new string
  movq %rax, -8(%rbp)       ; store result pointer
```

### Array Memory

**Local Arrays**:
```c
eric numbers: int[] = ...

Assembly:
  ; Array stored at RBP - offset
  leaq -4112(%rbp), %rax    ; address of array
```

**Array Initialization**:
```asm
; Zero-initialize array
movq $512, %rcx            ; size in quadwords
xorq %rax, %rax            ; zero value
leaq -4112(%rbp), %rdi     ; destination
rep stosq                  ; repeat store
```

**Dynamic Array Allocation** (heap):
```asm
; arr[index] = (array-decl ...)
movq $512, %rdi            ; element count
movq $8, %rsi              ; element size
call calloc                ; allocate and zero
movq %rax, (%rcx, %rdx, 8) ; store pointer in arr[index]
```

### Memory Alignment

All stack allocations are 16-byte aligned per System V ABI:

```haskell
allocSize = ((maxOffset + 31) `div` 16) * 16
```

This ensures:
- Proper alignment for SIMD instructions
- ABI compliance for function calls
- Optimal cache line usage

---

## Built-in Functions

The compiler includes several built-in functions implemented in assembly.

### renaud - Read File

**Signature**: `renaud(filename: string) -> string`

**Purpose**: Read entire file contents into a string

**Implementation**:
```asm
renaud:
    pushq %rbp
    movq %rsp, %rbp
    subq $32, %rsp
    
    ; Open file
    movq %rdi, -8(%rbp)          ; save filename
    leaq .LC_r_mode(%rip), %rsi  ; "rb" mode
    call fopen
    cmpq $0, %rax
    je .L_r_err                  ; error handling
    movq %rax, -16(%rbp)         ; save file handle
    
    ; Get file size
    movq %rax, %rdi
    movq $0, %rsi
    movq $2, %rdx                ; SEEK_END
    call fseek
    movq -16(%rbp), %rdi
    call ftell
    movq %rax, -24(%rbp)         ; save size
    
    ; Rewind
    movq -16(%rbp), %rdi
    movq $0, %rsi
    movq $0, %rdx                ; SEEK_SET
    call fseek
    
    ; Allocate buffer
    movq -24(%rbp), %rdi
    incq %rdi                    ; +1 for null terminator
    call malloc
    movq %rax, -32(%rbp)         ; save buffer
    
    ; Read file
    movq %rax, %rdi
    movq $1, %rsi                ; size = 1 byte
    movq -24(%rbp), %rdx         ; count = file size
    movq -16(%rbp), %rcx         ; file handle
    call fread
    
    ; Null-terminate
    movq -32(%rbp), %rax
    movq -24(%rbp), %rdx
    movb $0, (%rax, %rdx)
    
    ; Close and return
    movq -16(%rbp), %rdi
    call fclose
    movq -32(%rbp), %rax         ; return buffer
    jmp .L_r_done
    
.L_r_err:
    xorq %rax, %rax              ; return NULL
.L_r_done:
    leave
    ret
```

### romaric - Read Line

**Signature**: `romaric(prompt: string) -> string`

**Purpose**: Display prompt and read line from stdin

**Implementation**:
```asm
romaric:
    pushq %rbp
    movq %rsp, %rbp
    subq $32, %rsp
    
    ; Initialize getline variables
    movq $0, -8(%rbp)            ; buffer = NULL
    movq $0, -16(%rbp)           ; size = 0
    
    ; Print prompt
    movq %rdi, %rsi
    leaq .LC_s_fmt(%rip), %rdi   ; "%s"
    movb $0, %al
    call printf
    
    ; Read line
    leaq -8(%rbp), %rdi          ; &buffer
    leaq -16(%rbp), %rsi         ; &size
    movq stdin(%rip), %rdx       ; stdin
    call getline
    
    ; Remove newline
    movq -8(%rbp), %rax
    pushq %rax
    movq %rax, %rdi
    call strlen
    popq %rdi
    cmpq $0, %rax
    je .L_ro_d
    decq %rax                    ; length - 1
    movb $0, (%rdi, %rax)        ; buffer[len-1] = '\0'
    
.L_ro_d:
    movq %rdi, %rax              ; return buffer
    leave
    ret
```

### marvin - Write File

**Signature**: `marvin(filename: string, content: string) -> void`

**Purpose**: Write string content to file

**Implementation**:
```asm
marvin:
    pushq %rbp
    movq %rsp, %rbp
    subq $32, %rsp
    
    ; Save parameters
    movq %rdi, -8(%rbp)          ; filename
    movq %rsi, -16(%rbp)         ; content
    
    ; Open file for writing
    movq -8(%rbp), %rdi
    leaq .LC_w_mode(%rip), %rsi  ; "w" mode
    call fopen
    movq %rax, -24(%rbp)         ; save handle
    cmpq $0, %rax
    je .L_m_done                 ; error check
    
    ; Write content
    movq -16(%rbp), %rdi         ; content
    movq %rax, %rsi              ; file handle
    call fputs
    
    ; Close file
    movq -24(%rbp), %rdi
    call fclose
    
.L_m_done:
    leave
    ret
```

### str_concat - String Concatenation

**Signature**: `str_concat(s1: string, s2: string) -> string`

**Purpose**: Concatenate two strings into newly allocated buffer

**Implementation**:
```asm
str_concat:
    pushq %rbp
    movq %rsp, %rbp
    subq $32, %rsp
    
    ; Save parameters
    movq %rdi, -8(%rbp)          ; s1
    movq %rsi, -16(%rbp)         ; s2
    
    ; Get lengths
    call strlen                   ; strlen(s1)
    movq %rax, -24(%rbp)         ; save len1
    movq -16(%rbp), %rdi
    call strlen                   ; strlen(s2)
    addq -24(%rbp), %rax         ; len1 + len2
    incq %rax                    ; +1 for null
    
    ; Allocate buffer
    movq %rax, %rdi
    call malloc
    movq %rax, -32(%rbp)         ; save buffer
    
    ; Copy first string
    movq %rax, %rdi
    movq -8(%rbp), %rsi
    call strcpy
    
    ; Concatenate second string
    movq -32(%rbp), %rdi
    movq -16(%rbp), %rsi
    call strcat
    
    ; Return buffer
    movq -32(%rbp), %rax
    leave
    ret
```

### peric - Print (Implicit)

The `peric` function uses `printf` with format string interpolation:

```c
peric("Value: ", x)

Assembly:
  ; Format string: "Value: %ld"
  leaq LC0(%rip), %rdi         ; format string
  movq -8(%rbp), %rsi          ; x value
  movb $0, %al
  call printf
```

---

## Error Handling

### Compile-Time Errors

The compiler detects and reports various errors:

#### Undefined Variable
```c
assign x 42  // Error: Undefined variable 'x'
```

Error handling:
```haskell
case Map.lookup v locals of
  Just off -> [generateCode]
  Nothing -> unsafePerformIO $ do
    printError ("Compilation Error: Undefined variable '" ++ v ++ "'")
    exitFailure
```

#### Undefined Function
```c
foo(10)  // Error: Undefined function 'foo'
```

Error handling:
```haskell
if func `notElem` fns && func `notElem` builtIns
then unsafePerformIO $ do
  printError ("Compilation Error: Undefined function '" ++ func ++ "'")
  exitFailure
else [generateCode]
```

#### Type Mismatch

Type errors are caught during code generation:

```c
eric x: int = 42
assign x "string"  // Error: Type mismatch (int vs string)
```

#### Undefined Array
```c
assign arr[0] 42  // Error: Undefined array 'arr'
```

### Parser Errors

Syntax errors from parser:

```
Input: fun add(x: int { return x }
Error: Parse error: Unmatched parentheses
```

### AST Conversion Errors

S-expression to AST conversion errors:

```
SExpr: (fun add)
Error: fun: bad syntax - expected parameter list
```

### Error Message Format

All errors include:
- **Error type**: "Compilation Error", "Parse Error", etc.
- **Context**: Variable/function name, line information (if available)
- **Description**: Clear explanation of the issue

Example:
```
Compilation Error: Undefined function 'factorial'
  in call: factorial(5)
```

---

## Usage Examples

### Compiling to Bytecode

**Command**:
```bash
glados -c program.tslang -o program.o
```

**Process**:
1. Parse `program.tslang` → SExpr
2. Convert to AST
3. Analyze and optimize
4. Generate bytecode instructions
5. Save to `program.o`

**Execute**:
```bash
glados program.o
```

### Compiling to Native Assembly

**Command**:
```bash
glados program.tslang -o program.o --native
```

**Process**:
1. Parse source → AST
2. Analyze types and functions
3. Generate x86-64 assembly
4. Assemble with `as`
5. Produce `program.o` object file

**Link and Run**:
```bash
gcc program.o -o program
./program
```

### Example Program

**Source** (`factorial.tslang`):
```c
fun factorial(n: int) int {
  if n <= 1 {
    return 1
  }
  return n * factorial(n - 1)
}

fun Eric() void {
  eric result: int = factorial(5)
  peric("Factorial of 5 is: ", result)
}
```

**Compile to Bytecode**:
```bash
glados -c factorial.tslang -o factorial.o
glados factorial.o
```

**Output**:
```
Factorial of 5 is: 120
```

**Compile to Native**:
```bash
glados factorial.tslang -o factorial.o --native
gcc factorial.o -o factorial
./factorial
```

**Output**:
```
Factorial of 5 is: 120
```

### Disassembly

View generated bytecode:
```bash
glados -d factorial.o
```

**Output**:
```
0000: PUSH 5
0005: CALL 10
0010: PRINT
0011: HALT
0015: LOAD_VAR 0
0020: PUSH 1
0025: LT
0026: JUMP_IF_FALSE 35
0030: PUSH 1
0035: RET
...
```

---

## Performance Considerations

### Optimization Strategies

1. **Constant Folding**: Evaluate constant expressions at compile time
2. **Dead Code Elimination**: Remove unreachable code
3. **Global Constant Inlining**: Replace constant variables with literals
4. **Register Allocation**: Minimize memory accesses in assembly
5. **Tail Call Optimization** (planned): Optimize recursive calls

### Bytecode vs Native

**Bytecode Advantages**:
- Fast compilation
- Portable across platforms
- Easy debugging
- Small file size

**Native Assembly Advantages**:
- 10-100x faster execution
- Direct hardware access
- No interpreter overhead
- Full optimization potential

### Compilation Time

Typical compilation times (on modern hardware):

| Lines of Code | Bytecode | Native Assembly |
|---------------|----------|-----------------|
| 100           | <10ms    | ~50ms           |
| 1000          | ~50ms    | ~200ms          |
| 10000         | ~500ms   | ~2s             |

### Runtime Performance

**Bytecode**:
- Simple arithmetic: ~1 μs per operation
- Function call: ~1 μs per call
- Array access: ~0.5 μs

**Native Assembly**:
- Simple arithmetic: ~1 ns per operation
- Function call: ~10 ns per call
- Array access: ~5 ns

### Memory Usage

**Compilation**:
- Bytecode: ~1 MB per 1000 LOC
- Native: ~2 MB per 1000 LOC

**Runtime**:
- Bytecode: AST + bytecode in memory
- Native: Minimal runtime overhead

### Optimization Opportunities

**Current Limitations**:
- No loop unrolling
- No instruction scheduling
- No SIMD vectorization
- No interprocedural optimization

**Future Improvements**:
- LLVM IR backend for advanced optimizations
- Profile-guided optimization
- Link-time optimization
- JIT compilation for bytecode

---

## Future Enhancements

1. **Type Checking**: Full static type checking before code generation
2. **LLVM Backend**: Generate LLVM IR for maximum optimization
3. **Module System**: Support for multiple files and imports
4. **Generics**: Generic functions and data structures
5. **Pattern Matching**: Advanced control flow constructs
6. **Garbage Collection**: Automatic memory management for heap allocations
7. **Incremental Compilation**: Only recompile changed functions
8. **Debug Symbols**: DWARF debug information for native code
9. **Warnings**: Lint-style warnings for suspicious code
10. **Optimization Levels**: -O0, -O1, -O2, -O3 flags

---

## References

- [Bytecode Module](../../src/Bytecode.hs) - Instruction definitions
- [VM Module](../../src/VM.hs) - Bytecode execution engine
- [AST Module](../../src/AST.hs) - Abstract syntax tree definitions
- [Parser Module](../../src/Parser.hs) - Parser selection and integration
- [VM Technical Documentation](TECHNICAL_VM.md) - Virtual machine details
- [User Guide](user_guide.md) - End-user documentation
- [Language Reference](tsl_language_reference.md) - TSL language specification
