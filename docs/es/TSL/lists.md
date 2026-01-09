# Tablas (Listas) - Almacenar múltiples valores

Las tablas almacenan múltiples valores del mismo tipo en un orden secuencial. Te permiten trabajar con colecciones de datos donde todos los índices desde 0 hasta el índice más alto utilizado se llenan automáticamente.

## Crear una tabla

```tsl
Deschodt Eric() -> int
    eric numbers -> int[]
    eric names -> string[]
    eric flags -> bool[]
    deschodt 0
```

**Sintaxis:**
- `eric variableName -> type[]` declara un array de este tipo
- Los arrays pueden contener `int`, `float`, `string`, `char`, `bool`, o tipos personalizados

## Definición de los valores del array

Los arrays utilizan la notación de índice con corchetes `[]`. Los índices comienzan en `0`:

```tsl
Deschodt Eric() -> int
    eric scores -> int[]
    
    scores[0] = 95
    scores[1] = 87
    scores[2] = 92
    
    peric("First score: {scores[0]}")
    peric("Third score: {scores[2]}")
    deschodt 0
```

Sortie :
```
First score: 95
Third score: 92
```

## Acceso a los elementos de la tabla

Utiliza el índice `[n]` para leer los valores :

```tsl
Deschodt Eric() -> int
    eric colors -> string[]
    
    colors[0] = "red"
    colors[1] = "green"
    colors[2] = "blue"
    
    eric first = colors[0] -> string
    eric second = colors[1] -> string
    
    peric("Colors: {first}, {second}")
    deschodt 0
```

Sortie :
```
Colors: red, green
```

## Recorrer los arreglos con `aer`

Utiliza el bucle `aer` (for-in) para iterar a través de los índices del arreglo :

```tsl
Deschodt Eric() -> int
    eric numbers -> int[]
    
    numbers[0] = 10
    numbers[1] = 20
    numbers[2] = 30
    numbers[3] = 40
    
    aer i in range(0, 4):
        peric("numbers[{i}] = {numbers[i]}")
    
    deschodt 0
```

Sortie :
```
numbers[0] = 10
numbers[1] = 20
numbers[2] = 30
numbers[3] = 40
```

## Comprender el relleno secuencial hacia adelante

Cuando defines un elemento de la matriz en el índice N, todos los índices de 0 a N-1 se rellenan automáticamente con el valor definido anteriormente más reciente. Esto se llama **relleno secuencial hacia adelante** :

```tsl
Deschodt Eric() -> int
    eric data -> int[]
    
    data[0] = 50        desnote data is now [50]
    data[2] = 20        desnote data automatically becomes [50, 50, 20]
    
    desnote Index 1 was automatically filled with the previous value (50)
    peric("data[0] = {data[0]}")   desnote prints 50
    peric("data[1] = {data[1]}")   desnote prints 50 (auto-filled)
    peric("data[2] = {data[2]}")   desnote prints 20
    
    deschodt 0
```

Sortie :
```
data[0] = 50
data[1] = 50
data[2] = 20
```

### Otro ejemplo

```tsl
Deschodt Eric() -> int
    eric numbers -> int[]
    
    numbers[0] = 100
    numbers[5] = 200    desnote Creates array with 6 elements total
    
    desnote Indices 1-4 sont automatiquement remplis with 100
    aer i in range(0, 6):
        peric("numbers[{i}] = {numbers[i]}")
    
    deschodt 0
```

Sortie :
```
numbers[0] = 100
numbers[1] = 100
numbers[2] = 100
numbers[3] = 100
numbers[4] = 100
numbers[5] = 200
```

**Punto clave:** A diferencia de los arreglos dispersos en otros lenguajes, no puedes tener "huecos" o índices "no definidos". Establecer `data[0]=50` y luego `data[100]=20` crea un arreglo de 101 elementos donde los índices 1-99 se rellenan automáticamente con 50.

## Arreglo de cadenas

```tsl
Deschodt Eric() -> int
    eric fruits -> string[]
    
    fruits[0] = "apple"
    fruits[1] = "banana"
    fruits[2] = "orange"
    fruits[3] = "grape"
    
    aer i in range(0, 4):
        peric("Fruit {i}: {fruits[i]}")
    
    deschodt 0
```

Sortie :
```
Fruit 0: apple
Fruit 1: banana
Fruit 2: orange
Fruit 3: grape
```

## Tabla de flotantes

```tsl
Deschodt Eric() -> int
    eric temperatures -> float[]
    
    temperatures[0] = 20.5
    temperatures[1] = 22.3
    temperatures[2] = 18.7
    temperatures[3] = 25.0
    
    aer day in range(0, 4):
        peric("Day {day}: {temperatures[day]}°C")
    
    deschodt 0
```

Sortie :
```
Day 0: 20.5°C
Day 1: 22.3°C
Day 2: 18.7°C
Day 3: 25.0°C
```

## Cálculo con tablas

### Suma de los elementos de la tabla

```tsl
Deschodt Eric() -> int
    eric numbers -> int[]
    
    numbers[0] = 10
    numbers[1] = 20
    numbers[2] = 30
    numbers[3] = 40
    
    eric total = 0 -> int
    aer i in range(0, 4):
        total = total + numbers[i]
    
    peric("Total: {total}")
    deschodt 0
```

Sortie :
```
Total: 100
```

### Encontrar el valor máximo

```tsl
Deschodt Eric() -> int
    eric scores -> int[]
    
    scores[0] = 45
    scores[1] = 92
    scores[2] = 78
    scores[3] = 88
    scores[4] = 95
    
    eric max_score = scores[0] -> int
    aer i in range(1, 5):
        erif (scores[i] > max_score):
            max_score = scores[i]
    
    peric("Highest score: {max_score}")
    deschodt 0
```

Sortie :
```
Highest score: 95
```

### Contar los elementos

```tsl
Deschodt Eric() -> int
    eric numbers -> int[]
    
    numbers[0] = 5
    numbers[1] = 3
    numbers[2] = 7
    numbers[3] = 3
    numbers[4] = 5
    numbers[5] = 9
    
    eric count = 0 -> int
    eric target = 5 -> int
    
    aer i in range(0, 6):
        erif (numbers[i] == target):
            count = count + 1
    
    peric("Found {target} {count} times")
    deschodt 0
```

Sortie :
```
Found 5 2 times
```

## Tableros de booleanos

```tsl
Deschodt Eric() -> int
    eric flags -> bool[]
    
    flags[0] = #t
    flags[1] = #f
    flags[2] = #t
    flags[3] = #f
    flags[4] = #t
    
    eric true_count = 0 -> int
    aer i in range(0, 5):
        erif (flags[i]):
            true_count = true_count + 1
    
    peric("True values: {true_count}")
    deschodt 0
```

Sortie :
```
True values: 3
```

## Paso de tablas a funciones

```tsl
Deschodt sumArray(arr -> int[], size -> int) -> int
    eric total = 0 -> int
    aer i in range(0, size):
        total = total + arr[i]
    deschodt total

Deschodt averageArray(arr -> int[], size -> int) -> float
    eric sum = sumArray(arr, size) -> int
    deschodt sum / size

Deschodt Eric() -> int
    eric grades -> int[]
    
    grades[0] = 85
    grades[1] = 92
    grades[2] = 78
    grades[3] = 95
    
    eric avg = averageArray(grades, 4) -> float
    peric("Average: {avg}")
    deschodt 0
```

Sortie :
```
Average: 87.5
```

## Tabla de caracteres

```tsl
Deschodt Eric() -> int
    eric letters -> char[]
    
    letters[0] = #\a
    letters[1] = #\b
    letters[2] = #\c
    
    aer i in range(0, 3):
        peric("Letter {i}: {letters[i]}")
    
    deschodt 0
```

Sortie :
```
Letter 0: a
Letter 1: b
Letter 2: c
```

## Comprender el tamaño del arreglo

Debido al llenado secuencial hacia adelante, el tamaño del arreglo se determina por el índice más alto que has definido más uno. Todos los índices inferiores se crean y llenan automáticamente:

```tsl
Deschodt Eric() -> int
    eric data -> int[]
    
    data[0] = 10     desnote Array size: 1
    data[3] = 40     desnote Array size: 4 (auto-fill creates indices 1 and 2)
    data[1] = 20     desnote Array size: still 4
    
    desnote Accessing an index that hasn't been explicitly set yet but was auto-filled
    peric("{data[2]}")   desnote Prints 10 (filled by remplissage séquentiel vers l'avant)
    deschodt 0
```

**Importante :** No puedes acceder a índices más allá de lo que ha sido creado por tus asignaciones. El tamaño del arreglo crece a medida que accedes a índices más altos, pero primero debes establecer un valor en ese índice.

## Ejemplo práctico : Tabla de multiplicar

```tsl
Deschodt Eric() -> int
    eric table -> int[]
    eric multiplier = 7 -> int
    
    desnote Set values at indices 1-10
    desnote Note: index 0 will be auto-filled with 7 * 1 = 7
    aer i in range(1, 11):
        table[i] = multiplier * i
    
    desnote Now print from index 1 to 10 (index 0 auto-filled)
    aer i in range(1, 11):
        peric("7 × {i} = {table[i]}")
    
    deschodt 0
```

Sortie :
```
7 × 1 = 7
7 × 2 = 14
7 × 3 = 21
...
7 × 10 = 70
```

## Ejemplo práctico: Asignación de carta de calificación

```tsl
Deschodt Eric() -> int
    eric scores -> int[]
    eric grades -> string[]
    
    scores[0] = 92
    scores[1] = 78
    scores[2] = 65
    scores[3] = 88
    scores[4] = 95
    
    aer i in range(0, 5):
        eric score = scores[i] -> int
        erif (score >= 90):
            grades[i] = "A"
        deschelse:
            erif (score >= 80):
                grades[i] = "B"
            deschelse:
                erif (score >= 70):
                    grades[i] = "C"
                deschelse:
                    grades[i] = "F"
    
    aer i in range(0, 5):
        peric("Score {scores[i]}: Grade {grades[i]}")
    
    deschodt 0
```

Sortie :
```
Score 92: Grade A
Score 78: Grade C
Score 65: Grade F
Score 88: Grade B
Score 95: Grade A
```

## Ejemplo práctico: Encontrar el valor mínimo

```tsl
Deschodt Eric() -> int
    eric values -> int[]
    
    values[0] = 45
    values[1] = 12
    values[2] = 89
    values[3] = 23
    values[4] = 7
    values[5] = 56
    
    eric min_val = values[0] -> int
    aer i in range(1, 6):
        erif (values[i] < min_val):
            min_val = values[i]
    
    peric("Minimum: {min_val}")
    deschodt 0
```

Sortie :
```
Minimum: 7
```

## Errores comunes

### Olvidar el tipo de tabla
```tsl
eric data -> int[]        desnote CORRECT
eric data -> []           desnote ERROR - must specify type
```

### No Comprender el relleno secuencial hacia adelante
```tsl
eric arr -> int[]
arr[0] = 10
arr[2] = 30              desnote This creates [10, 10, 30] - index 1 auto-filled!
eric x = arr[1] -> int   desnote This is valid and égals 10 (auto-filled)
```

### Desplazamiento de tipo en Array
```tsl
eric numbers -> int[]
numbers[0] = 10          desnote CORRECT
numbers[1] = "ten"       desnote ERROR - string in int array
```

### Bucle Fuera de Límites
```tsl
eric data -> int[]
data[3] = 30
data[5] = 50             desnote Array now has 6 elements (indices 0-5)

aer i in range(0, 10):   desnote WRONG - will try to access data[6-9]
    peric(data[i])

aer i in range(0, 6):    desnote CORRECT - matches array size
    peric(data[i])
```

## Mejores prácticas

1. **Entender Fill-Forward**: Recuerda que establecer un índice alto llena todos los índices intermedios con el valor anterior.
2. **Rastrear el tamaño del array**: Mantén un seguimiento de cuál es tu índice más alto (eso determina el tamaño del array).
3. **Usar índices contiguos**: Normalmente establece los índices 0, 1, 2... en orden para un código más claro.
4. **Hacer coincidir los límites del bucle**: El rango de tu bucle debe coincidir con el tamaño real del array (índice más alto + 1).
5. **Usar funciones**: Extrae las operaciones del array en funciones para reutilizarlas.
6. **Documentar la longitud del array**: Añade comentarios sobre el tamaño esperado del array.

## Pasos siguientes

- Combina arrays con **[Funciones](functions.md)** para procesar datos.
- Usa arrays en **[Bucles](loops.md)** para iteración.
- Almacena arrays en **[Estructuras](structs.md)** para estructuras de datos complejas.
