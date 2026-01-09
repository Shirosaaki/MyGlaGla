# TSL (TheShowLang) - Référence complète du langage

Bienvenue dans TSL ! C'est un langage de programmation impératif moderne avec support pour les fonctions, variables, tableaux, structures, énumérations et contrôle de flux. Ce guide vous enseignera tout ce que vous devez savoir pour écrire des programmes TSL.

## Table des matières
1. [Hello World](#hello-world)
2. [Variables](#variables)
3. [Types de données](#types-de-données)
4. [Conditions](#conditions)
5. [Boucles](#boucles)
6. [Fonctions](#fonctions)
7. [Tableaux](#tableaux)
8. [Structures](#structures)
9. [Énumérations](#énumérations)
10. [Pointeurs](#pointeurs)
11. [Entrée/Sortie](#entréesortie)
12. [Exemples avancés](#exemples-avancés)

---

## Hello World

Chaque programme TSL commence avec une fonction principale called `Eric`. C'est le point d'entrée of your program.

```tsl
Deschodt Eric() -> int
    peric("Hello, World!")
    deschodt 0
```

**Breakdown:**
- `Deschodt` - keyword for defining a function
- `Eric()` - the main function (no parameters)
- `-> int` - return type annotation
- `peric(...)` - print function (outputs to console)
- `deschodt 0` - return statement (exit code 0)

Quand vous exécutez ce programme, il imprimera: `Hello, World!`

---

## Variables

Les variables stockent les valeurs de données. TSL is a langage statiquement typé, so vous devez déclarer le type of each variable.

### Déclaration de variable de base

```tsl
Deschodt Eric() -> int
    eric x -> int              desnote declare integer x (non initialisé)
    eric y = 10 -> int         desnote declare and initialize y = 10
    x = 5                      desnote assign value to x
    eric z = x + y -> int      desnote declare and initialize z = 15

    peric("x = {x}, y = {y}, z = {z}")
    deschodt 0
```

**Output:**
```
x = 5, y = 10, z = 15
```

**Syntax:**
- `eric varname -> type` - declare a variable
- `eric varname = value -> type` - declare and initialize
- Interpolation de chaîne: use `{variable}` inside strings to insert values

---

## Types de données

TSL supporte les types de données primitifs suivants:

| Type | Description | Example |
|------|-------------|---------|
| `int` | Entier signé 32 bits | `5`, `-10`, `0` |
| `float` | Nombre en virgule flottante | `3.14`, `-2.5` |
| `string` | Chaîne de texte | `"Hello"`, `"TSL"` |
| `char` | Caractère unique | `'a'`, `'Z'` |
| `bool` | Valeur booléenne | `#t` (true), `#f` (false) |
| `void` | Aucune valeur | Used for functions with no return |
| `int[]` | Tableau d'entiers | `[1, 2, 3]` |
| `string[]` | Tableau de chaînes | `["a", "b"]` |
| `type*` | Pointeur vers un type | `int*`, `string*` |

---

## Conditions

Contrôlez le flux du programme en fonction des conditions using `erif` (if) and `deschelse` (else).

### Instruction If

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

**Opérateurs de comparaison:**
- `==` - égal
- `!=` - not égal
- `<` - moins que
- `>` - supérieur à
- `<=` - moins que or égal
- `>=` - supérieur à or égal

**Opérateurs logiques:**
- `&&` - AND
- `||` - OR
- `!` - NOT

---

## Boucles

TSL fournit deux types de boucles: `aer` (for-in) and `darius` (while).

### For Loop

Use `aer` to iterate over a range or collection:

```tsl
Deschodt Eric() -> int
    peric("For loop:")
    aer i in range(0, 5):
        peric("i = {i}")

    deschodt 0
```

**Output:**
```
For loop:
i = 0
i = 1
i = 2
i = 3
i = 4
```

**Loop Control:**
- `deschontinue` - skip to next iteration
- `deschreak` - exit the loop

```tsl
aer i in range(0, 10):
    erif (i == 3):
        deschontinue        desnote skip when i = 3
    erif (i == 7):
        deschreak           desnote exit when i = 7
    peric("i = {i}")
```

### Boucle While

Use `darius` for condition-based loops:

```tsl
Deschodt Eric() -> int
    eric x = 0 -> int
    darius (x < 3):
        peric("x = {x}")
        x = x + 1

    deschodt 0
```

**Output:**
```
x = 0
x = 1
x = 2
```

---

## Fonctions

Fonctions let you réutiliser le code and organize your program.

### Function Definition

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
- `deschodt value` - return a value from a function
- Fonctions must have explicit return types
- All parameters must have type annotations

---

## Tableaux

Tableaux stocker plusieurs valeurs du même type.

### Array Declaration and Initialisation

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

**Point clés:**
- Declare with `varname -> type[]`
- Access elements with `arr[index]`
- Tableaux are 0-indexed
- You can set any index (sparse arrays)
- Use `range(start, end)` to iterate (goes from start to end-1)

---

## Structures

Structures let you group related data together.

### Struct Definition and Usage

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
- `destruct StructName:` - define a struct
- Fields are indented and typed
- `eric var -> StructName` - declare a struct variable
- `var.field` - access struct members
- `var.field = value` - set struct members

---

## Énumérations

Énumérations define a set of named constants.

### Enum Definition and Usage

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

**Output:**
```
Day = 1
```

**Point clés:**
- `desnum EnumName:` - define an enum
- Les valeurs d'énumération sont automatiquement assigned integers (0, 1, 2, ...)
- Énumérations provide type safety and readability

---

## Pointeurs

Pointeurs allow you to reference and modify values via les adresses.

### Déclaration de pointeur and Usage

```tsl
Deschodt increment(ptr -> int*) -> void
    *ptr = *ptr + 1

Deschodt Eric() -> int
    eric n = 10 -> int
    increment(&n)
    peric("n = {n}")
    deschodt 0
```

**Output:**
```
n = 11
```

**Syntax:**
- `type*` - pointer to a type
- `&var` - get address of variable (reference)
- `*ptr` - dereference pointer (get value)
- Utilisez les pointeurs to pass variables by reference

---

## Input/Output

### Printing

Use `peric()` to output text:

```tsl
eric x = 42 -> int
eric name = "Alice" -> string
peric("Value: {x}, Name: {name}")
```

**Features:**
- Interpolation de chaîne with `{variable}`
- Works with all data types
- Multiple values can be printed on separate lines

---

## Advanced Examples

### Example: Factorial Calculation

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

### Example: Sum Array

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

### Example: Multi-dimensional Tableaux

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

**Output:**
```
matrix[0][0] = 1
matrix[0][1] = 2
matrix[1][0] = 3
matrix[1][1] = 4
```

---

## Interactive REPL

You can also write TSL code interactively using the REPL:

### Single-line Execution
Just type code and press Enter - it executes immediately:

```
> (+ 5 3)
8
> (define x 42)
> (* x 2)
84
```

### Multi-line Code Blocks
For longer code, use `:code` ... `:end`:

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

## Tips and Meilleures pratiques

1. **Type Safety**: Always declare variable types. TSL will catch type errors at parse time.

2. **Naming Convention**: Use English or descriptive names for clarity.

3. **Return Values**: Every function must explicitly return a value using `deschodt`.

4. **Memory**: Be careful with pointers - ensure valid mémoire access.

5. **Loop Bounds**: Always use `range()` with proper bounds to avoid infinite loops.

6. **String Interpolation**: Use `{var}` in strings to make output readable.

7. **Comments**: The language supports `desnote` for comments in TSL code.

---

## Common Errors and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| "Parsing error" | Invalid syntax | Check brackets and indentation |
| "Variable X is not bound" | Using undefined variable | Declare it first with `eric` |
| Type mismatch | Wrong type assignment | Check variable type annotation |
| Division by zero | Dividing by 0 | Add a check before division |
| Array index out of bounds | Accessing invalid index | Use `range()` for safe iteration |

---

## Summary

TSL is a practical language for learning programming concepts:
- **Variables** let you store data
- **Conditions** control execution flow
- **Boucles** repeat code
- **Fonctions** organize and réutiliser le code
- **Tableaux & Structures** organize complex data
- **Pointeurs** enable reference-based programming

Start with simple programs and gradually add complexity. Happy coding!
