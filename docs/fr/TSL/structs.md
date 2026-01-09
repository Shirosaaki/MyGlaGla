# Structures - Regrouper les données associées

Les structures vous permettent de combiner plusieurs valeurs associées de différents types en une seule structure de données personnalisée.

## Définition de structure de base

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

Output:
```
Location: (10, 20)
```

**Syntaxe :**
- `destruct StructName` commence une définition de structure
- Chaque champ sur une nouvelle ligne avec `fieldName -> type`
- Accédez aux champs avec `variable.fieldName`
- Définir les champs avec `variable.fieldName = value`

## Structure avec différents types

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

Output:
```
Name: Alice
Age: 20
Height: 1.65m
Status: Student
```

## Structure avec de nombreux champs

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

Output:
```
2020 Toyota Camry
Color: blue
Mileage: 45000 km
```

## Tableau de structures

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

Output:
```
Student 101: Alice - Grade 85
Student 102: Bob - Grade 92
Student 103: Charlie - Grade 78
```

## Fonctions avec des structures

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

Output:
```
Distance: 7
```

## Types de champs de structure

Les champs de structure peuvent être de n'importe quel type :

| Type | Example |
|------|---------|
| `int` | `count -> int` |
| `float` | `price -> float` |
| `string` | `name -> string` |
| `char` | `initial -> char` |
| `bool` | `active -> bool` |
| `type[]` | `scores -> int[]` |
| `type*` | `pointer -> int*` |
| Other struct | `point -> Point` |

## Structures imbriquées

Les structures peuvent contenir d'autres structs :

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

Output:
```
Employee: John
Address: 123 Main St, Springfield 12345
```

## Comparaison de structure

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

Output:
```
Colors match
```

## Exemple pratique : Calculatrice de surface de rectangle

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

Output:
```
Width: 5.0, Height: 3.0
Area: 15.0
Perimeter: 16.0
```

## Exemple pratique : Bibliothèque de livres

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
    
    peric("Catalogue de la bibliothèque:")
    aer i in range(0, 3):
        peric("- {books[i].title} by {books[i].author} ({books[i].year})")
        peric("  Pages: {books[i].pages}")
    
    deschodt 0
```

Output:
```
Catalogue de la bibliothèque:
- 1984 by George Orwell (1949)
  Pages: 328
- To Kill a Mockingbird by Harper Lee (1960)
  Pages: 281
- The Great Gatsby by F. Scott Fitzgerald (1925)
  Pages: 180
```

## Exemple pratique : Personnage de jeu

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

Output:
```
Aragorn - Level 5, Health 100
After level up: Level 6, Health 110
```

## Erreurs courantes

### Oublier la flèche dans le type de champ
```tsl
destruct Point
    x int              desnote ERROR - missing ->
    x -> int          desnote CORRECT
```

### Accéder à un champ inexistant
```tsl
destruct Person
    name -> string

eric p -> Person
eric age = p.age -> int  desnote ERROR - Person has no 'age' field
```

### Structure sans définition
```tsl
eric person -> Person    desnote ERROR - Person struct not defined
destruct Person
    name -> string       desnote Define AFTER use - wrong order
```

Définir les structures AVANT de les utiliser :

```tsl
destruct Person          desnote Define FIRST
    name -> string

eric person -> Person    desnote Use AFTER definition
```

### Modification de la structure par valeur vs. pointeur
```tsl
destruct Point
    x -> int
    y -> int

Deschodt moveByValue(p -> Point) -> void
    p.x = p.x + 10  desnote This changes the COPY, not l'original

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

## Meilleures pratiques

1. **Regroupement logique** : Regroupez les champs associés dans une seule structure
2. **Noms significatifs** : Utilisez des noms clairs pour les structures et les champs
3. **Structures simples** : Évitez les structures imbriquées trop complexes au début
4. **Utiliser des fonctions** : Extrayez les opérations de structure dans des fonctions réutilisables
5. **Passage par référence** : Pour des performances optimales, utilisez des pointeurs lorsque vous modifiez des structures
6. **Documenter les champs** : Ajouter des commentaires expliquant les champs complexes
7. **Conserver la cohérence des types** : Toutes les instances d'une structure utilisent les mêmes types de champs

## Étapes suivantes

- Combinez les structures avec des **[Fonctions](functions.md)** pour le traitement des données
- Utilisez des **[Tableaux](lists.md)** de structures pour les collections
- Explorez les **[Pointeurs](pointers.md)** pour modifier efficacement les structures
- Essayez les **[Énumérations](enums.md)** pour des ensembles de valeurs fixes
