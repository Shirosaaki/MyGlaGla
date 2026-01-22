# Schleifen - Code wiederholen

Schleifen ermöglichen es dir, Code mehrfach auszuführen, ohne ihn immer wieder neu schreiben zu müssen. TSL bietet zwei Typen: `aer` (for-in) und `darius` (while).

## For-In Schleife (aer)

Die `aer` Schleife durchläuft einen Bereich:

```tsl
Deschodt Eric() -> int
    aer i in range(0, 5):
        peric("i = {i}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
i = 0
i = 1
i = 2
i = 3
i = 4
```

**Wichtige Punkte:**
- `aer i in range(0, 5)` durchläuft die Werte von 0 bis 4 (5 Iterationen)
- Der Bereich ist von `start` bis `end-1` (end ist exklusiv)
- `i` ist die Schleifenvariable, die automatisch inkrementiert wird

## While-Schleife (darius)

Die `darius`-Schleife wiederholt sich, solange eine Bedingung wahr ist:

```tsl
Deschodt Eric() -> int
    eric x = 0 -> int
    
    darius (x < 3):
        peric("x = {x}")
        x = x + 1
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
x = 0
x = 1
x = 2
```

**Wichtige Punkte:**
- Die Bedingung wird vor jeder Iteration überprüft
- Sie müssen den Zähler manuell aktualisieren (`x = x + 1`)
- Wenn die Bedingung niemals wahr ist, wird die Schleife nie ausgeführt

## Schleifensteueranweisungen

### continue - Zur nächsten Iteration springen

`deschontinue` springt zur nächsten Iteration:

```tsl
Deschodt Eric() -> int
    aer i in range(0, 5):
        erif (i == 2):
            deschontinue    desnote skip when i = 2
        peric("i = {i}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
i = 0
i = 1
i = 3
i = 4
```

### break - Schleife verlassen

`deschreak` verlässt die Schleife sofort:

```tsl
Deschodt Eric() -> int
    aer i in range(0, 10):
        erif (i == 5):
            deschreak       desnote exit when i = 5
        peric("i = {i}")
    
    peric("Loop finished")
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
i = 0
i = 1
i = 2
i = 3
i = 4
Loop finished
```

## Komplexes Schleifenbeispiel

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

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
i = 0
i = 1
i = 2
i = 4
i = 5
i = 6
Fin de boucle
```

## Verschachtelte Schleifen

Schleifen können ineinander verschachtelt werden:

```tsl
Deschodt Eric() -> int
    aer i in range(0, 3):
        aer j in range(0, 3):
            peric("({i}, {j})")
    
    deschodt 0
```

Sure, please provide the Markdown chunk you would like me to translate into German (DE).
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

## Über Arrays iterieren

Verwenden Sie Schleifen, um Array-Elemente zu verarbeiten:

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

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
nums[0] = 10
nums[1] = 20
nums[2] = 30
```

## While-Schleife mit Arrays

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

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
arr[0] = 5
arr[1] = 10
arr[2] = 15
```

## Unendliche Schleife (Vorsicht!)

Eine Schleife, die niemals endet:

```tsl
eric counter = 0 -> int
darius (#t):        desnote always true
    peric("Infinite loop: {counter}")
    counter = counter + 1
    erif (counter > 5):
        deschreak   desnote exit manually
```

Sure! Please provide the Markdown chunk that you would like me to translate into German.
```
Infinite loop: 0
Infinite loop: 1
Infinite loop: 2
Infinite loop: 3
Infinite loop: 4
Infinite loop: 5
```

## Praktisches Beispiel: Zahlen summieren

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

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
Sum of 1 to 5: 15
```

## Praktisches Beispiel: Maximum finden

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

Sure, please provide the Markdown chunk that you would like to have translated into German (DE).
```
Maximum: 23
```

## Praktisches Beispiel: Drucke die Multiplikationstabelle

```tsl
Deschodt Eric() -> int
    eric num = 7 -> int
    peric("Multiplication table for {num}:")
    
    aer i in range(1, 11):
        eric product = num * i -> int
        peric("{num} x {i} = {product}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
Multiplication table for 7:
7 x 1 = 7
7 x 2 = 14
7 x 3 = 21
...
7 x 10 = 70
```

## Häufige Fehler

### Off-by-One-Fehler
```tsl
desnote Wants to print 0-4, but range(0, 5) gives 0-4 - this is correct!
aer i in range(0, 5):
    peric("{i}")

desnote Common mistake: forgetting that end is exclusive
aer i in range(0, 4):      desnote Only goes to 3, not 4
    peric("{i}")
```

### Unendliche Schleife mit While
```tsl
eric x = 0 -> int
darius (x < 5):
    peric("{x}")
    desnote Forgot x = x + 1, infinite loop!
```

### Falscher Schleifentyp
```tsl
desnote Use aer when you know how many iterations
aer i in range(0, 5):
    peric("{i}")

desnote Use darius when condition is complex
darius ((x > 0) && (y < 10)):
    x = x - 1
```

## Nächste Schritte

- Lernen Sie **[Funktionen](functions.md)**, um Schleifenlogik zu organisieren
- Entdecken Sie **[Arrays](lists.md)**, um Sammlungen zu verarbeiten
- Verwenden Sie **[Bedingungen](condition.md)** innerhalb von Schleifen
