# Input & Output - Communicating with Your Program

Input and output (I/O) operations let your program display information to the user and potentially receive information from them.

## Output with peric

The `peric` function prints text to the screen. It's the primary way to show output:

```tsl
Deschodt Eric() -> int
    peric("Hello, World!")
    peric("This is my first program")
    deschodt 0
```

Output:
```
Hello, World!
This is my first program
```

## Printing Different Types

### Integers
```tsl
Deschodt Eric() -> int
    eric count = 42 -> int
    peric("Count: {count}")
    
    eric sum = 10 + 20 + 30 -> int
    peric("Sum: {sum}")
    
    deschodt 0
```

Output:
```
Count: 42
Sum: 60
```

### Floats
```tsl
Deschodt Eric() -> int
    eric pi = 3.14159 -> float
    eric price = 19.99 -> float
    
    peric("Pi is approximately: {pi}")
    peric("Price: ${price}")
    
    deschodt 0
```

Output:
```
Pi is approximately: 3.14159
Price: $19.99
```

### Strings
```tsl
Deschodt Eric() -> int
    eric name = "Alice" -> string
    eric greeting = "Hello" -> string
    
    peric("{greeting}, {name}!")
    
    deschodt 0
```

Output:
```
Hello, Alice!
```

### Booleans
```tsl
Deschodt Eric() -> int
    eric isActive = #t -> bool
    eric isComplete = #f -> bool
    
    peric("Active: {isActive}")
    peric("Complete: {isComplete}")
    
    deschodt 0
```

Output:
```
Active: #t
Complete: #f
```

### Characters
```tsl
Deschodt Eric() -> int
    eric initial = #\A -> char
    eric symbol = #\@ -> char
    
    peric("Initial: {initial}")
    peric("Symbol: {symbol}")
    
    deschodt 0
```

Output:
```
Initial: A
Symbol: @
```

## String Interpolation

Inside strings, use `{variable}` to insert variable values:

```tsl
Deschodt Eric() -> int
    eric user = "Bob" -> string
    eric age = 25 -> int
    eric score = 95.5 -> float
    
    peric("Hello {user}!")
    peric("You are {age} years old")
    peric("Your score: {score}%")
    
    deschodt 0
```

Output:
```
Hello Bob!
You are 25 years old
Your score: 95.5%
```

## Multiple Prints

Use multiple `peric` calls to print on separate lines:

```tsl
Deschodt Eric() -> int
    peric("First line")
    peric("Second line")
    peric("Third line")
    
    deschodt 0
```

Output:
```
First line
Second line
Third line
```

## Printing Expressions

You can print the result of expressions directly:

```tsl
Deschodt Eric() -> int
    peric("2 + 3 = {2 + 3}")
    peric("10 * 5 = {10 * 5}")
    peric("20 / 4 = {20 / 4}")
    
    deschodt 0
```

Output:
```
2 + 3 = 5
10 * 5 = 50
20 / 4 = 5
```

## Printing Array Elements

```tsl
Deschodt Eric() -> int
    eric scores -> int[]
    scores[0] = 85
    scores[1] = 92
    scores[2] = 78
    
    aer i in range(0, 3):
        peric("Score {i}: {scores[i]}")
    
    deschodt 0
```

Output:
```
Score 0: 85
Score 1: 92
Score 2: 78
```

## Printing Struct Fields

```tsl
destruct Person
    name -> string
    age -> int
    city -> string

Deschodt Eric() -> int
    eric person -> Person
    person.name = "Charlie"
    person.age = 30
    person.city = "New York"
    
    peric("Name: {person.name}")
    peric("Age: {person.age}")
    peric("City: {person.city}")
    
    deschodt 0
```

Output:
```
Name: Charlie
Age: 30
City: New York
```

## Formatted Output Examples

### Table-like Output
```tsl
Deschodt Eric() -> int
    peric("Item     | Price | Qty")
    peric("---------+-------+----")
    peric("Apple    | 0.50  | 5")
    peric("Banana   | 0.30  | 3")
    peric("Orange   | 0.75  | 7")
    
    deschodt 0
```

Output:
```
Item     | Price | Qty
---------+-------+----
Apple    | 0.50  | 5
Banana   | 0.30  | 3
Orange   | 0.75  | 7
```

### Progress Report
```tsl
Deschodt Eric() -> int
    eric completed = 7 -> int
    eric total = 10 -> int
    eric percent = completed * 100 / total -> int
    
    peric("Progress: {percent}%")
    peric("Completed: {completed}/{total}")
    
    deschodt 0
```

Output:
```
Progress: 70%
Completed: 7/10
```

## Practical Example: Student Report Card

```tsl
destruct Subject
    name -> string
    score -> int

Deschodt Eric() -> int
    eric math -> Subject
    math.name = "Mathematics"
    math.score = 85
    
    eric english -> Subject
    english.name = "English"
    english.score = 92
    
    eric science -> Subject
    science.name = "Science"
    science.score = 88
    
    peric("===== REPORT CARD =====")
    peric("")
    peric("Subject      | Score")
    peric("-------------+------")
    peric("{math.name}       | {math.score}")
    peric("{english.name}        | {english.score}")
    peric("{science.name}        | {science.score}")
    peric("")
    
    eric total = math.score + english.score + science.score -> int
    eric average = total / 3 -> int
    peric("Average: {average}")
    
    deschodt 0
```

Output:
```
===== REPORT CARD =====

Subject      | Score
-------------+------
Mathematics  | 85
English      | 92
Science      | 88

Average: 88
```

## Practical Example: Calculation Output

```tsl
Deschodt Eric() -> int
    eric base = 5 -> int
    eric height = 3 -> int
    
    eric area = base * height / 2 -> int
    
    peric("Triangle Calculator")
    peric("==================")
    peric("Base: {base}")
    peric("Height: {height}")
    peric("Area: {area} square units")
    
    deschodt 0
```

Output:
```
Triangle Calculator
==================
Base: 5
Height: 3
Area: 7 square units
```

## Practical Example: Loop Output with Labels

```tsl
Deschodt Eric() -> int
    peric("Multiplication Table (7s)")
    peric("==========================")
    
    aer i in range(1, 11):
        eric result = 7 * i -> int
        peric("7 × {i} = {result}")
    
    deschodt 0
```

Output:
```
Multiplication Table (7s)
==========================
7 × 1 = 7
7 × 2 = 14
7 × 3 = 21
7 × 4 = 28
7 × 5 = 35
7 × 6 = 42
7 × 7 = 49
7 × 8 = 56
7 × 9 = 63
7 × 10 = 70
```

## Practical Example: Status Messages

```tsl
Deschodt Eric() -> int
    eric itemsSold = 150 -> int
    eric targetSales = 200 -> int
    eric percentOfTarget = itemsSold * 100 / targetSales -> int
    
    peric("SALES REPORT")
    peric("============")
    peric("Items Sold: {itemsSold}")
    peric("Target: {targetSales}")
    peric("Achievement: {percentOfTarget}%")
    
    erif (itemsSold >= targetSales):
        peric("Status: GOAL REACHED!")
    deschelse:
        eric remaining = targetSales - itemsSold -> int
        peric("Status: {remaining} more to go")
    
    deschodt 0
```

Output:
```
SALES REPORT
============
Items Sold: 150
Target: 200
Achievement: 75%
Status: 75 more to go
```

## Reading User Input with romaric

Use the `romaric` function to read input from the user. It prompts with a message and returns the user's input as a string:

```tsl
Deschodt Eric() -> int
    eric name = romaric("Enter your name: ") -> string
    peric("Hello, {name}!")
    deschodt 0
```

Interaction:
```
Enter your name: Alice
Hello, Alice!
```

### Multiple Inputs

```tsl
Deschodt Eric() -> int
    eric firstName = romaric("First name: ") -> string
    eric lastName = romaric("Last name: ") -> string
    eric age = romaric("Age: ") -> string
    
    peric("Welcome {firstName} {lastName}, age {age}")
    
    deschodt 0
```

Interaction:
```
First name: John
Last name: Doe
Age: 30
Welcome John Doe, age 30
```

## Reading Files with renaud

Use the `renaud` function to read the entire content of a file into a string:

```tsl
Deschodt Eric() -> int
    eric content = renaud("input.txt") -> string
    peric("File contents:")
    peric(content)
    deschodt 0
```

This reads the file `input.txt` and stores its entire content in the `content` variable.

### Processing File Data

```tsl
Deschodt Eric() -> int
    eric data = renaud("data.txt") -> string
    peric("Data loaded successfully")
    peric("Length: {data}")
    
    deschodt 0
```

## Writing Files with marvin

Use the `marvin` function to write content to a file:

```tsl
Deschodt Eric() -> int
    eric message = "Hello, File!" -> string
    marvin("output.txt", message)
    peric("Written to output.txt")
    
    deschodt 0
```

This creates (or overwrites) the file `output.txt` with the content in `message`.

### Writing Multiple Values

```tsl
Deschodt Eric() -> int
    eric line1 = "First line" -> string
    eric line2 = "Second line" -> string
    eric content = line1 + "\n" + line2 -> string
    
    marvin("report.txt", content)
    peric("Report saved")
    
    deschodt 0
```

## Practical Example: Interactive Program

```tsl
Deschodt Eric() -> int
    eric name = romaric("What is your name? ") -> string
    eric age = romaric("What is your age? ") -> string
    eric city = romaric("What city do you live in? ") -> string
    
    eric info = "Name: " + name + ", Age: " + age + ", City: " + city -> string
    
    marvin("profile.txt", info)
    peric("Profile saved to profile.txt")
    
    deschodt 0
```

Interaction:
```
What is your name? Alice
What is your age? 28
What city do you live in? Paris
Profile saved to profile.txt
```

## Practical Example: Reading and Processing Files

```tsl
Deschodt Eric() -> int
    eric original = renaud("source.txt") -> string
    peric("Original content:")
    peric(original)
    peric("")
    
    eric processed = original -> string
    desnote In practice, you would process the content here
    
    marvin("output.txt", processed)
    peric("Processed content saved to output.txt")
    
    deschodt 0
```

## Practical Example: File Concatenation

```tsl
Deschodt Eric() -> int
    eric file1Content = renaud("file1.txt") -> string
    eric file2Content = renaud("file2.txt") -> string
    
    eric combined = file1Content + "\n---\n" + file2Content -> string
    marvin("combined.txt", combined)
    
    peric("Files combined into combined.txt")
    
    deschodt 0
```

## Debugging with Output

Use `peric` to debug your program by printing variable values:

```tsl
Deschodt Eric() -> int
    eric x = 10 -> int
    peric("DEBUG: x = {x}")
    
    x = x + 5
    peric("DEBUG: after +5, x = {x}")
    
    x = x * 2
    peric("DEBUG: after *2, x = {x}")
    
    deschodt 0
```

Output:
```
DEBUG: x = 10
DEBUG: after +5, x = 15
DEBUG: after *2, x = 30
```

This helps you trace execution and find mistakes.

## Common Output Mistakes

### Missing Interpolation Braces
```tsl
eric value = 42 -> int
peric("Value: value")     desnote ERROR - prints literal "value"
peric("Value: {value}")   desnote CORRECT - prints "Value: 42"
```

### Wrong Variable Name
```tsl
eric count = 5 -> int
peric("Count: {cout}")    desnote ERROR - 'cout' not defined
peric("Count: {count}")   desnote CORRECT
```

### Type Mismatches (Auto-converted)
```tsl
eric x = 42 -> int
peric("X: {x}")           desnote Works - prints "X: 42"
```

Most type conversions happen automatically when printing.

## Best Practices

1. **Clear Labels**: Always label what you're printing
2. **Consistent Formatting**: Keep your output format consistent
3. **Helpful Messages**: Use messages that help users understand the output
4. **Debug Markers**: Prefix debug output with "DEBUG:" for easy filtering
5. **Separate Sections**: Use blank lines to separate logical sections
6. **User-Friendly**: Make output readable and well-organized
7. **Test Output**: Verify output looks correct before finalizing

## Next Steps

- Combine I/O with **[Functions](functions.md)** to create reusable input/output routines
- Use **[Loops](loops.md)** with `peric` to print patterns and tables
- Build interactive programs with `romaric` for user input
- Manage data files with `renaud` and `marvin` for persistence
- Format **[Structs](structs.md)** output for complex data display
- Print **[Arrays](lists.md)** with loops for detailed reports
