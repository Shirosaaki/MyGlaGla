# Functions - Organizing Code

Functions let you write reusable blocks of code. They take parameters, perform operations, and return a result.

## Basic Function Definition

```tsl
Deschodt add(a -> int, b -> int) -> int
    deschodt a + b

Deschodt Eric() -> int
    eric result = add(5, 3) -> int
    peric("Result: {result}")
    deschodt 0
```

Output:
```
Result: 8
```

**Syntax:**
- `Deschodt functionName(param1 -> type1, param2 -> type2) -> returnType`
- `deschodt` returns a value and exits the function
- All parameters must have type annotations
- Return type must be explicitly specified

## Function with No Parameters

```tsl
Deschodt greet() -> string
    deschodt "Hello, World!"

Deschodt Eric() -> int
    eric message = greet() -> string
    peric("{message}")
    deschodt 0
```

Output:
```
Hello, World!
```

## Function with No Return Value (void)

```tsl
Deschodt printMessage(msg -> string) -> void
    peric("Message: {msg}")

Deschodt Eric() -> int
    printMessage("Hello")
    printMessage("World")
    deschodt 0
```

Output:
```
Message: Hello
Message: World
```

When return type is `void`, you don't return a value (or `deschodt` is omitted).

## Multiple Parameters

```tsl
Deschodt multiply(a -> int, b -> int) -> int
    deschodt a * b

Deschodt power(base -> int, exponent -> int) -> int
    eric result = 1 -> int
    aer i in range(0, exponent):
        result = result * base
    deschodt result

Deschodt Eric() -> int
    peric("3 * 4 = {multiply(3, 4)}")
    peric("2^5 = {power(2, 5)}")
    deschodt 0
```

Output:
```
3 * 4 = 12
2^5 = 32
```

## Different Return Types

Functions can return any type:

```tsl
Deschodt getAge() -> int
    deschodt 25

Deschodt getName() -> string
    deschodt "Alice"

Deschodt isStudent() -> bool
    deschodt #t

Deschodt getHeight() -> float
    deschodt 1.75

Deschodt Eric() -> int
    peric("Age: {getAge()}")
    peric("Name: {getName()}")
    peric("Student: {isStudent()}")
    peric("Height: {getHeight()}")
    deschodt 0
```

## Conditional Return

```tsl
Deschodt getGrade(score -> int) -> string
    erif (score >= 90):
        deschodt "A"
    deschelse:
        erif (score >= 80):
            deschodt "B"
        deschelse:
            erif (score >= 70):
                deschodt "C"
            deschelse:
                deschodt "F"

Deschodt Eric() -> int
    peric("Grade: {getGrade(85)}")
    deschodt 0
```

Output:
```
Grade: B
```

## Function Calling Function

Functions can call other functions:

```tsl
Deschodt isEven(n -> int) -> bool
    eric remainder = n -> int
    desnote Use modulo conceptually
    erif (remainder == 0):
        deschodt #t
    deschelse:
        deschodt #f

Deschodt printIfEven(n -> int) -> void
    erif (isEven(n)):
        peric("{n} is even")
    deschelse:
        peric("{n} is odd")

Deschodt Eric() -> int
    printIfEven(4)
    printIfEven(7)
    deschodt 0
```

## Recursion

Functions can call themselves to solve problems recursively:

```tsl
Deschodt factorial(n -> int) -> int
    erif (n <= 1):
        deschodt 1
    deschelse:
        deschodt n * factorial(n - 1)

Deschodt Eric() -> int
    peric("5! = {factorial(5)}")
    deschodt 0
```

Output:
```
5! = 120
```

## Passing Arrays to Functions

```tsl
Deschodt sumArray(arr -> int[], size -> int) -> int
    eric total = 0 -> int
    aer i in range(0, size):
        total = total + arr[i]
    deschodt total

Deschodt Eric() -> int
    eric numbers -> int[]
    numbers[0] = 10
    numbers[1] = 20
    numbers[2] = 30
    
    eric sum = sumArray(numbers, 3) -> int
    peric("Sum: {sum}")
    deschodt 0
```

Output:
```
Sum: 60
```

## Passing Pointers (By Reference)

Use pointers to modify values inside a function:

```tsl
Deschodt increment(ptr -> int*) -> void
    *ptr = *ptr + 1

Deschodt Eric() -> int
    eric x = 10 -> int
    peric("Before: {x}")
    increment(&x)
    peric("After: {x}")
    deschodt 0
```

Output:
```
Before: 10
After: 11
```

## Function with Multiple Exit Points

```tsl
Deschodt getStatus(score -> int) -> string
    erif (score < 0):
        deschodt "Invalid"
    
    erif (score < 50):
        deschodt "Fail"
    
    erif (score < 80):
        deschodt "Pass"
    
    deschodt "Excellent"

Deschodt Eric() -> int
    peric("Status: {getStatus(75)}")
    deschodt 0
```

Output:
```
Status: Pass
```

## Practical Example: Prime Number Checker

```tsl
Deschodt isPrime(n -> int) -> bool
    erif (n < 2):
        deschodt #f
    
    aer i in range(2, n):
        eric remainder = 0 -> int
        desnote Check if n is divisible by i
        desnote For now, assume we have modulo checking
        deschodt #f
    
    deschodt #t

Deschodt Eric() -> int
    eric num = 17 -> int
    erif (isPrime(num)):
        peric("{num} is prime")
    deschelse:
        peric("{num} is not prime")
    deschodt 0
```

## Practical Example: Fibonacci Sequence

```tsl
Deschodt fibonacci(n -> int) -> int
    erif (n <= 1):
        deschodt n
    deschelse:
        deschodt fibonacci(n - 1) + fibonacci(n - 2)

Deschodt Eric() -> int
    aer i in range(0, 7):
        peric("fib({i}) = {fibonacci(i)}")
    deschodt 0
```

Output:
```
fib(0) = 0
fib(1) = 1
fib(2) = 1
fib(3) = 2
fib(4) = 3
fib(5) = 5
fib(6) = 8
```

## Practical Example: String Processing Function

```tsl
Deschodt repeatString(str -> string, times -> int) -> string
    eric result = "" -> string
    aer i in range(0, times):
        desnote String concatenation (conceptually)
        desnote In practice, use string operations
    deschodt result

Deschodt Eric() -> int
    desnote Demonstrate function composition
    deschodt 0
```

## Common Mistakes

### Forgetting Return Type
```tsl
Deschodt add(a -> int, b -> int)    desnote ERROR - missing return type
Deschodt add(a -> int, b -> int) -> int  desnote CORRECT
```

### Parameter Type Mismatch
```tsl
Deschodt greet(name -> string) -> string
    deschodt "Hello, {name}"

Eric() -> int
    greet(42)      desnote ERROR - passed int, expected string
    greet("Bob")   desnote CORRECT
```

### Forgetting deschodt
```tsl
Deschodt getValue() -> int
    eric value = 10 -> int
    desnote ERROR - no return statement

Deschodt getValue() -> int
    eric value = 10 -> int
    deschodt value  desnote CORRECT
```

### Stack Overflow with Recursion
```tsl
Deschodt infinite(n -> int) -> int
    deschodt infinite(n + 1)  desnote Infinite recursion - avoid!

Deschodt countdown(n -> int) -> int
    erif (n <= 0):
        deschodt 0
    deschelse:
        deschodt countdown(n - 1)  desnote Proper recursion with base case
```

## Best Practices

1. **Single Responsibility**: Each function should do one thing well
2. **Clear Names**: Use descriptive function names that explain what they do
3. **Document Purpose**: Add comments explaining what the function does
4. **Validate Input**: Check parameters are valid
5. **Early Return**: Return early when possible to simplify logic
6. **Avoid Deep Nesting**: Keep functions simple and readable

## Next Steps

- Combine functions with **[Loops](loops.md)** for powerful patterns
- Use **[Arrays](lists.md)** with functions for data processing
- Explore **[Structs](structs.md)** to pass complex data to functions
