# Bucles - Repetir el código

Los bucles te permiten repetir código varias veces sin tener que escribirlo una y otra vez. TSL ofrece dos tipos: `aer` (for-in) y `darius` (while).

## Bucle For-In (aer)

El bucle `aer` itera sobre un rango:

```tsl
Deschodt Eric() -> int
    aer i in range(0, 5):
        peric("i = {i}")
    
    deschodt 0
```

Sortie:
```
i = 0
i = 1
i = 2
i = 3
i = 4
```

**Puntos clave:**
- `aer i in range(0, 5)` bucle de 0 a 4 (5 iteraciones)
- El rango es `start` a `end-1` (el final es exclusivo)
- `i` es la variable del bucle, incrementada automáticamente

## Bucle While (darius)

El bucle `darius` se repite mientras una condición sea verdadera:

```tsl
Deschodt Eric() -> int
    eric x = 0 -> int
    
    darius (x < 3):
        peric("x = {x}")
        x = x + 1
    
    deschodt 0
```

Sortie:
```
x = 0
x = 1
x = 2
```

**Puntos clave:**
- La condición se verifica antes de cada iteración
- Debes actualizar manualmente el contador (`x = x + 1`)
- Si la condición nunca es verdadera, el bucle nunca se ejecuta

## Instrucciones de control de bucle

### continuar - Pasar a la siguiente iteración

`deschontinue` pasa a la siguiente iteración:

```tsl
Deschodt Eric() -> int
    aer i in range(0, 5):
        erif (i == 2):
            deschontinue    desnote skip when i = 2
        peric("i = {i}")
    
    deschodt 0
```

Sortie:
```
i = 0
i = 1
i = 3
i = 4
```

### salir - Salir del bucle

`deschreak` sale inmediatamente del bucle:

```tsl
Deschodt Eric() -> int
    aer i in range(0, 10):
        erif (i == 5):
            deschreak       desnote exit when i = 5
        peric("i = {i}")
    
    peric("Loop finished")
    deschodt 0
```

Sortie:
```
i = 0
i = 1
i = 2
i = 3
i = 4
Loop finished
```

## Ejemplo de Bucle Complejo

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

Sortie:
```
i = 0
i = 1
i = 2
i = 4
i = 5
i = 6
Fin de boucle
```

## Boucles Anidadas

Las boucles pueden estar anidadas dentro de otras:

```tsl
Deschodt Eric() -> int
    aer i in range(0, 3):
        aer j in range(0, 3):
            peric("({i}, {j})")
    
    deschodt 0
```

Sortie:
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

## Iterando Sobre Tableros

Utiliza bucles para procesar elementos de un arreglo:

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

Sortie:
```
nums[0] = 10
nums[1] = 20
nums[2] = 30
```

## Bucle While con Arreglos

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

Sortie:
```
arr[0] = 5
arr[1] = 10
arr[2] = 15
```

## Bucle Infinito (¡Cuidado!)

Un bucle que nunca termina:

```tsl
eric counter = 0 -> int
darius (#t):        desnote always true
    peric("Infinite loop: {counter}")
    counter = counter + 1
    erif (counter > 5):
        deschreak   desnote exit manually
```

Sortie:
```
Infinite loop: 0
Infinite loop: 1
Infinite loop: 2
Infinite loop: 3
Infinite loop: 4
Infinite loop: 5
```

## Ejemplo práctico: Sumar Números

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

Sortie:
```
Sum of 1 to 5: 15
```

## Ejemplo práctico: Encontrar el máximo

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

Sortie:
```
Maximum: 23
```

## Ejemplo práctico: Imprimir tabla de multiplicación

```tsl
Deschodt Eric() -> int
    eric num = 7 -> int
    peric("Multiplication table for {num}:")
    
    aer i in range(1, 11):
        eric product = num * i -> int
        peric("{num} x {i} = {product}")
    
    deschodt 0
```

Sortie:
```
Multiplication table for 7:
7 x 1 = 7
7 x 2 = 14
7 x 3 = 21
...
7 x 10 = 70
```

## Errores comunes

### Error de uno fuera de lugar
```tsl
desnote Wants to print 0-4, but range(0, 5) gives 0-4 - this is correct!
aer i in range(0, 5):
    peric("{i}")

desnote Common mistake: forgetting that end is exclusive
aer i in range(0, 4):      desnote Only goes to 3, not 4
    peric("{i}")
```

### Bucle Infinito con While
```tsl
eric x = 0 -> int
darius (x < 5):
    peric("{x}")
    desnote Forgot x = x + 1, infinite loop!
```

### Tipo de Bucle Incorrecto
```tsl
desnote Use aer when you know how many iterations
aer i in range(0, 5):
    peric("{i}")

desnote Use darius when condition is complex
darius ((x > 0) && (y < 10)):
    x = x - 1
```

## Étapes siguientes

- Aprende **[Funciones](functions.md)** para organizar la lógica de bucles
- Explora **[Arreglos](lists.md)** para procesar colecciones
- Usa **[Condiciones](condition.md)** dentro de los bucles
