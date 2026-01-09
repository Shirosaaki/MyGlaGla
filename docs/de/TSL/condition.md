# Bedingungen - Entscheidungen treffen

Bedingungen ermöglichen es deinem Programm, Entscheidungen zu treffen und unterschiedlichen Code basierend auf Bedingungen auszuführen. Verwende `erif` (wenn) und `deschelse` (sonst) Anweisungen.

## Grundlegende Wenn-Anweisung

```tsl
Deschodt Eric() -> int
    eric age = 20 -> int

    erif (age >= 18):
        peric("You are an adult")
    
    deschodt 0
```

Wenn die Bedingung wahr ist, wird der Codeblock ausgeführt. Andernfalls wird er übersprungen.

## If-Else-Anweisung

```tsl
Deschodt Eric() -> int
    eric age = 15 -> int

    erif (age >= 18):
        peric("Majeur")        desnote adult
    deschelse:
        peric("Mineur")        desnote minor
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
Mineur
```

## Vergleichsoperatoren

Verwenden Sie diese, um Bedingungen zu erstellen:

| Operator | Bedeutung | Beispiel |
|----------|-----------|---------|
| `==` | Gleich | `x == 5` |
| `!=` | Ungleich | `x != 5` |
| `<` | Kleiner als | `x < 10` |
| `>` | Größer als | `x > 0` |
| `<=` | Kleiner oder gleich | `x <= 5` |
| `>=` | Größer oder gleich | `x >= 18` |

## Logische Operatoren

Kombinieren Sie mehrere Bedingungen:

| Operator | Bedeutung | Beispiel |
|----------|-----------|---------|
| `&&` | UND (beide wahr) | `(age >= 18) && (score > 75)` |
| `\|\|` | ODER (mindestens eine wahr) | `(day == 0) \|\| (day == 6)` |
| `!` | NICHT (umkehren wahr/falsch) | `!(x == 0)` |

## Beispiele mit logischen Operatoren

### UND - Alle Bedingungen müssen wahr sein

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

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
Eligible for the job!
```

### ODER - Mindestens eine Bedingung muss wahr sein

```tsl
Deschodt Eric() -> int
    eric day = 0 -> int     desnote 0 = Sunday
    
    erif ((day == 0) || (day == 6)):
        peric("It's the weekend!")
    deschelse:
        peric("It's a weekday")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
It's the weekend!
```

### NICHT - Bedingung umkehren

```tsl
Deschodt Eric() -> int
    eric isRaining = #f
    
    erif (!(isRaining)):
        peric("Let's go outside!")
    deschelse:
        peric("Stay inside")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you'd like me to translate into German (DE).
```
Let's go outside!
```

## Verschachtelte Bedingungen

Sie können `erif`-Anweisungen ineinander verschachteln:

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

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
You can drive
```

## Mehrere Bedingungen mit besserem Code-Stil

Anstelle von tief verschachtelten if-else-Anweisungen, verwenden Sie mehrere Bedingungen:

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

Sure, please provide the Markdown chunk you'd like me to translate into German (DE).
```
Category: Teenager
```

## Boolesche Variablen

Erstellen Sie Variablen, die Wahr/Falsch-Werte speichern:

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

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
You can apply for the internship!
```

## Praktisches Beispiel: Notenrechner

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

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
Score: 85 -> Grade: B
```

## Schalterähnliches Muster (Mehrere Prüfungen)

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

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
Day: Wednesday
```

## Häufige Fehler

### Verwendung von `=` anstelle von `==`
```tsl
erif (x = 5):       desnote ERROR - assignment, not comparison
erif (x == 5):      desnote CORRECT - comparison
```

### Fehlende Klammern
```tsl
erif age >= 18:     desnote ERROR - needs parentheses
erif (age >= 18):   desnote CORRECT
```

### Vergessen deschelse
```tsl
erif (x == 5):
    peric("x is 5")
desnote deschelse is optional - no error here
```

## Nächste Schritte

- Lernen Sie **[Schleifen](loops.md)**, um Code basierend auf Bedingungen zu wiederholen
- Erkunden Sie **[Funktionen](functions.md)**, um bedingte Logik zu organisieren
- Entdecken Sie **[Arrays](lists.md)** und iterieren Sie mit Bedingungen
