# Structs - Gruppierung verwandter Daten

Structs ermöglichen es Ihnen, mehrere verwandte Werte unterschiedlicher Typen in einer einzigen benutzerdefinierten Datenstruktur zu kombinieren.

## Grundlegende Struct-Definition

```tsl
destruct Point
    x -> int
    y -> int

Deschodt Eric() -> int
    eric location -> Point
    location.x = 10
    location.y = 20
    
    peric("Location: ({location.x}, {location.y})")
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
Location: (10, 20)
```

**Syntax:**
- `destruct StructName` beginnt eine Strukturdefinition
- Jedes Feld in einer neuen Zeile mit `fieldName -> type`
- Greifen Sie auf Felder mit `variable.fieldName` zu
- Setzen Sie Felder mit `variable.fieldName = value`

## Struktur mit Verschiedenen Typen

```tsl
destruct Person
    name -> string
    age -> int
    height -> float
    isStudent -> bool

Deschodt Eric() -> int
    eric student -> Person
    
    student.name = "Alice"
    student.age = 20
    student.height = 1.65
    student.isStudent = #t
    
    peric("Name: {student.name}")
    peric("Age: {student.age}")
    peric("Height: {student.height}m")
    
    erif (student.isStudent):
        peric("Status: Student")
    
    deschodt 0
```

Sure, please provide the Markdown chunk you'd like me to translate into German (DE).
```
Name: Alice
Age: 20
Height: 1.65m
Status: Student
```

## Struktur mit vielen Feldern

```tsl
destruct Car
    brand -> string
    model -> string
    year -> int
    color -> string
    mileage -> int

Deschodt Eric() -> int
    eric myCar -> Car
    
    myCar.brand = "Toyota"
    myCar.model = "Camry"
    myCar.year = 2020
    myCar.color = "blue"
    mileage = 45000
    
    peric("{myCar.year} {myCar.brand} {myCar.model}")
    peric("Color: {myCar.color}")
    peric("Mileage: {myCar.mileage} km")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
2020 Toyota Camry
Color: blue
Mileage: 45000 km
```

## Array von Strukturen

```tsl
destruct Student
    id -> int
    name -> string
    grade -> int

Deschodt Eric() -> int
    eric students -> Student[]
    
    students[0].id = 101
    students[0].name = "Alice"
    students[0].grade = 85
    
    students[1].id = 102
    students[1].name = "Bob"
    students[1].grade = 92
    
    students[2].id = 103
    students[2].name = "Charlie"
    students[2].grade = 78
    
    aer i in range(0, 3):
        peric("Student {students[i].id}: {students[i].name} - Grade {students[i].grade}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
Student 101: Alice - Grade 85
Student 102: Bob - Grade 92
Student 103: Charlie - Grade 78
```

## Funktionen mit Strukturen

```tsl
destruct Point
    x -> int
    y -> int

Deschodt distance(p1 -> Point, p2 -> Point) -> int
    eric dx = p2.x - p1.x -> int
    eric dy = p2.y - p1.y -> int
    desnote Simplified: return sum of absolute values
    deschodt dx + dy

Deschodt Eric() -> int
    eric start -> Point
    start.x = 0
    start.y = 0
    
    eric end -> Point
    end.x = 3
    end.y = 4
    
    eric dist = distance(start, end) -> int
    peric("Distance: {dist}")
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
Distance: 7
```

## Strukturfeldtypen

Strukturfelder können jeden Typ haben:

| Typ | Beispiel |
|-----|----------|
| `int` | `count -> int` |
| `float` | `price -> float` |
| `string` | `name -> string` |
| `char` | `initial -> char` |
| `bool` | `active -> bool` |
| `type[]` | `scores -> int[]` |
| `type*` | `pointer -> int*` |
| Andere Struktur | `point -> Point` |

## Verschachtelte Strukturen

Strukturen können andere Strukturen enthalten:

```tsl
destruct Address
    street -> string
    city -> string
    zipcode -> int

destruct Employee
    id -> int
    name -> string
    address -> Address

Deschodt Eric() -> int
    eric emp -> Employee
    
    emp.id = 1001
    emp.name = "John"
    emp.address.street = "123 Main St"
    emp.address.city = "Springfield"
    emp.address.zipcode = 12345
    
    peric("Employee: {emp.name}")
    peric("Address: {emp.address.street}, {emp.address.city} {emp.address.zipcode}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into German (DE).
```
Employee: John
Address: 123 Main St, Springfield 12345
```

## Strukturvergleich

```tsl
destruct RGB
    r -> int
    g -> int
    b -> int

Deschodt colorsEqual(c1 -> RGB, c2 -> RGB) -> bool
    eric sameRed = c1.r == c2.r -> bool
    eric sameGreen = c1.g == c2.g -> bool
    eric sameBlue = c1.b == c2.b -> bool
    
    deschodt sameRed && sameGreen && sameBlue

Deschodt Eric() -> int
    eric color1 -> RGB
    color1.r = 255
    color1.g = 128
    color1.b = 0
    
    eric color2 -> RGB
    color2.r = 255
    color2.g = 128
    color2.b = 0
    
    erif (colorsEqual(color1, color2)):
        peric("Colors match")
    deschelse:
        peric("Colors differ")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
Colors match
```

## Praktisches Beispiel: Rechteck-Flächenrechner

```tsl
destruct Rectangle
    width -> float
    height -> float

Deschodt area(rect -> Rectangle) -> float
    deschodt rect.width * rect.height

Deschodt perimeter(rect -> Rectangle) -> float
    deschodt 2 * (rect.width + rect.height)

Deschodt Eric() -> int
    eric rect -> Rectangle
    rect.width = 5.0
    rect.height = 3.0
    
    eric a = area(rect) -> float
    eric p = perimeter(rect) -> float
    
    peric("Width: {rect.width}, Height: {rect.height}")
    peric("Area: {a}")
    peric("Perimeter: {p}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
Width: 5.0, Height: 3.0
Area: 15.0
Perimeter: 16.0
```

## Praktisches Beispiel: Bücherbibliothek

```tsl
destruct Book
    title -> string
    author -> string
    year -> int
    pages -> int

Deschodt Eric() -> int
    eric books -> Book[]
    
    books[0].title = "1984"
    books[0].author = "George Orwell"
    books[0].year = 1949
    books[0].pages = 328
    
    books[1].title = "To Kill a Mockingbird"
    books[1].author = "Harper Lee"
    books[1].year = 1960
    books[1].pages = 281
    
    books[2].title = "The Great Gatsby"
    books[2].author = "F. Scott Fitzgerald"
    books[2].year = 1925
    books[2].pages = 180
    
    peric("Library Catalog:")
    aer i in range(0, 3):
        peric("- {books[i].title} by {books[i].author} ({books[i].year})")
        peric("  Pages: {books[i].pages}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
Library Catalog:
- 1984 by George Orwell (1949)
  Pages: 328
- To Kill a Mockingbird by Harper Lee (1960)
  Pages: 281
- The Great Gatsby by F. Scott Fitzgerald (1925)
  Pages: 180
```

## Praktisches Beispiel: Spielcharakter

```tsl
destruct Character
    name -> string
    health -> int
    mana -> int
    level -> int
    experience -> int

Deschodt levelUp(character -> Character*) -> void
    (*character).level = (*character).level + 1
    (*character).experience = 0
    (*character).health = (*character).health + 10

Deschodt Eric() -> int
    eric hero -> Character
    hero.name = "Aragorn"
    hero.health = 100
    hero.mana = 50
    hero.level = 5
    hero.experience = 500
    
    peric("{hero.name} - Level {hero.level}, Health {hero.health}")
    levelUp(&hero)
    peric("After level up: Level {hero.level}, Health {hero.health}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into German (DE).
```
Aragorn - Level 5, Health 100
After level up: Level 6, Health 110
```

## Häufige Fehler

### Den Pfeil im Feldtyp vergessen
```tsl
destruct Point
    x int              desnote ERROR - missing ->
    x -> int          desnote CORRECT
```

### Zugriff auf nicht vorhandenes Feld
```tsl
destruct Person
    name -> string

eric p -> Person
eric age = p.age -> int  desnote ERROR - Person has no 'age' field
```

### Struktur Ohne Definition
```tsl
eric person -> Person    desnote ERROR - Person struct not defined
destruct Person
    name -> string       desnote Define AFTER use - wrong order
```

Definiere Strukturen, BEVOR du sie verwendest:

```tsl
destruct Person          desnote Define FIRST
    name -> string

eric person -> Person    desnote Use AFTER definition
```

### Struktur durch Wert vs. Zeiger ändern
```tsl
destruct Point
    x -> int
    y -> int

Deschodt moveByValue(p -> Point) -> void
    p.x = p.x + 10  desnote This changes the COPY, not the original

Deschodt moveByPointer(p -> Point*) -> void
    (*p).x = (*p).x + 10  desnote This changes the ORIGINAL

Eric() -> int
    eric pos -> Point
    pos.x = 5
    moveByValue(pos)
    peric("{pos.x}")      desnote Still 5 - not changed
    moveByPointer(&pos)
    peric("{pos.x}")      desnote Now 15 - changed!
```

## Best Practices

1. **Logische Gruppierung**: Gruppiere verwandte Felder in einer Struktur
2. **Bedeutungsvolle Namen**: Verwende klare Namen für Strukturen und Felder
3. **Einfache Strukturen**: Vermeide anfangs übermäßig komplexe verschachtelte Strukturen
4. **Funktionen verwenden**: Extrahiere Strukturoperationen in wiederverwendbare Funktionen
5. **Referenzübergabe**: Verwende zur Leistungssteigerung Zeiger, wenn du Strukturen änderst
6. **Felder dokumentieren**: Füge Kommentare hinzu, die komplexe Felder erklären
7. **Typenkonsistenz wahren**: Alle Instanzen einer Struktur verwenden die gleichen Feldtypen

## Next Steps

- Kombiniere Strukturen mit **[Funktionen](functions.md)** zur Datenverarbeitung
- Verwende **[Arrays](lists.md)** von Strukturen für Sammlungen
- Erkunde **[Zeiger](pointers.md)**, um Strukturen effizient zu ändern
- Probiere **[Enums](enums.md)** für feste Wertmengen aus
