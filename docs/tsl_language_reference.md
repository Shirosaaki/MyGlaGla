# 📝 TSL Language Reference

This document is a comprehensive reference for TheShowLang (TSL), the small custom language used by the GLADOS interpreter. TSL uses French-styled keywords but follows familiar programming concepts, with Python-like block syntax (colon + indentation) and C-style types for strings and pointers.

## 🧭 Overview

The language uses French-inspired keywords to define functions, variables, control blocks, structures, constants, and more. Block structure is indicated using `:` and indentation (similar to Python). Functions are declared with `Deschodt` followed by the name and `->` to indicate the return type. Arguments are written as `name -> type`.

Minimal example (program entry point):

Deschodt Eric() -> int
    peric("Hello, world!")
    deschodt 0

The `peric` call prints text with printf-like interpolation using `{var}`.

Note: the `Deschodt Eric() -> int` form represents the program's main function (the entry point) — equivalent to `main` in other languages. Examples in this repository consistently use this signature for the entry point.

## 🔤 Types and Declarations

- Variable declaration:
  - `eric x = 5` (declare and initialize; type is inferred)
  - `eric x -> int` (declare without initializing; specify the type)
  - Arrays: `eric nums -> int[]` or `eric values -> int[4]` (fixed-size arrays can be used)
  - Pointers: use `ptr -> int*` in function signatures; `&` and `*` operators are supported
  - Strings: `char *str` (C-like)

Example:

eric name = "Matheo"
eric age = 21
peric("Hello {name}, you are {age} years old.")

### 🔒 Constants

`desconst NAME = value`

Example:

desconst PI = 3.1415

### 🧾 Enumerations

`desenum Name:\n    Value1\n    Value2` — enumerated values with implicit indices. Example:

desenum Day:
    Monday
    Tuesday
    Wednesday

### 🏗️ Structures

`destruct Name:\n    type field1\n    type field2` — members are accessed with `.` and you can pass the address (`&`) when a function expects a pointer.

Example:

destruct Car:
    char* brand
    int speed

eric car -> Car
car.brand = "Peugeot"
car.speed = 100

## ⚙️ Functions

- Declaration:
  - `Deschodt name(arg1 -> type, arg2 -> type) -> return_type`
  - Return values with `deschodt <expression>` (similar to `return`).
  - Function prototypes can appear in `.hlang` files and be included with `johnsenat "file.hlang"`.

Example:

Deschodt add(a -> int, b -> int) -> int
    deschodt a + b

Deschodt Eric() -> int
    eric result = add(5, 7)
    peric("Result: {result}")
    deschodt 0

### 🧷 Passing by Address / Pointers

Example incrementing via pointer:

Deschodt increment(ptr -> int*) -> void
    *ptr = *ptr + 1

Deschodt Eric() -> int
    eric n = 10
    increment(&n)
    peric("n = {n}")
    deschodt 0

## 🔁 Control Flow

- If: `erif (cond):` followed by an indented block. Alternative branch uses `deschelse:`.

Example:

erif (age >= 18):
    peric("Adult")
deschelse:
    peric("Minor")

- Loops:
  - `aer i in range(start, end):` — for-loop (iterate over a range)
  - `darius (cond):` — while-loop
  - Loop control: `deschontinue` (continue), `deschreak` (break)

Examples:

aer i in range(0, 5):
    peric("i = {i}")

eric x = 0
darius (x < 3):
    peric("x = {x}")
    x = x + 1

## 📚 Arrays

- Declaration: `eric tab -> int[]` or `eric tab -> int[4]`
- Access: `tab[i]`

Sum example:

Deschodt sum(tab -> int[], size -> int) -> int
    eric total = 0
    aer i in range(0, size):
        total = total + tab[i]
    deschodt total

## 🔡 Strings and Utility Functions

The examples include utility functions for string manipulation and comparisons (for example `my_strlen` and `my_strcmp`).

Implementation (excerpt):

Deschodt my_strlen(s -> char *) -> int
    eric len -> int
    len = 0
    darius (s[len] != '\0'):
        len = len + 1
    deschodt len

## 🖨️ I/O and Interpolation

- `peric("text {var}...")` prints text where `{var}` is replaced with the variable value.
- Example files commonly include `desnote print ...` lines after examples — these are expected-output annotations used for quick verification (not needed at runtime).

## ✅ Recognized Keywords

- `Deschodt`: function start
- `deschodt`: return a value
- `eric`: variable declaration
- `erif`: conditional (if)
- `deschelse`: else
- `aer`: for (iteration using `in range`)
- `darius`: while
- `deschontinue`: continue
- `deschreak`: break
- `peric`: print
- `desconst`: constant
- `desenum`: enum
- `destruct`: struct
- `johnsenat`: include header (e.g. `johnsenat "example1.hlang"`)
- `desnote`: example annotation / expected output (not required at runtime)

## 📁 Annotated Examples (from `examples/`)

- For-loop (`aer`): `examples/sample/example3.tslang`
- If / else: `examples/sample/example4.tslang`
- Structs: `examples/sample/example5.tslang` and `examples/sample/example14.tslang`
- Arrays and iteration: `examples/sample/example6.tslang`
- Continue / Break: `examples/sample/example8.tslang`
- Functions & recursion (factorial): `examples/sample/example13.tslang`
- Pointers / pass-by-address: `examples/sample/example12.tslang`
- Headers & prototypes: `examples/with_header/example1.hlang` and `examples/with_header/my_strlen.tslang`

Each example file contains a `desnote print ...` sequence showing the expected output for quick verification.
