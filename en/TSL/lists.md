# Arrays (Lists) - Storing Multiple Values

Arrays store multiple values of the same type in sequential order. They let you work with collections of data where all indices from 0 to the highest index used are automatically filled.

## Creating an Array

```tsl
Deschodt Eric() -> int
    eric numbers -> int[]
    eric names -> string[]
    eric flags -> bool[]
    deschodt 0
```

**Syntax:**
- `eric variableName -> type[]` declares an array of that type
- Arrays can hold `int`, `float`, `string`, `char`, `bool`, or custom types

## Setting Array Values

Arrays use index notation with square brackets `[]`. Indices start at `0`:

```tsl
Deschodt Eric() -> int
    eric scores -> int[]
    
    scores[0] = 95
    scores[1] = 87
    scores[2] = 92
    
    peric("First score: {scores[0]}")
    peric("Third score: {scores[2]}")
    deschodt 0
```

Output:
```
First score: 95
Third score: 92
```

## Accessing Array Elements

Use the index `[n]` to read values:

```tsl
Deschodt Eric() -> int
    eric colors -> string[]
    
    colors[0] = "red"
    colors[1] = "green"
    colors[2] = "blue"
    
    eric first = colors[0] -> string
    eric second = colors[1] -> string
    
    peric("Colors: {first}, {second}")
    deschodt 0
```

Output:
```
Colors: red, green
```

## Looping Through Arrays with `aer`

Use the `aer` (for-in) loop to iterate through array indices:

```tsl
Deschodt Eric() -> int
    eric numbers -> int[]
    
    numbers[0] = 10
    numbers[1] = 20
    numbers[2] = 30
    numbers[3] = 40
    
    aer i in range(0, 4):
        peric("numbers[{i}] = {numbers[i]}")
    
    deschodt 0
```

Output:
```
numbers[0] = 10
numbers[1] = 20
numbers[2] = 30
numbers[3] = 40
```

## Understanding Sequential Fill-Forward

When you set an array element at index N, all indices from 0 to N-1 are automatically filled with the most recent previously set value. This is called **sequential fill-forward**:

```tsl
Deschodt Eric() -> int
    eric data -> int[]
    
    data[0] = 50        desnote data is now [50]
    data[2] = 20        desnote data automatically becomes [50, 50, 20]
    
    desnote Index 1 was automatically filled with the previous value (50)
    peric("data[0] = {data[0]}")   desnote prints 50
    peric("data[1] = {data[1]}")   desnote prints 50 (auto-filled)
    peric("data[2] = {data[2]}")   desnote prints 20
    
    deschodt 0
```

Output:
```
data[0] = 50
data[1] = 50
data[2] = 20
```

### Another Example

```tsl
Deschodt Eric() -> int
    eric numbers -> int[]
    
    numbers[0] = 100
    numbers[5] = 200    desnote Creates array with 6 elements total
    
    desnote Indices 1-4 are automatically filled with 100
    aer i in range(0, 6):
        peric("numbers[{i}] = {numbers[i]}")
    
    deschodt 0
```

Output:
```
numbers[0] = 100
numbers[1] = 100
numbers[2] = 100
numbers[3] = 100
numbers[4] = 100
numbers[5] = 200
```

**Key Point:** Unlike sparse arrays in other languages, you cannot have "gaps" or "undefined" indices. Setting `data[0]=50` and then `data[100]=20` creates an array of 101 elements where indices 1-99 are automatically filled with 50.

## Array of Strings

```tsl
Deschodt Eric() -> int
    eric fruits -> string[]
    
    fruits[0] = "apple"
    fruits[1] = "banana"
    fruits[2] = "orange"
    fruits[3] = "grape"
    
    aer i in range(0, 4):
        peric("Fruit {i}: {fruits[i]}")
    
    deschodt 0
```

Output:
```
Fruit 0: apple
Fruit 1: banana
Fruit 2: orange
Fruit 3: grape
```

## Array of Floats

```tsl
Deschodt Eric() -> int
    eric temperatures -> float[]
    
    temperatures[0] = 20.5
    temperatures[1] = 22.3
    temperatures[2] = 18.7
    temperatures[3] = 25.0
    
    aer day in range(0, 4):
        peric("Day {day}: {temperatures[day]}°C")
    
    deschodt 0
```

Output:
```
Day 0: 20.5°C
Day 1: 22.3°C
Day 2: 18.7°C
Day 3: 25.0°C
```

## Computing with Arrays

### Sum of Array Elements

```tsl
Deschodt Eric() -> int
    eric numbers -> int[]
    
    numbers[0] = 10
    numbers[1] = 20
    numbers[2] = 30
    numbers[3] = 40
    
    eric total = 0 -> int
    aer i in range(0, 4):
        total = total + numbers[i]
    
    peric("Total: {total}")
    deschodt 0
```

Output:
```
Total: 100
```

### Finding Maximum Value

```tsl
Deschodt Eric() -> int
    eric scores -> int[]
    
    scores[0] = 45
    scores[1] = 92
    scores[2] = 78
    scores[3] = 88
    scores[4] = 95
    
    eric max_score = scores[0] -> int
    aer i in range(1, 5):
        erif (scores[i] > max_score):
            max_score = scores[i]
    
    peric("Highest score: {max_score}")
    deschodt 0
```

Output:
```
Highest score: 95
```

### Counting Elements

```tsl
Deschodt Eric() -> int
    eric numbers -> int[]
    
    numbers[0] = 5
    numbers[1] = 3
    numbers[2] = 7
    numbers[3] = 3
    numbers[4] = 5
    numbers[5] = 9
    
    eric count = 0 -> int
    eric target = 5 -> int
    
    aer i in range(0, 6):
        erif (numbers[i] == target):
            count = count + 1
    
    peric("Found {target} {count} times")
    deschodt 0
```

Output:
```
Found 5 2 times
```

## Arrays of Booleans

```tsl
Deschodt Eric() -> int
    eric flags -> bool[]
    
    flags[0] = #t
    flags[1] = #f
    flags[2] = #t
    flags[3] = #f
    flags[4] = #t
    
    eric true_count = 0 -> int
    aer i in range(0, 5):
        erif (flags[i]):
            true_count = true_count + 1
    
    peric("True values: {true_count}")
    deschodt 0
```

Output:
```
True values: 3
```

## Passing Arrays to Functions

```tsl
Deschodt sumArray(arr -> int[], size -> int) -> int
    eric total = 0 -> int
    aer i in range(0, size):
        total = total + arr[i]
    deschodt total

Deschodt averageArray(arr -> int[], size -> int) -> float
    eric sum = sumArray(arr, size) -> int
    deschodt sum / size

Deschodt Eric() -> int
    eric grades -> int[]
    
    grades[0] = 85
    grades[1] = 92
    grades[2] = 78
    grades[3] = 95
    
    eric avg = averageArray(grades, 4) -> float
    peric("Average: {avg}")
    deschodt 0
```

Output:
```
Average: 87.5
```

## Array of Characters

```tsl
Deschodt Eric() -> int
    eric letters -> char[]
    
    letters[0] = #\a
    letters[1] = #\b
    letters[2] = #\c
    
    aer i in range(0, 3):
        peric("Letter {i}: {letters[i]}")
    
    deschodt 0
```

Output:
```
Letter 0: a
Letter 1: b
Letter 2: c
```

## Understanding Array Size

Because of sequential fill-forward, the array size is determined by the highest index you've set plus one. All lower indices are automatically created and filled:

```tsl
Deschodt Eric() -> int
    eric data -> int[]
    
    data[0] = 10     desnote Array size: 1
    data[3] = 40     desnote Array size: 4 (auto-fill creates indices 1 and 2)
    data[1] = 20     desnote Array size: still 4
    
    desnote Accessing an index that hasn't been explicitly set yet but was auto-filled
    peric("{data[2]}")   desnote Prints 10 (filled by sequential fill-forward)
    deschodt 0
```

**Important:** You cannot access indices beyond what has been created by your assignments. The array size grows as you access higher indices, but you must set a value at that index first.

## Practical Example: Multiplication Table

```tsl
Deschodt Eric() -> int
    eric table -> int[]
    eric multiplier = 7 -> int
    
    desnote Set values at indices 1-10
    desnote Note: index 0 will be auto-filled with 7 * 1 = 7
    aer i in range(1, 11):
        table[i] = multiplier * i
    
    desnote Now print from index 1 to 10 (index 0 auto-filled)
    aer i in range(1, 11):
        peric("7 × {i} = {table[i]}")
    
    deschodt 0
```

Output:
```
7 × 1 = 7
7 × 2 = 14
7 × 3 = 21
...
7 × 10 = 70
```

## Practical Example: Grade Letter Assignment

```tsl
Deschodt Eric() -> int
    eric scores -> int[]
    eric grades -> string[]
    
    scores[0] = 92
    scores[1] = 78
    scores[2] = 65
    scores[3] = 88
    scores[4] = 95
    
    aer i in range(0, 5):
        eric score = scores[i] -> int
        erif (score >= 90):
            grades[i] = "A"
        deschelse:
            erif (score >= 80):
                grades[i] = "B"
            deschelse:
                erif (score >= 70):
                    grades[i] = "C"
                deschelse:
                    grades[i] = "F"
    
    aer i in range(0, 5):
        peric("Score {scores[i]}: Grade {grades[i]}")
    
    deschodt 0
```

Output:
```
Score 92: Grade A
Score 78: Grade C
Score 65: Grade F
Score 88: Grade B
Score 95: Grade A
```

## Practical Example: Finding Minimum Value

```tsl
Deschodt Eric() -> int
    eric values -> int[]
    
    values[0] = 45
    values[1] = 12
    values[2] = 89
    values[3] = 23
    values[4] = 7
    values[5] = 56
    
    eric min_val = values[0] -> int
    aer i in range(1, 6):
        erif (values[i] < min_val):
            min_val = values[i]
    
    peric("Minimum: {min_val}")
    deschodt 0
```

Output:
```
Minimum: 7
```

## Common Mistakes

### Forgetting Array Type
```tsl
eric data -> int[]        desnote CORRECT
eric data -> []           desnote ERROR - must specify type
```

### Not Understanding Sequential Fill-Forward
```tsl
eric arr -> int[]
arr[0] = 10
arr[2] = 30              desnote This creates [10, 10, 30] - index 1 auto-filled!
eric x = arr[1] -> int   desnote This is valid and equals 10 (auto-filled)
```

### Type Mismatch in Array
```tsl
eric numbers -> int[]
numbers[0] = 10          desnote CORRECT
numbers[1] = "ten"       desnote ERROR - string in int array
```

### Loop Out of Bounds
```tsl
eric data -> int[]
data[3] = 30
data[5] = 50             desnote Array now has 6 elements (indices 0-5)

aer i in range(0, 10):   desnote WRONG - will try to access data[6-9]
    peric(data[i])

aer i in range(0, 6):    desnote CORRECT - matches array size
    peric(data[i])
```

## Best Practices

1. **Understand Fill-Forward**: Remember that setting a high index fills all intermediate indices with the previous value
2. **Track Array Size**: Keep track of what your highest index is (that determines array size)
3. **Use Contiguous Indices**: Typically set indices 0, 1, 2... in order for clearer code
4. **Match Loop Bounds**: Your loop range should match the actual array size (highest index + 1)
5. **Use Functions**: Extract array operations into functions for reuse
6. **Document Array Length**: Add comments about expected array size

## Next Steps

- Combine arrays with **[Functions](functions.md)** to process data
- Use arrays in **[Loops](loops.md)** for iteration
- Store arrays in **[Structs](structs.md)** for complex data structures
