# Boucles - Répéter le code

Les boucles vous permettent de répéter du code plusieurs fois sans l'écrire encore et encore. TSL propose deux types : `aer` (for-in) et `darius` (while).

## Boucle For-In (aer)

La boucle `aer` itère sur une plage :

```tsl
Deschodt Eric() -> int
    aer i in range(0, 5):
        peric("i = {i}")
    
    deschodt 0
```

Sortie :
```
i = 0
i = 1
i = 2
i = 3
i = 4
```

**Points clés :**
- `aer i in range(0, 5)` boucle de 0 à 4 (5 itérations)
- La plage est `start` à `end-1` (la fin est exclusive)
- `i` est la variable de boucle, incrémentée automatiquement

## Boucle While (darius)

La boucle `darius` se répète tant qu'une condition est vraie :

```tsl
Deschodt Eric() -> int
    eric x = 0 -> int
    
    darius (x < 3):
        peric("x = {x}")
        x = x + 1
    
    deschodt 0
```

Sortie :
```
x = 0
x = 1
x = 2
```

**Points clés :**
- La condition est vérifiée avant chaque itération
- Vous devez mettre à jour manuellement le compteur (`x = x + 1`)
- Si la condition n'est jamais vraie, la boucle ne s'exécute jamais

## Instructions de contrôle de boucle

### continuer - Passer à l'itération suivante

`deschontinue` passe à l'itération suivante :

```tsl
Deschodt Eric() -> int
    aer i in range(0, 5):
        erif (i == 2):
            deschontinue    desnote skip when i = 2
        peric("i = {i}")
    
    deschodt 0
```

Sortie :
```
i = 0
i = 1
i = 3
i = 4
```

### sortir - Quitter la boucle

`deschreak` quitte immédiatement la boucle :

```tsl
Deschodt Eric() -> int
    aer i in range(0, 10):
        erif (i == 5):
            deschreak       desnote exit when i = 5
        peric("i = {i}")
    
    peric("Loop finished")
    deschodt 0
```

Sortie :
```
i = 0
i = 1
i = 2
i = 3
i = 4
Loop finished
```

## Complex Loop Example

```tsl
Deschodt Eric() -> int
    aer i in range(0, 10):
        erif (i == 3):
            deschontinue    desnote skip 3
        erif (i == 7):
            deschreak       desnote exit at 7
        peric("i = {i}")
    
    peric("Loop finished")
    deschodt 0
```

Sortie :
```
i = 0
i = 1
i = 2
i = 4
i = 5
i = 6
Fin de boucle
```

## Nested Boucles

Boucles can be nested inside each other:

```tsl
Deschodt Eric() -> int
    aer i in range(0, 3):
        aer j in range(0, 3):
            peric("({i}, {j})")
    
    deschodt 0
```

Sortie :
```
(0, 0)
(0, 1)
(0, 2)
(1, 0)
(1, 1)
(1, 2)
(2, 0)
(2, 1)
(2, 2)
```

## Iterating Over Tableaux

Use loops to process array elements:

```tsl
Deschodt Eric() -> int
    eric nums -> int[]
    nums[0] = 10
    nums[1] = 20
    nums[2] = 30
    
    aer i in range(0, 3):
        peric("nums[{i}] = {nums[i]}")
    
    deschodt 0
```

Sortie :
```
nums[0] = 10
nums[1] = 20
nums[2] = 30
```

## Boucle While with Tableaux

```tsl
Deschodt Eric() -> int
    eric arr -> int[]
    arr[0] = 5
    arr[1] = 10
    arr[2] = 15
    
    eric index = 0 -> int
    darius (index < 3):
        peric("arr[{index}] = {arr[index]}")
        index = index + 1
    
    deschodt 0
```

Sortie :
```
arr[0] = 5
arr[1] = 10
arr[2] = 15
```

## Infinite Loop (Careful!)

A loop that never ends:

```tsl
eric counter = 0 -> int
darius (#t):        desnote always true
    peric("Infinite loop: {counter}")
    counter = counter + 1
    erif (counter > 5):
        deschreak   desnote exit manually
```

Sortie :
```
Infinite loop: 0
Infinite loop: 1
Infinite loop: 2
Infinite loop: 3
Infinite loop: 4
Infinite loop: 5
```

## Exemple pratique: Sum Numbers

```tsl
Deschodt sumRange(start -> int, end -> int) -> int
    eric total = 0 -> int
    aer i in range(start, end):
        total = total + i
    deschodt total

Deschodt Eric() -> int
    eric result = sumRange(1, 6) -> int
    peric("Sum of 1 to 5: {result}")
    deschodt 0
```

Sortie :
```
Sum of 1 to 5: 15
```

## Exemple pratique: Find Maximum

```tsl
Deschodt findMax(arr -> int[], size -> int) -> int
    eric max = arr[0] -> int
    aer i in range(1, size):
        erif (arr[i] > max):
            max = arr[i]
    deschodt max

Deschodt Eric() -> int
    eric numbers -> int[]
    numbers[0] = 15
    numbers[1] = 8
    numbers[2] = 23
    numbers[3] = 4
    
    eric maximum = findMax(numbers, 4) -> int
    peric("Maximum: {maximum}")
    deschodt 0
```

Sortie :
```
Maximum: 23
```

## Exemple pratique: Print Table de multiplication

```tsl
Deschodt Eric() -> int
    eric num = 7 -> int
    peric("Multiplication table for {num}:")
    
    aer i in range(1, 11):
        eric product = num * i -> int
        peric("{num} x {i} = {product}")
    
    deschodt 0
```

Sortie :
```
Multiplication table for 7:
7 x 1 = 7
7 x 2 = 14
7 x 3 = 21
...
7 x 10 = 70
```

## Erreurs courantes

### Off-by-One Error
```tsl
desnote Wants to print 0-4, but range(0, 5) gives 0-4 - this is correct!
aer i in range(0, 5):
    peric("{i}")

desnote Common mistake: forgetting that end is exclusive
aer i in range(0, 4):      desnote Only goes to 3, not 4
    peric("{i}")
```

### Infinite Loop with While
```tsl
eric x = 0 -> int
darius (x < 5):
    peric("{x}")
    desnote Forgot x = x + 1, infinite loop!
```

### Wrong Loop Type
```tsl
desnote Use aer when you know how many iterations
aer i in range(0, 5):
    peric("{i}")

desnote Use darius when condition is complex
darius ((x > 0) && (y < 10)):
    x = x - 1
```

## Étapes suivantes

- Learn **[Fonctions](functions.md)** to organize loop logic
- Explore **[Tableaux](lists.md)** to process collections
- Use **[Conditions](condition.md)** inside loops
