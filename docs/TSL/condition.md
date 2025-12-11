# Conditionals - Making Decisions

Conditionals let your program make decisions and execute different code based on conditions. Use `erif` (if) and `deschelse` (else) statements.

## Basic If Statement

```tsl
Deschodt Eric() -> int
    eric age = 20 -> int

    erif (age >= 18):
        peric("You are an adult")
    
    deschodt 0
```

If the condition is true, the code block executes. Otherwise, it's skipped.

## If-Else Statement

```tsl
Deschodt Eric() -> int
    eric age = 15 -> int

    erif (age >= 18):
        peric("Majeur")        desnote adult
    deschelse:
        peric("Mineur")        desnote minor
    
    deschodt 0
```

Output:
```
Mineur
```

## Comparison Operators

Use these to create conditions:

| Operator | Meaning | Example |
|----------|---------|---------|
| `==` | Equal to | `x == 5` |
| `!=` | Not equal to | `x != 5` |
| `<` | Less than | `x < 10` |
| `>` | Greater than | `x > 0` |
| `<=` | Less than or equal | `x <= 5` |
| `>=` | Greater than or equal | `x >= 18` |

## Logical Operators

Combine multiple conditions:

| Operator | Meaning | Example |
|----------|---------|---------|
| `&&` | AND (both true) | `(age >= 18) && (score > 75)` |
| `\|\|` | OR (at least one true) | `(day == 0) \|\| (day == 6)` |
| `!` | NOT (reverse true/false) | `!(x == 0)` |

## Examples with Logical Operators

### AND - All conditions must be true

```tsl
Deschodt Eric() -> int
    eric age = 25 -> int
    eric score = 85 -> int
    
    erif ((age >= 18) && (score >= 80)):
        peric("Eligible for the job!")
    deschelse:
        peric("Not eligible")
    
    deschodt 0
```

Output:
```
Eligible for the job!
```

### OR - At least one condition must be true

```tsl
Deschodt Eric() -> int
    eric day = 0 -> int     desnote 0 = Sunday
    
    erif ((day == 0) || (day == 6)):
        peric("It's the weekend!")
    deschelse:
        peric("It's a weekday")
    
    deschodt 0
```

Output:
```
It's the weekend!
```

### NOT - Reverse the condition

```tsl
Deschodt Eric() -> int
    eric isRaining = #f
    
    erif (!(isRaining)):
        peric("Let's go outside!")
    deschelse:
        peric("Stay inside")
    
    deschodt 0
```

Output:
```
Let's go outside!
```

## Nested Conditionals

You can nest `erif` statements inside each other:

```tsl
Deschodt Eric() -> int
    eric age = 25 -> int
    eric hasLicense = #t
    
    erif (age >= 18):
        erif (hasLicense):
            peric("You can drive")
        deschelse:
            peric("Get a license first")
    deschelse:
        peric("You must be 18 to drive")
    
    deschodt 0
```

Output:
```
You can drive
```

## Multiple Conditions with Better Code Style

Instead of deeply nested if-else, use multiple conditions:

```tsl
Deschodt classify(age -> int) -> string
    erif (age < 13):
        deschodt "Child"
    deschelse:
        erif ((age >= 13) && (age < 18)):
            deschodt "Teenager"
        deschelse:
            erif (age >= 18):
                deschodt "Adult"
            deschelse:
                deschodt "Unknown"

Deschodt Eric() -> int
    eric age = 16 -> int
    eric category = classify(age) -> string
    peric("Category: {category}")
    deschodt 0
```

Output:
```
Category: Teenager
```

## Boolean Variables

Create variables that store true/false values:

```tsl
Deschodt Eric() -> int
    eric isStudent = #t
    eric hasJobExperience = #f
    eric canApply = #f
    
    erif (isStudent && (! hasJobExperience)):
        canApply = #t
    
    erif (canApply):
        peric("You can apply for the internship!")
    
    deschodt 0
```

Output:
```
You can apply for the internship!
```

## Real-World Example: Grade Calculator

```tsl
Deschodt Eric() -> int
    eric score = 85 -> int
    eric grade -> string
    
    erif (score >= 90):
        grade = "A"
    deschelse:
        erif (score >= 80):
            grade = "B"
        deschelse:
            erif (score >= 70):
                grade = "C"
            deschelse:
                erif (score >= 60):
                    grade = "D"
                deschelse:
                    grade = "F"
    
    peric("Score: {score} -> Grade: {grade}")
    deschodt 0
```

Output:
```
Score: 85 -> Grade: B
```

## Switch-like Pattern (Multiple Checks)

```tsl
Deschodt Eric() -> int
    eric day = 2 -> int
    eric dayName -> string
    
    erif (day == 0):
        dayName = "Monday"
    deschelse:
        erif (day == 1):
            dayName = "Tuesday"
        deschelse:
            erif (day == 2):
                dayName = "Wednesday"
            deschelse:
                dayName = "Other"
    
    peric("Day: {dayName}")
    deschodt 0
```

Output:
```
Day: Wednesday
```

## Common Mistakes

### Using `=` Instead of `==`
```tsl
erif (x = 5):       desnote ERROR - assignment, not comparison
erif (x == 5):      desnote CORRECT - comparison
```

### Missing Parentheses
```tsl
erif age >= 18:     desnote ERROR - needs parentheses
erif (age >= 18):   desnote CORRECT
```

### Forgetting deschelse
```tsl
erif (x == 5):
    peric("x is 5")
desnote deschelse is optional - no error here
```

## Next Steps

- Learn **[Loops](loops.md)** to repeat code based on conditions
- Explore **[Functions](functions.md)** to organize conditional logic
- Discover **[Arrays](lists.md)** and iterate with conditions
