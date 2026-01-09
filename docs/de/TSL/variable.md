# Variablen - Daten speichern

Variablen ermöglichen es Ihnen, Daten in Ihrem Programm zu speichern und zu manipulieren. TSL ist **statisch typisiert**, was bedeutet, dass jede Variable einen spezifischen Datentyp hat, der sich nicht ändern kann.

## Grundlegende Variablendeklaration

### Deklaration ohne Initialisierung

```tsl
eric x -> int
eric name -> string
eric value -> float
```

Variablen, die auf diese Weise deklariert werden, existieren, haben jedoch undefinierte Werte. Sie sollten ihnen vor der Verwendung Werte zuweisen.

### Deklaration mit Initialisierung

```tsl
eric x = 5 -> int
eric name = "Alice" -> string
eric pi = 3.14 -> float
```

This deklariert und weist einen Wert in einem Schritt zu.

## Datentypen

TSL unterstützt diese primitiven Typen:

| Typ    | Beschreibung               | Beispiele                |
|--------|----------------------------|--------------------------|
| `int`  | 32-Bit vorzeichenbehaftete Ganzzahl | `42`, `-10`, `0`        |
| `float`| Fließkommazahl             | `3.14`, `-2.5`, `0.0`   |
| `string`| Textzeichenfolge           | `"Hallo"`, `"TSL"`      |
| `char` | Einzelnes Zeichen           | `'a'`, `'Z'`, `'!'`     |
| `bool` | Boolescher Wert            | `#t` (wahr), `#f` (falsch) |

## Werte zuweisen

Sobald deklariert, weisen Sie neue Werte mit `=` zu:

```tsl
Deschodt Eric() -> int
    eric x = 10 -> int
    x = 20              desnote reassign x to 20
    x = x + 5           desnote x is now 25
    
    peric("x = {x}")
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
x = 25
```

## Variablenbereich

Variablen existieren von der Deklaration bis zum Ende ihres Blocks:

```tsl
Deschodt Eric() -> int
    eric x = 1 -> int
    peric("x = {x}")    desnote x is accessible here
    
    erif (#t):
        eric y = 2 -> int
        peric("y = {y}")    desnote y is accessible here
    
    desnote y no longer exists here - would cause error
    
    deschodt 0
```

## Benennungsrichtlinien

Wählen Sie klare, beschreibende Namen:

```tsl
desnote Good variable names
eric totalPrice -> float
eric userAge -> int
eric isValid -> bool

desnote Avoid unclear names
eric x -> int           desnote too vague
eric asdf -> string     desnote meaningless
eric a1b2c3 -> float    desnote hard to remember
```

## Verwendung von Variablen in Ausdrücken

Variablen funktionieren in arithmetischen und logischen Operationen:

```tsl
Deschodt Eric() -> int
    eric a = 10 -> int
    eric b = 3 -> int
    eric sum = a + b -> int
    eric product = a * b -> int
    
    peric("Sum: {sum}")         desnote Sum: 13
    peric("Product: {product}") desnote Product: 30
    
    deschodt 0
```

## String-Interpolation

Fügen Sie Variablenwerte in Strings ein, indem Sie `{variable}` verwenden:

```tsl
Deschodt Eric() -> int
    eric name = "Bob" -> string
    eric age = 25 -> int
    eric height = 1.75 -> float
    
    peric("Name: {name}")                      desnote Name: Bob
    peric("Age: {age}")                        desnote Age: 25
    peric("Height: {height} meters")           desnote Height: 1.75 meters
    peric("{name} is {age} years old")         desnote Bob is 25 years old
    
    deschodt 0
```

## Typumwandlung

Um zwischen Typen zu konvertieren:

```tsl
desnote Float to int (loses decimals)
eric f = 3.7 -> float
eric i = (cast int f) -> int    desnote i is now 3

desnote Int to float (adds .0)
eric i = 42 -> int
eric f = (cast float i) -> float desnote f is now 42.0
```

## Häufige Fehler

### Vergessen der Typannotation
```tsl
eric x = 5      desnote ERROR - missing type
eric x = 5 -> int desnote CORRECT
```

### Typkonflikt
```tsl
eric x = "hello" -> int  desnote ERROR - string can't be int
eric x = "hello" -> string desnote CORRECT
```

### Verwendung einer undefinierten Variablen
```tsl
peric("{y}")     desnote ERROR - y was never declared
eric y = 0 -> int
peric("{y}")     desnote CORRECT
```

## Vollständiges Beispiel

```tsl
Deschodt Eric() -> int
    desnote Declare and initialize variables
    eric firstName = "Alice" -> string
    eric lastName = "Smith" -> string
    eric birthYear = 1995 -> int
    eric currentYear = 2024 -> int
    
    desnote Calculate age
    eric age = currentYear - birthYear -> int
    
    desnote Use string interpolation
    peric("Name: {firstName} {lastName}")
    peric("Age: {age}")
    
    deschodt 0
```

I'm sorry, but it seems that you haven't provided the Markdown chunk that you would like me to translate. Please share the content, and I'll be happy to assist you with the translation into German (DE).
```
Name: Alice Smith
Age: 29
```

## Nächste Schritte

- Informiere dich über **[Bedingungen](condition.md)**, um Entscheidungen basierend auf Variablen zu treffen
- Erkunde **[Arrays](lists.md)**, um mehrere Werte zu speichern
- Sieh dir **[Funktionen](functions.md)** an, um Variablen zu übergeben und zurückzugeben
