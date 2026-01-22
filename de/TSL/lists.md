# Arrays (Listen) - Mehrere Werte speichern

Arrays speichern mehrere Werte desselben Typs in sequenzieller Reihenfolge. Sie ermöglichen es Ihnen, mit Datensammlungen zu arbeiten, bei denen alle Indizes von 0 bis zum höchsten verwendeten Index automatisch gefüllt werden.

## Ein Array erstellen

```tsl
Deschodt Eric() -> int
    eric numbers -> int[]
    eric names -> string[]
    eric flags -> bool[]
    deschodt 0
```

**Syntax:**
- `eric variableName -> type[]` deklariert ein Array dieses Typs
- Arrays können `int`, `float`, `string`, `char`, `bool` oder benutzerdefinierte Typen enthalten

## Array-Werte festlegen

Arrays verwenden die Indexnotation mit eckigen Klammern `[]`. Indizes beginnen bei `0`:

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

Sure! Please provide the Markdown chunk you'd like me to translate into German (DE).
```
First score: 95
Third score: 92
```

## Zugriff auf Array-Elemente

Verwenden Sie den Index `[n]`, um Werte zu lesen:

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

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
Colors: red, green
```

## Durchlaufen von Arrays mit `aer`

Verwenden Sie die `aer` (for-in) Schleife, um durch die Indizes des Arrays zu iterieren:

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

I'm sorry, but it seems that you haven't provided the Markdown chunk that needs to be translated. Please share the text you'd like me to work on, and I'll be happy to assist you with the translation into German (DE).
```
numbers[0] = 10
numbers[1] = 20
numbers[2] = 30
numbers[3] = 40
```

## Verständnis von sequenzieller Vorwärtsfüllung

Wenn Sie ein Array-Element am Index N festlegen, werden automatisch alle Indizes von 0 bis N-1 mit dem zuletzt festgelegten Wert gefüllt. Dies wird als **sequenzielle Vorwärtsfüllung** bezeichnet:

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

Sure! Please provide the Markdown chunk you'd like me to translate into German (DE).
```
data[0] = 50
data[1] = 50
data[2] = 20
```

### Ein weiteres Beispiel

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

Sure! Please provide the Markdown chunk you'd like me to translate into German (DE).
```
numbers[0] = 100
numbers[1] = 100
numbers[2] = 100
numbers[3] = 100
numbers[4] = 100
numbers[5] = 200
```

**Wichtig:** Im Gegensatz zu spärlichen Arrays in anderen Sprachen können Sie keine "Lücken" oder "undefinierten" Indizes haben. Wenn Sie `data[0]=50` und dann `data[100]=20` setzen, entsteht ein Array mit 101 Elementen, wobei die Indizes 1-99 automatisch mit 50 gefüllt werden.

## Array von Zeichenfolgen

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

Sure, please provide the Markdown chunk you would like me to translate into German (DE).
```
Fruit 0: apple
Fruit 1: banana
Fruit 2: orange
Fruit 3: grape
```

## Array von Fließkommazahlen

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

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
Day 0: 20.5°C
Day 1: 22.3°C
Day 2: 18.7°C
Day 3: 25.0°C
```

## Berechnungen mit Arrays

### Summe der Array-Elemente

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

Sure! Please provide the Markdown chunk that you would like to have translated into German (DE).
```
Total: 100
```

### Maximale Werte finden

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

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
Highest score: 95
```

### Zählen von Elementen

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

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
Found 5 2 times
```

## Arrays von Booleans

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

I'm sorry, but it seems that you haven't provided the Markdown chunk that needs to be translated. Please share the content you'd like me to work on, and I'll be happy to assist you with the translation!
```
True values: 3
```

## Arrays an Funktionen übergeben

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

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
Average: 87.5
```

## Array von Zeichen

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

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
Letter 0: a
Letter 1: b
Letter 2: c
```

## Verständnis der Array-Größe

Durch die sequenzielle Vorwärtsfüllung wird die Array-Größe durch den höchsten von Ihnen festgelegten Index plus eins bestimmt. Alle niedrigeren Indizes werden automatisch erstellt und gefüllt:

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

**Wichtig:** Sie können nicht auf Indizes zugreifen, die über das hinausgehen, was durch Ihre Zuweisungen erstellt wurde. Die Größe des Arrays wächst, wenn Sie höhere Indizes ansprechen, aber Sie müssen zuerst einen Wert an diesem Index festlegen.

## Praktisches Beispiel: Multiplikationstabelle

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

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
7 × 1 = 7
7 × 2 = 14
7 × 3 = 21
...
7 × 10 = 70
```

## Praktisches Beispiel: Notenvergabe

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

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
Score 92: Grade A
Score 78: Grade C
Score 65: Grade F
Score 88: Grade B
Score 95: Grade A
```

## Praktisches Beispiel: Minimalwert finden

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

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
Minimum: 7
```

## Häufige Fehler

### Vergessen des Array-Typs
```tsl
eric data -> int[]        desnote CORRECT
eric data -> []           desnote ERROR - must specify type
```

### Nichtverstehen von sequenzieller Fill-Forward
```tsl
eric arr -> int[]
arr[0] = 10
arr[2] = 30              desnote This creates [10, 10, 30] - index 1 auto-filled!
eric x = arr[1] -> int   desnote This is valid and equals 10 (auto-filled)
```

### Typkonflikt im Array
```tsl
eric numbers -> int[]
numbers[0] = 10          desnote CORRECT
numbers[1] = "ten"       desnote ERROR - string in int array
```

### Schleifen außerhalb der Grenzen
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

1. **Verstehen Sie Fill-Forward**: Denken Sie daran, dass das Setzen eines hohen Index alle Zwischenindizes mit dem vorherigen Wert füllt.
2. **Array-Größe verfolgen**: Behalten Sie im Auge, was Ihr höchster Index ist (der die Array-Größe bestimmt).
3. **Kontinuierliche Indizes verwenden**: Setzen Sie typischerweise die Indizes 0, 1, 2... in Reihenfolge für klareren Code.
4. **Schleifen-Grenzen anpassen**: Ihr Schleifenbereich sollte der tatsächlichen Array-Größe entsprechen (höchster Index + 1).
5. **Funktionen verwenden**: Extrahieren Sie Array-Operationen in Funktionen zur Wiederverwendung.
6. **Array-Länge dokumentieren**: Fügen Sie Kommentare zur erwarteten Array-Größe hinzu.

## Next Steps

- Kombinieren Sie Arrays mit **[Functions](functions.md)**, um Daten zu verarbeiten.
- Verwenden Sie Arrays in **[Loops](loops.md)** für Iterationen.
- Speichern Sie Arrays in **[Structs](structs.md)** für komplexe Datenstrukturen.
