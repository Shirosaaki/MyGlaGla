# Punteros - Referencias a valores

Los punteros almacenan las direcciones de memoria de otras variables. Te permiten trabajar con los valores de forma indirecta y modificar los datos en funciones.

## Entendiendo los Punteros

Un puntero es una variable que contiene la dirección de memoria de otra variable:

```
Variable régulière:    int x = 5        (stocke la valeur 5)
Variable pointeur:    int* ptr = &x    (stores the address of x)
```

El operador `&` obtiene la dirección de una variable.  
El operador `*` accede al valor en una dirección.  

## Declaración de puntero e Inicialización

```tsl
Deschodt Eric() -> int
    eric x = 10 -> int
    eric ptr = &x -> int*
    
    peric("Value of x: {x}")
    peric("Address of x: {ptr}")
    
    deschodt 0
```

Lo siento, pero no has proporcionado el contenido en Markdown que deseas traducir. Por favor, comparte el texto y estaré encantado de ayudarte con la traducción.
```
Value of x: 10
Address of x: 94593175618496
```

**Sintaxis:**
- `eric ptr -> int*` declara un puntero a un int (tipo con `*`)
- `&variable` obtiene la dirección de una variable
- Asignar: `ptr = &x`

## Desreferenciando Punteros

Desreferenciar un puntero con `*` para acceder al valor al que apunta:

```tsl
Deschodt Eric() -> int
    eric x = 10 -> int
    eric ptr = &x -> int*
    
    eric value = *ptr -> int
    peric("x = {x}")
    peric("*ptr = {value}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into Spanish (ES).
```
x = 10
*ptr = 10
```

Quand vous déréférencez un pointeur, vous obtenez la valeur à cette adresse.

## Modification à Travers des Pointeurs

Vous pouvez modifier une valeur via un pointeur:

```tsl
Deschodt Eric() -> int
    eric x = 10 -> int
    eric ptr = &x -> int*
    
    peric("Before: x = {x}")
    
    *ptr = 20
    peric("After: x = {x}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into Spanish (ES).
```
Before: x = 10
After: x = 20
```

Changing `*ptr` cambia la variable original `x`.

## Tipos de punteros

Diferentes tipos de punteros:

```tsl
Deschodt Eric() -> int
    eric intVal = 42 -> int
    eric floatVal = 3.14 -> float
    eric strVal = "hello" -> string
    eric boolVal = #t -> bool
    
    eric intPtr = &intVal -> int*
    eric floatPtr = &floatVal -> float*
    eric strPtr = &strVal -> string*
    eric boolPtr = &boolVal -> bool*
    
    peric("int* points to: {*intPtr}")
    peric("float* points to: {*floatPtr}")
    
    deschodt 0
```

## Parámetros de función con Punteros

Pasar punteros a las funciones para modificar valores dentro de la función:

```tsl
Deschodt increment(ptr -> int*) -> void
    *ptr = *ptr + 1

Deschodt Eric() -> int
    eric x = 5 -> int
    peric("Before: {x}")
    
    increment(&x)
    peric("After: {x}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into Spanish (ES).
```
Before: 5
After: 6
```

La función modifica la variable original a través de su parámetro de puntero.

## Intercambio de valores con Punteros

```tsl
Deschodt swap(a -> int*, b -> int*) -> void
    eric temp = *a -> int
    *a = *b
    *b = temp

Deschodt Eric() -> int
    eric x = 10 -> int
    eric y = 20 -> int
    
    peric("Before: x = {x}, y = {y}")
    swap(&x, &y)
    peric("After: x = {x}, y = {y}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into Spanish (ES).
```
Before: x = 10, y = 20
After: x = 20, y = 10
```

## Comparando Pointeurs

```tsl
Deschodt Eric() -> int
    eric x = 10 -> int
    eric y = 20 -> int
    
    eric ptr1 = &x -> int*
    eric ptr2 = &x -> int*
    eric ptr3 = &y -> int*
    
    erif (ptr1 == ptr2):
        peric("ptr1 and ptr2 point to same location")
    
    erif (ptr1 != ptr3):
        peric("ptr1 and ptr3 point to different locations")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into Spanish (ES).
```
ptr1 and ptr2 point to same location
ptr1 and ptr3 point to different locations
```

## Aritmética de punteros (Conceptual)

```tsl
Deschodt Eric() -> int
    eric arr -> int[]
    arr[0] = 10
    arr[1] = 20
    arr[2] = 30
    
    eric ptr = &arr[0] -> int*
    peric("Points to: {*ptr}")
    
    deschodt 0
```

## Parámetros de tabla con Punteros

```tsl
Deschodt doubleArray(arr -> int*, size -> int) -> void
    aer i in range(0, size):
        desnote Access element through pointer arithmetic (conceptual)
        desnote For now, use the array directly

Deschodt Eric() -> int
    eric values -> int[]
    values[0] = 1
    values[1] = 2
    values[2] = 3
    
    eric ptr = &values[0] -> int*
    peric("First element: {*ptr}")
    
    deschodt 0
```

## Devolviendo Pointeurs desde Funciones

```tsl
Deschodt getMax(a -> int*, b -> int*) -> int*
    erif (*a > *b):
        deschodt a
    deschelse:
        deschodt b

Deschodt Eric() -> int
    eric x = 10 -> int
    eric y = 25 -> int
    
    eric maxPtr = getMax(&x, &y) -> int*
    peric("Maximum: {*maxPtr}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into Spanish (ES).
```
Maximum: 25
```

## Campos de estructura con Punteros

```tsl
destruct LinkedNode
    value -> int
    next -> LinkedNode*

Deschodt Eric() -> int
    eric node -> LinkedNode
    node.value = 10
    desnote node.next = null (not yet implemented)
    
    peric("Node value: {node.value}")
    deschodt 0
```

## Pasar por valor frente a Pasar por puntero

**Pasar por valor** - La función obtiene una COPIA:

```tsl
Deschodt incrementValue(x -> int) -> void
    x = x + 1

Deschodt Eric() -> int
    eric num = 5 -> int
    incrementValue(num)
    peric("{num}")  desnote Still 5 - copy was modified
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into Spanish (ES).
```
5
```

**Pase por Puntero** - La función obtiene la DIRECCIÓN:

```tsl
Deschodt incrementPointer(ptr -> int*) -> void
    *ptr = *ptr + 1

Deschodt Eric() -> int
    eric num = 5 -> int
    incrementPointer(&num)
    peric("{num}")  desnote Now 6 - l'original a été modifié
    deschodt 0
```

Sure! Please provide the Markdown chunk you would like me to translate into Spanish (ES).
```
6
```

Utiliza punteros cuando necesites modificar la variable original.

## Ejemplo práctico: Actualizar los valores de la estructura

```tsl
destruct BankAccount
    balance -> float
    transactions -> int

Deschodt deposit(account -> BankAccount*, amount -> float) -> void
    (*account).balance = (*account).balance + amount
    (*account).transactions = (*account).transactions + 1

Deschodt Eric() -> int
    eric myAccount -> BankAccount
    myAccount.balance = 1000.0
    myAccount.transactions = 0
    
    peric("Initial balance: {myAccount.balance}")
    deposit(&myAccount, 500.0)
    peric("After deposit: {myAccount.balance}")
    peric("Transactions: {myAccount.transactions}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into Spanish (ES).
```
Initial balance: 1000.0
After deposit: 1500.0
Transactions: 1
```

## Ejemplo práctico: Ordenamiento burbuja con Punteros

```tsl
Deschodt swap(a -> int*, b -> int*) -> void
    eric temp = *a -> int
    *a = *b
    *b = temp

Deschodt Eric() -> int
    eric arr -> int[]
    arr[0] = 64
    arr[1] = 34
    arr[2] = 25
    arr[3] = 12
    arr[4] = 22
    
    desnote Simple sorting loop
    aer i in range(0, 5):
        aer j in range(0, 4):
            erif (arr[j] > arr[j + 1]):
                swap(&arr[j], &arr[j + 1])
    
    aer i in range(0, 5):
        peric("{arr[i]}")
    
    deschodt 0
```

Sure! Please provide the Markdown chunk that you would like me to translate into Spanish (ES).
```
12
22
25
34
64
```

## Errores comunes

### Desreferenciar sin Inicialización
```tsl
eric ptr -> int*
desnote ptr is non initialisé
eric value = *ptr -> int  desnote ERROR - accès aux ordures mémoire
```

Siempre inicializa punteros:
```tsl
eric x = 10 -> int
eric ptr = &x -> int*  desnote CORRECT - maintenant en sécurité to dereference
```

### Desajuste de tipo
```tsl
eric x = 10 -> int
eric strPtr = &x -> string*  desnote ERROR - type mismatch
eric intPtr = &x -> int*     desnote CORRECT
```

### Olvidar desindexar
```tsl
eric x = 10 -> int
eric ptr = &x -> int*

eric value = ptr -> int  desnote ERROR - assigne l'adresse, not value
eric value = *ptr -> int desnote CORRECT - déréférences to get value
```

### Modificación Sin Desreferencia
```tsl
eric x = 10 -> int
eric ptr = &x -> int*

ptr = 20         desnote ERROR - changes the pointer, not x
*ptr = 20        desnote CORRECT - changes the value x points to
```

## Mejores prácticas

1. **Inicializa Punteros**: Siempre apunta a una variable válida
2. **Verifica Antes de Desreferenciar**: Asegúrate de que el puntero sea válido
3. **Usa Nombres Significativos**: Usa el sufijo `ptr`: `xPtr`, `nodePtr`
4. **Documenta la Propiedad**: Aclara quién es el dueño de la memoria
5. **Punteros Nulos**: Usa los punteros con cuidado cuando puedan ser nulos
6. **Evita Punteros Colgantes**: No apuntes a variables que salgan del ámbito
7. **Usa Cuando Sea Necesario**: Solo usa punteros cuando sea necesario (modificando originales)

## Pasos Siguientes

- Usa punteros con **[Estructuras](structs.md)** para estructuras de datos complejas
- Combina punteros con **[Funciones](functions.md)** para la modificación de datos
- Aplica punteros en **[Arreglos](lists.md)** para un procesamiento eficiente
