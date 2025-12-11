# Hello World - Getting Started with TSL

## Your First Program

The simplest TSL program prints "Hello, World!":

```tsl
Deschodt Eric() -> int
    peric("Salut, monde !")
    deschodt 0
```

When you run this program, it outputs:
```
Salut, monde !
```

## Understanding the Code

### `Deschodt` - Function Declaration
- `Deschodt` is the keyword for defining a function
- Every TSL program needs an `Eric` function (the entry point)
- Think of it like `main()` in C or Java

### `Eric()` - Main Function
- `Eric` is the special name for the main function
- The parentheses `()` indicate it takes no parameters
- This is where your program starts executing

### `-> int` - Return Type
- Specifies that the function returns an integer
- `0` indicates successful execution (standard in most systems)
- Other return types could be `string`, `float`, `void`, etc.

### `peric(...)` - Printing Output
- `peric` stands for "print" (in French: "écrire")
- Takes a string argument
- Prints to the console and adds a newline
- Can use string interpolation with `{variable}`

### `deschodt` - Return Statement
- `deschodt` means "return" (in French: "descendre" → down)
- Exits the function and returns a value
- `deschodt 0` returns exit code 0 (success)

## Running Your Program

### Compile and Run
```bash
./glados < hello.tsl
```

### Interactive REPL
```bash
./glados
> :code
|Deschodt Eric() -> int
|    peric("Salut, monde !")
|    deschodt 0
|:end
Salut, monde !
```

## Variations

### Printing Multiple Lines
```tsl
Deschodt Eric() -> int
    peric("Line 1")
    peric("Line 2")
    peric("Line 3")
    deschodt 0
```

Output:
```
Line 1
Line 2
Line 3
```

### Using String Interpolation
```tsl
Deschodt Eric() -> int
    eric name = "Alice" -> string
    peric("Hello, {name}!")
    deschodt 0
```

Output:
```
Hello, Alice!
```

### Different Return Codes
```tsl
Deschodt Eric() -> int
    erif (someCondition):
        deschodt 1    desnote error exit
    deschelse:
        deschodt 0    desnote success exit
```

## Next Steps

Now that you understand the basic structure, explore:
1. **[Variables](variable.md)** - Store and manipulate data
2. **[Conditionals](condition.md)** - Make decisions in your code
3. **[Loops](loops.md)** - Repeat actions
4. **[Functions](functions.md)** - Organize reusable code

Happy coding!
