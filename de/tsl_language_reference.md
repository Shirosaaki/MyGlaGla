# TSL (TheShowLang) - Vollständige Sprachreferenz

Willkommen bei TSL! Dies ist eine moderne imperative Programmiersprache mit Unterstützung für Funktionen, Variablen, Arrays, Strukturen, Aufzählungen und Kontrollfluss. Dieser Leitfaden wird Ihnen alles beibringen, was Sie wissen müssen, um TSL-Programme zu schreiben.

## Inhaltsverzeichnis
1. [Hallo Welt](#hello-world)
2. [Variablen](#variables)
3. [Datentypen](#data-types)
4. [Bedingungen](#conditionals)
5. [Schleifen](#loops)
6. [Funktionen](#functions)
7. [Arrays](#arrays)
8. [Strukturen](#structs)
9. [Aufzählungen](#enums)
10. [Zeiger](#pointers)
11. [Eingabe/Ausgabe](#inputoutput)
12. [Fortgeschrittene Beispiele](#advanced-examples)

---

## Hallo Welt

Jedes TSL-Programm beginnt mit einer Hauptfunktion namens `Eric`. Dies ist der Einstiegspunkt Ihres Programms.

```tsl
Deschodt Eric() -> int
    peric("Hello, World!")
    deschodt 0
```

**Aufschlüsselung:**
- `Deschodt` - Schlüsselwort zur Definition einer Funktion
- `Eric()` - die Hauptfunktion (keine Parameter)
- `-> int` - Rückgabetyp-Annotation
- `peric(...)` - Druckfunktion (gibt auf der Konsole aus)
- `deschodt 0` - Rückgabewert (Exit-Code 0)

Wenn Sie dieses Programm ausführen, wird es ausgeben: `Hallo, Welt!`

---

## Variablen

Variablen speichern Datenwerte. TSL ist eine statisch typisierte Sprache, daher müssen Sie den Typ jeder Variablen deklarieren.

### Grundlegende Variablendeklaration

```tsl
Deschodt Eric() -> int
    eric x -> int              desnote declare integer x (uninitialized)
    eric y = 10 -> int         desnote declare and initialize y = 10
    x = 5                      desnote assign value to x
    eric z = x + y -> int      desnote declare and initialize z = 15

    peric("x = {x}, y = {y}, z = {z}")
    deschodt 0
```

**Ausgabe:**
```
x = 5, y = 10, z = 15
```

**Syntax:**
- `eric varname -> type` - eine Variable deklarieren
- `eric varname = value -> type` - deklarieren und initialisieren
- String-Interpolation: benutze `{variable}` innerhalb von Strings, um Werte einzufügen

---

## Datentypen

TSL unterstützt die folgenden primitiven Datentypen:

| Typ     | Beschreibung                     | Beispiel         |
|---------|----------------------------------|------------------|
| `int`   | 32-Bit vorzeichenbehaftete Ganzzahl | `5`, `-10`, `0`  |
| `float` | Fließkommazahl                   | `3.14`, `-2.5`   |
| `string`| Textzeichenfolge                 | `"Hallo"`, `"TSL"` |
| `char`  | Einzelnes Zeichen                | `'a'`, `'Z'`     |
| `bool`  | Boolescher Wert                  | `#t` (wahr), `#f` (falsch) |
| `void`  | Kein Wert                        | Verwendet für Funktionen ohne Rückgabe |
| `int[]` | Array von Ganzzahlen             | `[1, 2, 3]`      |
| `string[]` | Array von Zeichenfolgen       | `["a", "b"]`     |
| `type*` | Zeiger auf einen Typ             | `int*`, `string*` |

---

## Bedingungen

Steuere den Programmfluss basierend auf Bedingungen mit `erif` (wenn) und `deschelse` (sonst).

### Wenn-Anweisung

```tsl
Deschodt Eric() -> int
    eric age = 20 -> int

    erif (age >= 18):
        peric("Majeur")
    deschelse:
        peric("Mineur")

    deschodt 0
```

**Output:**
```
Majeur
```

**Vergleichsoperatoren:**
- `==` - gleich
- `!=` - ungleich
- `<` - kleiner als
- `>` - größer als
- `<=` - kleiner oder gleich
- `>=` - größer oder gleich

**Logische Operatoren:**
- `&&` - UND
- `||` - ODER
- `!` - NICHT

---

## Schleifen

TSL bietet zwei Arten von Schleifen: `aer` (for-in) und `darius` (while).

### For-Schleife

Verwenden Sie `aer`, um über einen Bereich oder eine Sammlung zu iterieren:

```tsl
Deschodt Eric() -> int
    peric("For loop:")
    aer i in range(0, 5):
        peric("i = {i}")

    deschodt 0
```

**Ausgabe:**
```
For loop:
i = 0
i = 1
i = 2
i = 3
i = 4
```

**Schleifensteuerung:**
- `deschontinue` - zur nächsten Iteration überspringen
- `deschreak` - die Schleife verlassen

```tsl
aer i in range(0, 10):
    erif (i == 3):
        deschontinue        desnote skip when i = 3
    erif (i == 7):
        deschreak           desnote exit when i = 7
    peric("i = {i}")
```

### While-Schleife

Verwende `darius` für bedingte Schleifen:

```tsl
Deschodt Eric() -> int
    eric x = 0 -> int
    darius (x < 3):
        peric("x = {x}")
        x = x + 1

    deschodt 0
```

**Ausgabe:**
```
x = 0
x = 1
x = 2
```

---

## Funktionen

Funktionen ermöglichen es Ihnen, Code wiederzuverwenden und Ihr Programm zu organisieren.

### Funktionsdefinition

```tsl
Deschodt addition(a -> int, b -> int) -> int
    deschodt a + b

Deschodt Eric() -> int
    eric result = addition(5, 7) -> int
    peric("Result: {result}")
    deschodt 0
```

**Output:**
```
Result: 12
```

**Syntax:**
- `Deschodt funcname(param1 -> type1, param2 -> type2) -> returntype`
- `deschodt value` - gibt einen Wert aus einer Funktion zurück
- Funktionen müssen explizite Rückgabetypen haben
- Alle Parameter müssen Typannotationen haben

---

## Arrays

Arrays speichern mehrere Werte desselben Typs.

### Array-Deklaration und Initialisierung

```tsl
Deschodt Eric() -> int
    eric nums -> int[]
    nums[0] = 1
    nums[1] = 2
    nums[2] = 3
    nums[100] = 50

    aer i in range(0, 101):
        peric("nums[{i}] = {nums[i]}")

    deschodt 0
```

**Wichtige Punkte:**
- Deklarieren mit `varname -> type[]`
- Elemente zugreifen mit `arr[index]`
- Arrays sind 0-indiziert
- Du kannst jeden Index setzen (sparse arrays)
- Verwende `range(start, end)`, um zu iterieren (geht von start bis end-1)

---

## Strukturen

Strukturen ermöglichen es dir, verwandte Daten zusammenzufassen.

### Strukturdefinition und -verwendung

```tsl
destruct Person:
    name -> string
    age -> int

Deschodt Eric() -> int
    eric p -> Person
    p.name = "Alice"
    p.age = 25

    peric("Name: {p.name}, Age: {p.age}")
    deschodt 0
```

**Output:**
```
Name: Alice, Age: 25
```

**Syntax:**
- `destruct StructName:` - definiere eine Struktur
- Felder sind eingerückt und typisiert
- `eric var -> StructName` - deklariere eine Strukturvariable
- `var.field` - greife auf Strukturmitglieder zu
- `var.field = value` - setze Strukturmitglieder

---

## Enums

Enums definieren eine Menge von benannten Konstanten.

### Enum-Definition und Verwendung

```tsl
desnum Day:
    Monday
    Tuesday
    Wednesday

Deschodt Eric() -> int
    eric d = Tuesday -> Day
    peric("Day = {d}")
    deschodt 0
```

I'm sorry, but it seems that the Markdown chunk you wanted to translate is missing. Please provide the text, and I'll be happy to assist you with the translation!
```
Day = 1
```

**Wichtige Punkte:**
- `desnum EnumName:` - ein Enum definieren
- Enum-Werte werden automatisch Ganzzahlen zugewiesen (0, 1, 2, ...)
- Enums bieten Typsicherheit und Lesbarkeit

---

## Zeiger

Zeiger ermöglichen es Ihnen, Werte über Adressen zu referenzieren und zu ändern.

### Deklaration und Verwendung von Zeigern

```tsl
Deschodt increment(ptr -> int*) -> void
    *ptr = *ptr + 1

Deschodt Eric() -> int
    eric n = 10 -> int
    increment(&n)
    peric("n = {n}")
    deschodt 0
```

**Ausgabe:**
```
n = 11
```

**Syntax:**
- `type*` - Zeiger auf einen Typ
- `&var` - Adresse der Variablen erhalten (Referenz)
- `*ptr` - Zeiger dereferenzieren (Wert erhalten)
- Verwenden Sie Zeiger, um Variablen durch Referenz zu übergeben

---

## Eingabe/Ausgabe

### Drucken

Verwenden Sie `peric()`, um Text auszugeben:

```tsl
eric x = 42 -> int
eric name = "Alice" -> string
peric("Value: {x}, Name: {name}")
```

**Funktionen:**
- String-Interpolation mit `{variable}`
- Funktioniert mit allen Datentypen
- Mehrere Werte können auf separaten Zeilen ausgegeben werden

---

## Fortgeschrittene Beispiele

### Beispiel: Fakultätsberechnung

```tsl
Deschodt factorial(n -> int) -> int
    erif (n <= 1):
        deschodt 1
    deschelse:
        deschodt n * factorial(n - 1)

Deschodt Eric() -> int
    eric val = 5 -> int
    peric("factorial({val}) = {factorial(val)}")
    deschodt 0
```

**Output:**
```
factorial(5) = 120
```

### Beispiel: Summe eines Arrays

```tsl
Deschodt sum(arr -> int[], size -> int) -> int
    eric total = 0 -> int
    aer i in range(0, size):
        total = total + arr[i]
    deschodt total

Deschodt Eric() -> int
    eric values -> int[4]
    values[0] = 4
    values[1] = 7
    values[2] = 2
    values[3] = 9

    eric res = sum(values, 4) -> int
    peric("Sum = {res}")
    deschodt 0
```

**Output:**
```
Sum = 22
```

### Beispiel: Mehrdimensionale Arrays

```tsl
Deschodt Eric() -> int
    eric matrix -> int[]
    matrix[0] -> int[]
    matrix[0][0] = 1
    matrix[0][1] = 2
    matrix[1] -> int[]
    matrix[1][0] = 3
    matrix[1][1] = 4

    aer i in range(0, 2):
        aer j in range(0, 2):
            peric("matrix[{i}][{j}] = {matrix[i][j]}")

    deschodt 0
```

**Ausgabe:**
```
matrix[0][0] = 1
matrix[0][1] = 2
matrix[1][0] = 3
matrix[1][1] = 4
```

---

## Interaktives REPL

Sie können auch TSL-Code interaktiv mit dem REPL schreiben:

### Einzeilige Ausführung
Geben Sie einfach den Code ein und drücken Sie die Eingabetaste - er wird sofort ausgeführt:

```
> (+ 5 3)
8
> (define x 42)
> (* x 2)
84
```

### Mehrzeilige Codeblöcke
Für längeren Code verwenden Sie `:code` ... `:end`:

```
> :code
code> Deschodt factorial(n -> int) -> int
code>     erif (n <= 1):
code>         deschodt 1
code>     deschelse:
code>         deschodt n * factorial(n - 1)
code> peric(factorial(5))
:end
120
```

---

## Tipps und Best Practices

1. **Typensicherheit**: Deklarieren Sie immer die Variablentypen. TSL erkennt Typfehler zur Parse-Zeit.

2. **Namenskonvention**: Verwenden Sie englische oder beschreibende Namen für mehr Klarheit.

3. **Rückgabewerte**: Jede Funktion muss explizit einen Wert mit `deschodt` zurückgeben.

4. **Speicher**: Seien Sie vorsichtig mit Zeigern - stellen Sie sicher, dass der Speicherzugriff gültig ist.

5. **Schleifen-Grenzen**: Verwenden Sie immer `range()` mit den richtigen Grenzen, um endlose Schleifen zu vermeiden.

6. **String-Interpolation**: Verwenden Sie `{var}` in Strings, um die Ausgabe lesbar zu machen.

7. **Kommentare**: Die Sprache unterstützt `desnote` für Kommentare im TSL-Code.

---

## Häufige Fehler und Lösungen

| Fehler | Ursache | Lösung |
|-------|-------|----------|
| "Parsing-Fehler" | Ungültige Syntax | Überprüfen Sie Klammern und Einrückungen |
| "Variable X ist nicht gebunden" | Verwendung einer undefinierten Variable | Deklarieren Sie sie zuerst mit `eric` |
| Typenkonflikt | Falsche Typzuweisung | Überprüfen Sie die Typannotation der Variablen |
| Division durch Null | Division durch 0 | Fügen Sie eine Überprüfung vor der Division hinzu |
| Array-Index außerhalb der Grenzen | Zugriff auf einen ungültigen Index | Verwenden Sie `range()` für sicheres Iterieren |

---

## Zusammenfassung

TSL ist eine praktische Sprache zum Erlernen von Programmierkonzepten:
- **Variablen** ermöglichen das Speichern von Daten
- **Bedingungen** steuern den Ausführungsfluss
- **Schleifen** wiederholen Code
- **Funktionen** organisieren und wiederverwenden Code
- **Arrays & Strukturen** organisieren komplexe Daten
- **Zeiger** ermöglichen referenzbasiertes Programmieren

Beginnen Sie mit einfachen Programmen und fügen Sie nach und nach Komplexität hinzu. Viel Spaß beim Programmieren!
