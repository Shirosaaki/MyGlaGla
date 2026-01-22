# Funktionen - Code organisieren

Funktionen ermöglichen es dir, wiederverwendbare Codeblöcke zu schreiben. Sie nehmen Parameter entgegen, führen Operationen aus und geben ein Ergebnis zurück.

## Grundlegende Funktionsdefinition

```tsl
Deschodt add(a -> int, b -> int) -> int
    deschodt a + b

Deschodt Eric() -> int
    eric result = add(5, 3) -> int
    peric("Result: {result}")
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
Result: 8
```

**Syntax:**
- `Deschodt functionName(param1 -> type1, param2 -> type2) -> returnType`
- `deschodt` gibt einen Wert zurück und verlässt die Funktion
- Alle Parameter müssen Typannotationen haben
- Der Rückgabewert muss ausdrücklich angegeben werden

## Funktion ohne Parameter

```tsl
Deschodt greet() -> string
    deschodt "Hello, World!"

Deschodt Eric() -> int
    eric message = greet() -> string
    peric("{message}")
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
Hello, World!
```

## Funktion ohne Rückgabewert (void)

```tsl
Deschodt printMessage(msg -> string) -> void
    peric("Message: {msg}")

Deschodt Eric() -> int
    printMessage("Hello")
    printMessage("World")
    deschodt 0
```

I'm sorry, but it seems that you haven't provided the Markdown chunk you'd like me to translate. Please share the text, and I'll be happy to assist you with the translation into German (DE).
```
Message: Hello
Message: World
```

Wenn der Rückgabewert `void` ist, geben Sie keinen Wert zurück (oder `deschodt` wird weggelassen).

## Mehrere Parameter

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

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
3 * 4 = 12
2^5 = 32
```

## Verschiedene Rückgabetypen

Funktionen können jeden Typ zurückgeben:

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

## Bedingte Rückgabe

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

I'm sorry, but it seems you haven't provided the Markdown chunk to translate. Please share the content you'd like me to translate into German, and I'll be happy to assist!
```
Grade: B
```

## Funktionsaufruf

Funktionen können andere Funktionen aufrufen:

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

## Rekursion

Funktionen können sich selbst aufrufen, um Probleme rekursiv zu lösen:

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

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
5! = 120
```

## Arrays an Funktionen übergeben

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

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
Sum: 60
```

## Zeiger übergeben (Referenz)

Verwenden Sie Zeiger, um Werte innerhalb einer Funktion zu ändern:

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

Please provide the Markdown chunk you would like me to translate into German (DE).
```
Before: 10
After: 11
```

## Funktion mit mehreren Austrittspunkten

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

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
Status: Pass
```

## Praktisches Beispiel: Primzahlprüfer

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

## Praktisches Beispiel: Fibonacci-Folge

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

Sure! Please provide the Markdown chunk you'd like me to translate into German (DE).
```
fib(0) = 0
fib(1) = 1
fib(2) = 1
fib(3) = 2
fib(4) = 3
fib(5) = 5
fib(6) = 8
```

## Praktisches Beispiel: Zeichenfolgenverarbeitungsfunktion

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

## Häufige Fehler

### Vergessen des Rückgabetyps
```tsl
Deschodt add(a -> int, b -> int)    desnote ERROR - missing return type
Deschodt add(a -> int, b -> int) -> int  desnote CORRECT
```

### Parameter Typeninkonsistenz
```tsl
Deschodt greet(name -> string) -> string
    deschodt "Hello, {name}"

Eric() -> int
    greet(42)      desnote ERROR - passed int, expected string
    greet("Bob")   desnote CORRECT
```

### Vergessen deschodt
```tsl
Deschodt getValue() -> int
    eric value = 10 -> int
    desnote ERROR - no return statement

Deschodt getValue() -> int
    eric value = 10 -> int
    deschodt value  desnote CORRECT
```

### Stack Overflow mit Rekursion
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

1. **Einzelne Verantwortung**: Jede Funktion sollte eine Aufgabe gut erfüllen
2. **Klare Namen**: Verwenden Sie beschreibende Funktionsnamen, die erklären, was sie tun
3. **Zweck dokumentieren**: Fügen Sie Kommentare hinzu, die erklären, was die Funktion macht
4. **Eingaben validieren**: Überprüfen Sie, ob die Parameter gültig sind
5. **Frühe Rückgabe**: Geben Sie früh zurück, wenn möglich, um die Logik zu vereinfachen
6. **Tiefe Verschachtelung vermeiden**: Halten Sie Funktionen einfach und lesbar

## Next Steps

- Kombinieren Sie Funktionen mit **[Schleifen](loops.md)** für leistungsstarke Muster
- Verwenden Sie **[Arrays](lists.md)** mit Funktionen zur Datenverarbeitung
- Erkunden Sie **[Strukturen](structs.md)**, um komplexe Daten an Funktionen zu übergeben
