# Variables - Stocker des données

Les variables vous permettent de stocker et manipuler les données dans votre programme. TSL est **statiquement typé**, ce qui signifie que chaque variable a un type de données spécifique qui ne peut pas changer.

## Déclaration de variable de base

### Declare Without Initialisation

```tsl
eric x -> int
eric name -> string
eric value -> float
```

Variables declared this way exist but have undefined values. You should assign them before using.

### Déclarer avec initialisation

```tsl
eric x = 5 -> int
eric name = "Alice" -> string
eric pi = 3.14 -> float
```

Ceci déclare et assigne une valeur en une étape.

## Types de données

TSL supports these primitive types:

| Type | Description | Examples |
|------|-------------|----------|
| `int` | Entier signé 32 bits | `42`, `-10`, `0` |
| `float` | Nombre en virgule flottante | `3.14`, `-2.5`, `0.0` |
| `string` | Chaîne de texte | `"Hello"`, `"TSL"` |
| `char` | Caractère unique | `'a'`, `'Z'`, `'!'` |
| `bool` | Valeur booléenne | `#t` (true), `#f` (false) |

## Assignation de valeurs

Une fois déclarée, assignez de nouvelles valeurs avec `=` :

```tsl
Deschodt Eric() -> int
    eric x = 10 -> int
    x = 20              desnote reassign x to 20
    x = x + 5           desnote x is now 25
    
    peric("x = {x}")
    deschodt 0
```

Output:
```
x = 25
```

## Portée des variables

Les variables existent de la déclaration jusqu'à la fin de leur bloc :

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

## Conventions de nommage

Choisissez des noms clairs et descriptifs :

```tsl
desnote Bons noms de variables
eric totalPrice -> float
eric userAge -> int
eric isValid -> bool

desnote Éviter les noms peu clairs
eric x -> int           desnote trop vague
eric asdf -> string     desnote sans sens
eric a1b2c3 -> float    desnote difficile à retenir
```

## Utiliser les variables dans les expressions

Les variables fonctionnent dans les opérations arithmétiques et logiques :

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

## String Interpolation

Insert variable values into strings using `{variable}`:

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

## Type Conversion

To convert between types:

```tsl
desnote Float to int (loses decimals)
eric f = 3.7 -> float
eric i = (cast int f) -> int    desnote i is now 3

desnote Int to float (adds .0)
eric i = 42 -> int
eric f = (cast float i) -> float desnote f is now 42.0
```

## Erreurs courantes

### Forgetting Type Annotation
```tsl
eric x = 5      desnote ERROR - missing type
eric x = 5 -> int desnote CORRECT
```

### Décalage de type
```tsl
eric x = "hello" -> int  desnote ERROR - string can't be int
eric x = "hello" -> string desnote CORRECT
```

### Using Undefined Variable
```tsl
peric("{y}")     desnote ERROR - y was never declared
eric y = 0 -> int
peric("{y}")     desnote CORRECT
```

## Complete Example

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

Output:
```
Name: Alice Smith
Age: 29
```

## Étapes suivantes

- Learn about **[Conditions](condition.md)** to make decisions based on variables
- Explore **[Tableaux](lists.md)** to stocker plusieurs valeurs
- See **[Fonctions](functions.md)** to pass and return variables
