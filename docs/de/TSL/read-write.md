# Eingabe & Ausgabe - Kommunikation mit Ihrem Programm

Eingabe- und Ausgabe (I/O) Operationen ermöglichen es Ihrem Programm, Informationen an den Benutzer anzuzeigen und möglicherweise Informationen von ihm zu erhalten.

## Ausgabe mit peric

Die `peric` Funktion gibt Text auf dem Bildschirm aus. Es ist die Hauptmethode, um Ausgaben anzuzeigen:

```tsl
Deschodt Eric() -> int
    peric("Hello, World!")
    peric("This is my first program")
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
Hello, World!
This is my first program
```

## Drucken verschiedener Typen

### Ganzzahlen
```tsl
Deschodt Eric() -> int
    eric count = 42 -> int
    peric("Count: {count}")
    
    eric sum = 10 + 20 + 30 -> int
    peric("Sum: {sum}")
    
    deschodt 0
```

Sure, please provide the Markdown chunk that you would like me to translate into German (DE).
```
Count: 42
Sum: 60
```

### Fließende Elemente
```tsl
Deschodt Eric() -> int
    eric pi = 3.14159 -> float
    eric price = 19.99 -> float
    
    peric("Pi is approximately: {pi}")
    peric("Price: ${price}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
Pi is approximately: 3.14159
Price: $19.99
```

### Zeichenfolgen
```tsl
Deschodt Eric() -> int
    eric name = "Alice" -> string
    eric greeting = "Hello" -> string
    
    peric("{greeting}, {name}!")
    
    deschodt 0
```

I'm sorry, but it seems you haven't provided the Markdown chunk that needs to be translated. Please share the content you'd like me to work on, and I'll be happy to assist you with the translation!
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

Sure, please provide the Markdown chunk that you would like me to translate into German (DE).
```
Active: #t
Complete: #f
```

### Charaktere
```tsl
Deschodt Eric() -> int
    eric initial = #\A -> char
    eric symbol = #\@ -> char
    
    peric("Initial: {initial}")
    peric("Symbol: {symbol}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
Initial: A
Symbol: @
```

## String-Interpolation

Innerhalb von Strings verwenden Sie `{variable}`, um Variablenwerte einzufügen:

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

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
Hello Bob!
You are 25 years old
Your score: 95.5%
```

## Mehrere Ausgaben

Verwenden Sie mehrere `peric`-Aufrufe, um auf separaten Zeilen auszugeben:

```tsl
Deschodt Eric() -> int
    peric("First line")
    peric("Second line")
    peric("Third line")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
First line
Second line
Third line
```

## Ausdrucke drucken

Sie können das Ergebnis von Ausdrücken direkt drucken:

```tsl
Deschodt Eric() -> int
    peric("2 + 3 = {2 + 3}")
    peric("10 * 5 = {10 * 5}")
    peric("20 / 4 = {20 / 4}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
2 + 3 = 5
10 * 5 = 50
20 / 4 = 5
```

## Drucken von Array-Elementen

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

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
Score 0: 85
Score 1: 92
Score 2: 78
```

## Drucken von Strukturfeldern

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

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
Name: Charlie
Age: 30
City: New York
```

## Formatierte Ausgabebeispiele

### Tabellenähnliche Ausgabe
```tsl
Deschodt Eric() -> int
    peric("Item     | Price | Qty")
    peric("---------+-------+----")
    peric("Apple    | 0.50  | 5")
    peric("Banana   | 0.30  | 3")
    peric("Orange   | 0.75  | 7")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
Item     | Price | Qty
---------+-------+----
Apple    | 0.50  | 5
Banana   | 0.30  | 3
Orange   | 0.75  | 7
```

### Fortschrittsbericht
```tsl
Deschodt Eric() -> int
    eric completed = 7 -> int
    eric total = 10 -> int
    eric percent = completed * 100 / total -> int
    
    peric("Progress: {percent}%")
    peric("Completed: {completed}/{total}")
    
    deschodt 0
```

I'm sorry, but it seems that you haven't provided the Markdown chunk that you would like me to translate into German (DE). Please share the text, and I'll be happy to assist you with the translation!
```
Progress: 70%
Completed: 7/10
```

## Praktisches Beispiel: Schülerzeugnis

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

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
===== REPORT CARD =====

Subject      | Score
-------------+------
Mathematics  | 85
English      | 92
Science      | 88

Average: 88
```

## Praktisches Beispiel: Berechnungsausgabe

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

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
Triangle Calculator
==================
Base: 5
Height: 3
Area: 7 square units
```

## Praktisches Beispiel: Schleifen-Ausgabe mit Beschriftungen

```tsl
Deschodt Eric() -> int
    peric("Multiplication Table (7s)")
    peric("==========================")
    
    aer i in range(1, 11):
        eric result = 7 * i -> int
        peric("7 × {i} = {result}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
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

## Praktisches Beispiel: Statusnachrichten

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

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
SALES REPORT
============
Items Sold: 150
Target: 200
Achievement: 75%
Status: 75 more to go
```

## Benutzereingaben mit romaric lesen

Verwende die `romaric`-Funktion, um Eingaben vom Benutzer zu lesen. Sie zeigt eine Nachricht an und gibt die Eingabe des Benutzers als Zeichenfolge zurück:

```tsl
Deschodt Eric() -> int
    eric name = romaric("Enter your name: ") -> string
    peric("Hello, {name}!")
    deschodt 0
```
```markdown
Interaktion:
``````
Enter your name: Alice
Hello, Alice!
```

### Mehrere Eingaben

```tsl
Deschodt Eric() -> int
    eric firstName = romaric("First name: ") -> string
    eric lastName = romaric("Last name: ") -> string
    eric age = romaric("Age: ") -> string
    
    peric("Welcome {firstName} {lastName}, age {age}")
    
    deschodt 0
```

Interaktion:
```
First name: John
Last name: Doe
Age: 30
Welcome John Doe, age 30
```

## Dateien mit renaud lesen

Verwenden Sie die `renaud`-Funktion, um den gesamten Inhalt einer Datei in einen String zu lesen:

```tsl
Deschodt Eric() -> int
    eric content = renaud("input.txt") -> string
    peric("File contents:")
    peric(content)
    deschodt 0
```

Dies liest die Datei `input.txt` und speichert ihren gesamten Inhalt in der Variable `content`.

### Verarbeiten von Dateidaten

```tsl
Deschodt Eric() -> int
    eric data = renaud("data.txt") -> string
    peric("Data loaded successfully")
    peric("Length: {data}")
    
    deschodt 0
```

## Dateien mit marvin schreiben

Verwenden Sie die `marvin`-Funktion, um Inhalte in eine Datei zu schreiben:

```tsl
Deschodt Eric() -> int
    eric message = "Hello, File!" -> string
    marvin("output.txt", message)
    peric("Written to output.txt")
    
    deschodt 0
```

Dies erstellt (oder überschreibt) die Datei `output.txt` mit dem Inhalt in `message`.

### Mehrere Werte schreiben

```tsl
Deschodt Eric() -> int
    eric line1 = "First line" -> string
    eric line2 = "Second line" -> string
    eric content = line1 + "\n" + line2 -> string
    
    marvin("report.txt", content)
    peric("Report saved")
    
    deschodt 0
```

## Praktisches Beispiel: Interaktives Programm

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

Interaktion:
```
What is your name? Alice
What is your age? 28
What city do you live in? Paris
Profile saved to profile.txt
```

## Praktisches Beispiel: Lesen und Verarbeiten von Dateien

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

## Praktisches Beispiel: Datei-Verkettung

```tsl
Deschodt Eric() -> int
    eric file1Content = renaud("file1.txt") -> string
    eric file2Content = renaud("file2.txt") -> string
    
    eric combined = file1Content + "\n---\n" + file2Content -> string
    marvin("combined.txt", combined)
    
    peric("Files combined into combined.txt")
    
    deschodt 0
```

## Debugging mit Ausgaben

Verwende `peric`, um dein Programm zu debuggen, indem du die Werte von Variablen ausgibst:

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

Sure! Please provide the Markdown chunk you'd like me to translate into German (DE).
```
DEBUG: x = 10
DEBUG: after +5, x = 15
DEBUG: after *2, x = 30
```

Dies hilft Ihnen, die Ausführung nachzuvollziehen und Fehler zu finden.

## Häufige Ausgabefehler

### Fehlende Interpolationsklammern
```tsl
eric value = 42 -> int
peric("Value: value")     desnote ERROR - prints literal "value"
peric("Value: {value}")   desnote CORRECT - prints "Value: 42"
```

### Falscher Variablenname
```tsl
eric count = 5 -> int
peric("Count: {cout}")    desnote ERROR - 'cout' not defined
peric("Count: {count}")   desnote CORRECT
```

### Typinkonsistenzen (Automatisch konvertiert)
```tsl
eric x = 42 -> int
peric("X: {x}")           desnote Works - prints "X: 42"
```

Most type conversions happen automatically when printing.

## Best Practices

1. **Klare Beschriftungen**: Beschriften Sie immer, was Sie drucken
2. **Konsistente Formatierung**: Halten Sie Ihr Ausgabeformat konsistent
3. **Hilfreiche Nachrichten**: Verwenden Sie Nachrichten, die den Benutzern helfen, die Ausgabe zu verstehen
4. **Debug-Markierungen**: Fügen Sie der Debug-Ausgabe "DEBUG:" voran, um die Filterung zu erleichtern
5. **Getrennte Abschnitte**: Verwenden Sie Leerzeilen, um logische Abschnitte zu trennen
6. **Benutzerfreundlich**: Gestalten Sie die Ausgabe lesbar und gut organisiert
7. **Ausgabe testen**: Überprüfen Sie, ob die Ausgabe korrekt aussieht, bevor Sie sie finalisieren

## Next Steps

- Kombinieren Sie I/O mit **[Funktionen](functions.md)**, um wiederverwendbare Eingabe-/Ausgabeverfahren zu erstellen
- Verwenden Sie **[Schleifen](loops.md)** mit `peric`, um Muster und Tabellen zu drucken
- Erstellen Sie interaktive Programme mit `romaric` für Benutzereingaben
- Verwalten Sie Datendateien mit `renaud` und `marvin` für Persistenz
- Formatieren Sie **[Strukturen](structs.md)**-Ausgaben für die Anzeige komplexer Daten
- Drucken Sie **[Arrays](lists.md)** mit Schleifen für detaillierte Berichte
