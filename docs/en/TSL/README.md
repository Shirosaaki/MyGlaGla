# TSL Documentation - Complete Guide Overview

This directory contains comprehensive documentation for the TSL (Temporal Stream Language) programming language. All files are designed for beginners learning the language from scratch.

## 📚 Documentation Files

### Core Documentation (`docs/`)

| File | Purpose |
|------|---------|
| [LANGUAGE_GUIDE.md](LANGUAGE_GUIDE.md) | **Complete language overview** - All features, syntax, examples, REPL usage, tips, common errors |

### Tutorial Series (`docs/TSL/`)

| # | Topic | File | Content |
|---|-------|------|---------|
| 1 | Hello World | [hello_world.md](TSL/hello_world.md) | Your first program using `Deschodt`, `Eric`, `peric`, `deschodt` |
| 2 | Variables | [variable.md](TSL/variable.md) | Variable declaration, types, scope, interpolation, type conversion |
| 3 | Conditionals | [condition.md](TSL/condition.md) | If/else statements, operators, boolean logic, nested conditions |
| 4 | Loops | [loops.md](TSL/loops.md) | For-in (aer) and while (darius) loops, break/continue, nested loops |
| 5 | Functions | [functions.md](TSL/functions.md) | Function definition, parameters, return types, recursion, practical examples |
| 6 | Arrays/Lists | [lists.md](TSL/lists.md) | Array creation, indexing, sparse arrays, iteration, practical examples |
| 7 | Structs | [structs.md](TSL/structs.md) | Struct definition, fields, nested structs, array of structs |
| 8 | Enums | [enums.md](TSL/enums.md) | Enum definition, auto-numbering, usage in functions, practical patterns |
| 9 | Pointers | [pointers.md](TSL/pointers.md) | Pointer declaration, dereferencing, pass-by-reference, pointer arithmetic |
| 10 | Input/Output | [read-write.md](TSL/read-write.md) | Output with `peric`, string interpolation, formatted output, debugging |

## 🎯 Coverage

### Language Features Documented

**Data Types:**
- ✅ Integers (`int`)
- ✅ Floats (`float`)
- ✅ Strings (`string`)
- ✅ Characters (`char`)
- ✅ Booleans (`bool`)
- ✅ Void (`void`)
- ✅ Arrays (`type[]`)
- ✅ Pointers (`type*`)
- ✅ Structs (`destruct`)
- ✅ Enums (`desnum`)

**Keywords & Functions:**
- ✅ `Deschodt` - Function definition
- ✅ `Eric` - Main function / Variable declaration
- ✅ `peric` - Print output
- ✅ `deschodt` - Return statement
- ✅ `erif` - If conditional
- ✅ `deschelse` - Else conditional
- ✅ `aer` - For-in loop
- ✅ `darius` - While loop
- ✅ `deschontinue` - Continue statement
- ✅ `deschreak` - Break statement
- ✅ `&` - Address-of operator (pointers)
- ✅ `*` - Dereference operator (pointers)

**Operators:**
- ✅ Arithmetic: `+`, `-`, `*`, `/`, `mod`, `div`
- ✅ Comparison: `==`, `!=`, `<`, `>`, `<=`, `>=`
- ✅ Logical: `&&`, `||`, `!`
- ✅ Type annotations: `->`

## 📖 Learning Path

### Beginner (1-4)
Start here if you're new to programming:
1. [Hello World](TSL/hello_world.md) - Write your first program
2. [Variables](TSL/variable.md) - Store and use data
3. [Conditionals](TSL/condition.md) - Make decisions in code
4. [Loops](TSL/loops.md) - Repeat actions

### Intermediate (5-6)
Build more complex programs:
5. [Functions](TSL/functions.md) - Organize code into reusable pieces
6. [Arrays/Lists](TSL/lists.md) - Work with collections of data

### Advanced (7-9)
Create sophisticated data structures:
7. [Structs](TSL/structs.md) - Group related data
8. [Enums](TSL/enums.md) - Define fixed sets of values
9. [Pointers](TSL/pointers.md) - Work with memory addresses

### Practical (10)
Master program communication:
10. [Input/Output](TSL/read-write.md) - Display results and format output

## 🔑 Key Features of Documentation

### For Each Topic:
- ✅ **Basic Concepts** - Simple explanations with syntax
- ✅ **Code Examples** - Runnable examples with output
- ✅ **Practical Applications** - Real-world use cases
- ✅ **Common Mistakes** - Error patterns to avoid
- ✅ **Best Practices** - Tips for writing good code
- ✅ **Cross-references** - Links to related topics

### Documentation Style:
- 🎯 **Beginner-Friendly** - Assumes no programming background
- 📝 **Example-First** - Show code first, explain after
- 🧪 **Runnable Examples** - All code can be tested in the REPL
- 🔗 **Interconnected** - Cross-references between related concepts
- 📊 **Clear Tables** - Syntax and operator reference tables
- ⚠️ **Error Guidance** - Common mistakes with corrections

## 🚀 Using This Documentation

### Learning TSL:
1. Start with **[Hello World](TSL/hello_world.md)**
2. Follow the numbered sequence based on your skill level
3. Type examples into the **Interactive REPL**
4. Experiment and modify examples
5. Refer to **[LANGUAGE_GUIDE](LANGUAGE_GUIDE.md)** for quick reference

### Quick Reference:
- Need syntax help? → Check relevant tutorial section
- Want examples? → See "Practical Example" sections
- Getting an error? → Check "Common Mistakes" section
- Need full overview? → Read **[LANGUAGE_GUIDE](LANGUAGE_GUIDE.md)**

### For Teachers:
- Use tutorials as lesson plans
- Show examples to students
- Point learners to relevant sections
- Use "Common Mistakes" for debugging practice

## 📊 Documentation Statistics

| Metric | Count |
|--------|-------|
| Total Documentation Files | 11 |
| Total Lines of Documentation | ~4,500+ |
| Code Examples | 150+ |
| Practical Examples | 40+ |
| Common Mistakes Listed | 60+ |
| Cross-references | 100+ |
| Tables & Reference Material | 20+ |

## 🔄 Interactive REPL

All examples can be tested in the interactive REPL:

```bash
stack run
# or
./glados
```

**REPL Features:**
- Single-line immediate execution: Type and press Enter
- Multi-line blocks: Use `:code` ... `:end` delimiters
- Line editing: Full support for editing history
- Type any expression to evaluate

## 📝 Example Session

```
$ stack run
glados> eric x = 10 -> int
10
glados> peric("x = {x}")
x = 10
glados> :code
code> eric factorial(n -> int) -> int
code>     erif (n <= 1):
code>         deschodt 1
code>     deschelse:
code>         deschodt n * factorial(n - 1)
code> :end
<closure>
glados> peric("5! = {factorial(5)}")
5! = 120
```

## 🎓 Next Steps

After completing the tutorial series:

1. **Build Projects** - Create your own programs using the learned concepts
2. **Combine Concepts** - Mix arrays, structs, functions for complex solutions
3. **Read Examples** - Study the `.tslang` files in `examples/` folder
4. **Experiment** - Modify examples to understand deeper

## 📞 Documentation Questions?

If concepts are unclear:
1. Check the **LANGUAGE_GUIDE** for additional context
2. Review **Common Mistakes** for error patterns
3. Look at **Practical Examples** for similar cases
4. Experiment in the **REPL** to test understanding

---

**Last Updated:** 2024
**Version:** 1.0 - Complete Beginner Guide
**Status:** ✅ All 10 core topics documented
