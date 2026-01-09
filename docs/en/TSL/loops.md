# Loops - Repeating Code

Loops let you repeat code multiple times without writing it over and over. TSL provides two types: `aer` (for-in) and `darius` (while).

## For-In Loop (aer)

The `aer` loop iterates over a range:

```tsl
Deschodt Eric() -> int
    aer i in range(0, 5):
        peric("i = {i}")
    
    deschodt 0
```

Output:
```
i = 0
i = 1
i = 2
i = 3
i = 4
```

**Key Points:**
- `aer i in range(0, 5)` loops from 0 to 4 (5 iterations)
- The range is `start` to `end-1` (end is exclusive)
- `i` is the loop variable, automatically incremented

## While Loop (darius)

The `darius` loop repeats while a condition is true:

```tsl
Deschodt Eric() -> int
    eric x = 0 -> int
    
    darius (x < 3):
        peric("x = {x}")
        x = x + 1
    
    deschodt 0
```

Output:
```
x = 0
x = 1
x = 2
```

**Key Points:**
- The condition is checked before each iteration
- You must manually update the counter (`x = x + 1`)
- If the condition is never true, the loop never executes

## Loop Control Statements

### continue - Skip to Next Iteration

`deschontinue` jumps to the next iteration:

```tsl
Deschodt Eric() -> int
    aer i in range(0, 5):
        erif (i == 2):
            deschontinue    desnote skip when i = 2
        peric("i = {i}")
    
    deschodt 0
```

Output:
```
i = 0
i = 1
i = 3
i = 4
```

### break - Exit the Loop

`deschreak` exits the loop immediately:

```tsl
Deschodt Eric() -> int
    aer i in range(0, 10):
        erif (i == 5):
            deschreak       desnote exit when i = 5
        peric("i = {i}")
    
    peric("Loop finished")
    deschodt 0
```

Output:
```
i = 0
i = 1
i = 2
i = 3
i = 4
Loop finished
```

## Complex Loop Example

```tsl
Deschodt Eric() -> int
    aer i in range(0, 10):
        erif (i == 3):
            deschontinue    desnote skip 3
        erif (i == 7):
            deschreak       desnote exit at 7
        peric("i = {i}")
    
    peric("Loop finished")
    deschodt 0
```

Output:
```
i = 0
i = 1
i = 2
i = 4
i = 5
i = 6
Fin de boucle
```

## Nested Loops

Loops can be nested inside each other:

```tsl
Deschodt Eric() -> int
    aer i in range(0, 3):
        aer j in range(0, 3):
            peric("({i}, {j})")
    
    deschodt 0
```

Output:
```
(0, 0)
(0, 1)
(0, 2)
(1, 0)
(1, 1)
(1, 2)
(2, 0)
(2, 1)
(2, 2)
```

## Iterating Over Arrays

Use loops to process array elements:

```tsl
Deschodt Eric() -> int
    eric nums -> int[]
    nums[0] = 10
    nums[1] = 20
    nums[2] = 30
    
    aer i in range(0, 3):
        peric("nums[{i}] = {nums[i]}")
    
    deschodt 0
```

Output:
```
nums[0] = 10
nums[1] = 20
nums[2] = 30
```

## While Loop with Arrays

```tsl
Deschodt Eric() -> int
    eric arr -> int[]
    arr[0] = 5
    arr[1] = 10
    arr[2] = 15
    
    eric index = 0 -> int
    darius (index < 3):
        peric("arr[{index}] = {arr[index]}")
        index = index + 1
    
    deschodt 0
```

Output:
```
arr[0] = 5
arr[1] = 10
arr[2] = 15
```

## Infinite Loop (Careful!)

A loop that never ends:

```tsl
eric counter = 0 -> int
darius (#t):        desnote always true
    peric("Infinite loop: {counter}")
    counter = counter + 1
    erif (counter > 5):
        deschreak   desnote exit manually
```

Output:
```
Infinite loop: 0
Infinite loop: 1
Infinite loop: 2
Infinite loop: 3
Infinite loop: 4
Infinite loop: 5
```

## Practical Example: Sum Numbers

```tsl
Deschodt sumRange(start -> int, end -> int) -> int
    eric total = 0 -> int
    aer i in range(start, end):
        total = total + i
    deschodt total

Deschodt Eric() -> int
    eric result = sumRange(1, 6) -> int
    peric("Sum of 1 to 5: {result}")
    deschodt 0
```

Output:
```
Sum of 1 to 5: 15
```

## Practical Example: Find Maximum

```tsl
Deschodt findMax(arr -> int[], size -> int) -> int
    eric max = arr[0] -> int
    aer i in range(1, size):
        erif (arr[i] > max):
            max = arr[i]
    deschodt max

Deschodt Eric() -> int
    eric numbers -> int[]
    numbers[0] = 15
    numbers[1] = 8
    numbers[2] = 23
    numbers[3] = 4
    
    eric maximum = findMax(numbers, 4) -> int
    peric("Maximum: {maximum}")
    deschodt 0
```

Output:
```
Maximum: 23
```

## Practical Example: Print Multiplication Table

```tsl
Deschodt Eric() -> int
    eric num = 7 -> int
    peric("Multiplication table for {num}:")
    
    aer i in range(1, 11):
        eric product = num * i -> int
        peric("{num} x {i} = {product}")
    
    deschodt 0
```

Output:
```
Multiplication table for 7:
7 x 1 = 7
7 x 2 = 14
7 x 3 = 21
...
7 x 10 = 70
```

## Common Mistakes

### Off-by-One Error
```tsl
desnote Wants to print 0-4, but range(0, 5) gives 0-4 - this is correct!
aer i in range(0, 5):
    peric("{i}")

desnote Common mistake: forgetting that end is exclusive
aer i in range(0, 4):      desnote Only goes to 3, not 4
    peric("{i}")
```

### Infinite Loop with While
```tsl
eric x = 0 -> int
darius (x < 5):
    peric("{x}")
    desnote Forgot x = x + 1, infinite loop!
```

### Wrong Loop Type
```tsl
desnote Use aer when you know how many iterations
aer i in range(0, 5):
    peric("{i}")

desnote Use darius when condition is complex
darius ((x > 0) && (y < 10)):
    x = x - 1
```

## Next Steps

- Learn **[Functions](functions.md)** to organize loop logic
- Explore **[Arrays](lists.md)** to process collections
- Use **[Conditionals](condition.md)** inside loops
