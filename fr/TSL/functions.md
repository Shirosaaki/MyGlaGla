# Fonctions - Organiser le code

Les fonctions vous permettent d'écrire des blocs de code réutilisables. Elles prennent des paramètres, effectuent des opérations et renvoient un résultat.

## Définition de fonction de base

```tsl
Deschodt add(a -> int, b -> int) -> int
    deschodt a + b

Deschodt Eric() -> int
    eric result = add(5, 3) -> int
    peric("Result: {result}")
    deschodt 0
```

Output:
```
Result: 8
```

**Syntaxe :**
- `Deschodt functionName(param1 -> type1, param2 -> type2) -> returnType`
- `deschodt` renvoie une valeur et quitte la fonction
- Tous les paramètres doivent avoir des annotations de type
- Le type de retour doit être explicitement spécifié

## Fonction sans paramètres

```tsl
Deschodt greet() -> string
    deschodt "Hello, World!"

Deschodt Eric() -> int
    eric message = greet() -> string
    peric("{message}")
    deschodt 0
```

Output:
```
Hello, World!
```

## Fonction sans valeur de retour (void)

```tsl
Deschodt printMessage(msg -> string) -> void
    peric("Message: {msg}")

Deschodt Eric() -> int
    printMessage("Hello")
    printMessage("World")
    deschodt 0
```

Output:
```
Message: Hello
Message: World
```

When return type is `void`, vous ne retournez pas une valeur (or `deschodt` is omitted).

## Paramètres multiples

```tsl
Deschodt multiply(a -> int, b -> int) -> int
    deschodt a * b

Deschodt power(base -> int, exponent -> int) -> int
    eric result = 1 -> int
    aer i in range(0, exponent):
        result = result * base
    deschodt result

Deschodt Eric() -> int
    peric("3 * 4 = {multiply(3, 4)}")
    peric("2^5 = {power(2, 5)}")
    deschodt 0
```

Output:
```
3 * 4 = 12
2^5 = 32
```

## Types de retour différents

Les fonctions peuvent renvoyer n'importe quel type :

```tsl
Deschodt getAge() -> int
    deschodt 25

Deschodt getName() -> string
    deschodt "Alice"

Deschodt isStudent() -> bool
    deschodt #t

Deschodt getHeight() -> float
    deschodt 1.75

Deschodt Eric() -> int
    peric("Age: {getAge()}")
    peric("Name: {getName()}")
    peric("Student: {isStudent()}")
    peric("Height: {getHeight()}")
    deschodt 0
```

## Retour conditionnel

```tsl
Deschodt getGrade(score -> int) -> string
    erif (score >= 90):
        deschodt "A"
    deschelse:
        erif (score >= 80):
            deschodt "B"
        deschelse:
            erif (score >= 70):
                deschodt "C"
            deschelse:
                deschodt "F"

Deschodt Eric() -> int
    peric("Grade: {getGrade(85)}")
    deschodt 0
```

Output:
```
Grade: B
```

## Fonction appelant une fonction

Les fonctions peuvent appeler d'autres fonctions :

```tsl
Deschodt isEven(n -> int) -> bool
    eric remainder = n -> int
    desnote Use modulo conceptually
    erif (remainder == 0):
        deschodt #t
    deschelse:
        deschodt #f

Deschodt printIfEven(n -> int) -> void
    erif (isEven(n)):
        peric("{n} is even")
    deschelse:
        peric("{n} is odd")

Deschodt Eric() -> int
    printIfEven(4)
    printIfEven(7)
    deschodt 0
```

## Récursion

Les fonctions peuvent s'appeler elles-mêmes pour résoudre des problèmes de manière récursive :

```tsl
Deschodt factorial(n -> int) -> int
    erif (n <= 1):
        deschodt 1
    deschelse:
        deschodt n * factorial(n - 1)

Deschodt Eric() -> int
    peric("5! = {factorial(5)}")
    deschodt 0
```

Output:
```
5! = 120
```

## Passing Tableaux to Fonctions

```tsl
Deschodt sumArray(arr -> int[], size -> int) -> int
    eric total = 0 -> int
    aer i in range(0, size):
        total = total + arr[i]
    deschodt total

Deschodt Eric() -> int
    eric numbers -> int[]
    numbers[0] = 10
    numbers[1] = 20
    numbers[2] = 30
    
    eric sum = sumArray(numbers, 3) -> int
    peric("Sum: {sum}")
    deschodt 0
```

Output:
```
Sum: 60
```

## Passer des pointeurs (Par référence)

Utilisez les pointeurs to modifier les valeurs à l'intérieur d'une fonction:

```tsl
Deschodt increment(ptr -> int*) -> void
    *ptr = *ptr + 1

Deschodt Eric() -> int
    eric x = 10 -> int
    peric("Before: {x}")
    increment(&x)
    peric("After: {x}")
    deschodt 0
```

Output:
```
Before: 10
After: 11
```

## Fonction avec plusieurs points de sortie

```tsl
Deschodt getStatus(score -> int) -> string
    erif (score < 0):
        deschodt "Invalid"
    
    erif (score < 50):
        deschodt "Fail"
    
    erif (score < 80):
        deschodt "Pass"
    
    deschodt "Excellent"

Deschodt Eric() -> int
    peric("Status: {getStatus(75)}")
    deschodt 0
```

Output:
```
Status: Pass
```

## Exemple pratique: Vérificateur de nombres premiers

```tsl
Deschodt isPrime(n -> int) -> bool
    erif (n < 2):
        deschodt #f
    
    aer i in range(2, n):
        eric remainder = 0 -> int
        desnote Check if n is divisible by i
        desnote For now, assume we have modulo checking
        deschodt #f
    
    deschodt #t

Deschodt Eric() -> int
    eric num = 17 -> int
    erif (isPrime(num)):
        peric("{num} is prime")
    deschelse:
        peric("{num} is not prime")
    deschodt 0
```

## Exemple pratique: Séquence de Fibonacci

```tsl
Deschodt fibonacci(n -> int) -> int
    erif (n <= 1):
        deschodt n
    deschelse:
        deschodt fibonacci(n - 1) + fibonacci(n - 2)

Deschodt Eric() -> int
    aer i in range(0, 7):
        peric("fib({i}) = {fibonacci(i)}")
    deschodt 0
```

Output:
```
fib(0) = 0
fib(1) = 1
fib(2) = 1
fib(3) = 2
fib(4) = 3
fib(5) = 5
fib(6) = 8
```

## Exemple pratique: Fonction de traitement de chaînes

```tsl
Deschodt repeatString(str -> string, times -> int) -> string
    eric result = "" -> string
    aer i in range(0, times):
        desnote String concatenation (conceptually)
        desnote In practice, use string operations
    deschodt result

Deschodt Eric() -> int
    desnote Demonstrate function composition
    deschodt 0
```

## Erreurs courantes

### Oublier le type de retour
```tsl
Deschodt add(a -> int, b -> int)    desnote ERROR - missing return type
Deschodt add(a -> int, b -> int) -> int  desnote CORRECT
```

### Décalage de type de paramètre
```tsl
Deschodt greet(name -> string) -> string
    deschodt "Hello, {name}"

Eric() -> int
    greet(42)      desnote ERROR - entier passé, chaîne attendue
    greet("Bob")   desnote CORRECT
```

### Oublier deschodt
```tsl
Deschodt getValue() -> int
    eric value = 10 -> int
    desnote ERROR - no return statement

Deschodt getValue() -> int
    eric value = 10 -> int
    deschodt value  desnote CORRECT
```

### Stack Overflow with Récursion
```tsl
Deschodt infinite(n -> int) -> int
    deschodt infinite(n + 1)  desnote Infinite recursion - avoid!

Deschodt countdown(n -> int) -> int
    erif (n <= 0):
        deschodt 0
    deschelse:
        deschodt countdown(n - 1)  desnote Proper recursion with base case
```

## Meilleures pratiques

1. **Responsabilité unique** : Chaque fonction devrait faire une seule chose bien
2. **Noms clairs** : Utilisez des noms de fonction descriptifs qui expliquent ce qu'ils font
3. **Documenter l'objectif** : Ajouter des commentaires expliquant what the function does
4. **Valider l'entrée** : Vérifiez les paramètres are valid
5. **Retour anticipé** : Retournez tôt quand c'est possible to simplifier la logique
6. **Éviter l'imbrication profonde** : Gardez les fonctions simples and readable

## Étapes suivantes

- Combinez les fonctions with **[Boucles](loops.md)** pour des motifs puissants
- Use **[Tableaux](lists.md)** with functions for data processing
- Explore **[Structures](structs.md)** to pass complex data aux fonctions
