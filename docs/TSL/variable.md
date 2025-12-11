# Variables - Storing Data

Variables allow you to store and manipulate data in your program. TSL is **statically typed**, meaning each variable has a specific data type that cannot change.

## Basic Variable Declaration

### Declare Without Initialization

```tsl
eric x -> int
eric name -> string
eric value -> float
```

Variables declared this way exist but have undefined values. You should assign them before using.

### Declare With Initialization

```tsl
eric x = 5 -> int
eric name = "Alice" -> string
eric pi = 3.14 -> float
```

This declares and assigns a value in one step.

## Data Types

TSL supports these primitive types:

| Type | Description | Examples |
|------|-------------|----------|
| `int` | 32-bit signed integer | `42`, `-10`, `0` |
| `float` | Floating-point number | `3.14`, `-2.5`, `0.0` |
| `string` | Text string | `"Hello"`, `"TSL"` |
| `char` | Single character | `'a'`, `'Z'`, `'!'` |
| `bool` | Boolean value | `#t` (true), `#f` (false) |

## Assigning Values

Once declared, assign new values with `=`:

```tsl
Deschodt Eric() -> int
    eric x = 10 -> int
    x = 20              desnote reassign x to 20
    x = x + 5           desnote x is now 25
    
    peric("x = {x}")
    deschodt 0
```

Output:
```
x = 25
```

## Variable Scope

Variables exist from declaration until the end of their block:

```tsl
Deschodt Eric() -> int
    eric x = 1 -> int
    peric("x = {x}")    desnote x is accessible here
    
    erif (#t):
        eric y = 2 -> int
        peric("y = {y}")    desnote y is accessible here
    
    desnote y no longer exists here - would cause error
    
    deschodt 0
```

## Naming Conventions

Choose clear, descriptive names:

```tsl
desnote Good variable names
eric totalPrice -> float
eric userAge -> int
eric isValid -> bool

desnote Avoid unclear names
eric x -> int           desnote too vague
eric asdf -> string     desnote meaningless
eric a1b2c3 -> float    desnote hard to remember
```

## Using Variables in Expressions

Variables work in arithmetic and logical operations:

```tsl
Deschodt Eric() -> int
    eric a = 10 -> int
    eric b = 3 -> int
    eric sum = a + b -> int
    eric product = a * b -> int
    
    peric("Sum: {sum}")         desnote Sum: 13
    peric("Product: {product}") desnote Product: 30
    
    deschodt 0
```

## String Interpolation

Insert variable values into strings using `{variable}`:

```tsl
Deschodt Eric() -> int
    eric name = "Bob" -> string
    eric age = 25 -> int
    eric height = 1.75 -> float
    
    peric("Name: {name}")                      desnote Name: Bob
    peric("Age: {age}")                        desnote Age: 25
    peric("Height: {height} meters")           desnote Height: 1.75 meters
    peric("{name} is {age} years old")         desnote Bob is 25 years old
    
    deschodt 0
```

## Type Conversion

To convert between types:

```tsl
desnote Float to int (loses decimals)
eric f = 3.7 -> float
eric i = (cast int f) -> int    desnote i is now 3

desnote Int to float (adds .0)
eric i = 42 -> int
eric f = (cast float i) -> float desnote f is now 42.0
```

## Common Mistakes

### Forgetting Type Annotation
```tsl
eric x = 5      desnote ERROR - missing type
eric x = 5 -> int desnote CORRECT
```

### Type Mismatch
```tsl
eric x = "hello" -> int  desnote ERROR - string can't be int
eric x = "hello" -> string desnote CORRECT
```

### Using Undefined Variable
```tsl
peric("{y}")     desnote ERROR - y was never declared
eric y = 0 -> int
peric("{y}")     desnote CORRECT
```

## Complete Example

```tsl
Deschodt Eric() -> int
    desnote Declare and initialize variables
    eric firstName = "Alice" -> string
    eric lastName = "Smith" -> string
    eric birthYear = 1995 -> int
    eric currentYear = 2024 -> int
    
    desnote Calculate age
    eric age = currentYear - birthYear -> int
    
    desnote Use string interpolation
    peric("Name: {firstName} {lastName}")
    peric("Age: {age}")
    
    deschodt 0
```

Output:
```
Name: Alice Smith
Age: 29
```

## Next Steps

- Learn about **[Conditionals](condition.md)** to make decisions based on variables
- Explore **[Arrays](lists.md)** to store multiple values
- See **[Functions](functions.md)** to pass and return variables
